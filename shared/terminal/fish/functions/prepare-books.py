#!/usr/bin/env python3
"""Remove given filename prefixes and create missing EPUBs with pdf2epub."""

import argparse
import ctypes
import errno
import hashlib
import os
from pathlib import Path
import posixpath
import re
import shutil
import signal
import stat
import subprocess
import sys
import tempfile
import time
from collections import deque
from urllib.parse import unquote, urlsplit
import xml.etree.ElementTree as ET
import zipfile


SEPARATOR = "[_ -]"


def prefix_pattern(prefixes):
    """Match any of the prefixes at the start of a name, ignoring case.

    The separators around a prefix go with it, and a prefix must end at a
    separator or at the end of the name, so `Foo` never strips `Food_`.
    """
    cores = sorted({text.strip("_ -") for text in prefixes}, key=len, reverse=True)
    if not cores:
        return None
    alternatives = "|".join(re.escape(core) for core in cores)
    return re.compile(rf"^{SEPARATOR}*(?:{alternatives})(?:{SEPARATOR}+|$)", re.IGNORECASE)


class BatchError(Exception):
    """An input or conversion could not be handled safely."""


def files_in(directory):
    return sorted(
        (p for p in directory.iterdir() if stat.S_ISREG(p.lstat().st_mode)),
        key=lambda p: p.name,
    )


def plan(directory, prefix):
    files = files_in(directory)
    occupied = {p.name.casefold(): p.name for p in directory.iterdir()}
    targets = {}
    renames = []
    names = []
    for source in files:
        name = prefix.sub("", source.name, count=1) if prefix else source.name
        if name != source.name:
            if not name or name.startswith("."):
                raise BatchError(f"Removing the prefix would leave an empty or hidden name: {source.name!r}")
            key = name.casefold()
            if key in targets or key in occupied:
                other = targets.get(key, occupied.get(key))
                raise BatchError(f"Rename collision: {source.name!r} -> {name!r}; conflicts with {other!r}")
            targets[key] = source.name
            renames.append((source, directory / name))
        names.append(name)
    epubs = {Path(name).stem.casefold() for name in names if Path(name).suffix.lower() == ".epub"}
    pdfs = [directory / name for name in names if Path(name).suffix.lower() == ".pdf"]
    pending = [pdf for pdf in pdfs if pdf.stem.casefold() not in epubs]
    return renames, pending, len(pdfs) - len(pending)


def rename_without_overwriting(source, destination):
    # Linux renameat2 makes the existence check and rename one atomic operation.
    libc = ctypes.CDLL(None, use_errno=True)
    try:
        rename = libc.renameat2
    except AttributeError as error:
        raise BatchError("This script requires Linux renameat2 for safe file publication") from error
    rename.argtypes = [ctypes.c_int, ctypes.c_char_p, ctypes.c_int, ctypes.c_char_p, ctypes.c_uint]
    rename.restype = ctypes.c_int
    if rename(-100, os.fsencode(source), -100, os.fsencode(destination), 1) != 0:
        number = ctypes.get_errno()
        if number == errno.EEXIST:
            raise BatchError(f"Destination already exists: {destination.name!r}")
        raise OSError(number, os.strerror(number))


def fingerprint(pdf):
    descriptor = os.open(pdf, os.O_RDONLY | os.O_NOFOLLOW)
    with os.fdopen(descriptor, "rb") as stream:
        before = os.fstat(stream.fileno())
        if not stat.S_ISREG(before.st_mode):
            raise BatchError(f"Input is not a regular file: {pdf.name!r}")
        digest = hashlib.file_digest(stream, "sha256").digest()
        after = os.fstat(stream.fileno())
    identity = lambda entry: (entry.st_dev, entry.st_ino, entry.st_size, entry.st_mtime_ns)
    if identity(before) != identity(after):
        raise BatchError(f"PDF changed while being read: {pdf.name!r}")
    return identity(after), digest


def has_epub(pdf):
    return any(
        p.suffix.lower() == ".epub" and p.stem.casefold() == pdf.stem.casefold()
        for p in files_in(pdf.parent)
    )


def validate_epub(path):
    with zipfile.ZipFile(path) as book:
        if book.testzip() is not None:
            raise BatchError("The converter produced an EPUB with a failed ZIP integrity check")
        if book.read("mimetype").strip() != b"application/epub+zip":
            raise BatchError("The converter did not produce an EPUB")
        container = ET.fromstring(book.read("META-INF/container.xml"))
        rootfile = container.find(".//{*}rootfile")
        if rootfile is None:
            raise BatchError("The EPUB has no package document")
        package = ET.fromstring(book.read(rootfile.attrib["full-path"]))
        manifest = {item.attrib["id"]: item.attrib for item in package.findall("./{*}manifest/{*}item")}
        spine = package.findall("./{*}spine/{*}itemref")
        if not spine:
            raise BatchError("The EPUB has an empty reading order")
        has_content = False
        for reference in spine:
            item = manifest[reference.attrib["idref"]]
            url = urlsplit(item["href"])
            resource = posixpath.normpath(posixpath.join(posixpath.dirname(rootfile.attrib["full-path"]), unquote(url.path)))
            if url.scheme or url.netloc or resource.startswith(("/", "../")):
                raise BatchError("The EPUB reading order refers outside the archive")
            content = ET.fromstring(book.read(resource))
            body = content.find(".//{*}body")
            if body is None:
                body = content
            has_content |= bool("".join(body.itertext()).strip()) or any(
                element.tag.rsplit("}", 1)[-1] in ("img", "image", "svg") for element in body.iter()
            )
        if not has_content:
            raise BatchError("The EPUB has no text or images")


def stop(process):
    if process.poll() is not None:
        return
    try:
        os.killpg(process.pid, signal.SIGTERM)
    except ProcessLookupError:
        return
    try:
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        try:
            os.killpg(process.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        process.wait()


def run_converter(fish, pdf, output, work, timeout):
    environment = os.environ.copy()
    environment.update(
        QT_QPA_PLATFORM="offscreen",
        QT_QPA_PLATFORMTHEME="",
        QT_STYLE_OVERRIDE="Fusion",
        CALIBRE_CONFIG_DIRECTORY=str(work / "calibre-config"),
        TMPDIR=str(work),
    )
    log = work / "conversion.log"
    started = time.monotonic()
    with log.open("wb") as stream:
        process = subprocess.Popen(
            [fish, "-c", "pdf2epub -- $argv", str(pdf), str(output)],
            stdout=stream,
            stderr=subprocess.STDOUT,
            env=environment,
            start_new_session=True,
        )
        try:
            while True:
                elapsed = time.monotonic() - started
                if timeout is not None and elapsed >= timeout:
                    raise BatchError(f"Conversion exceeded the {timeout}-second timeout")
                interval = 30 if timeout is None else min(30, timeout - elapsed)
                try:
                    code = process.wait(timeout=interval)
                    break
                except subprocess.TimeoutExpired:
                    if timeout is None or time.monotonic() - started < timeout:
                        print(f"[WORKING] {pdf.name!r}: {int(time.monotonic() - started)} seconds", flush=True)
        finally:
            stop(process)
    if code != 0:
        with log.open(errors="replace") as stream:
            tail = deque(stream, maxlen=12)
        for line in tail:
            print(f"    {line.rstrip()!r}", file=sys.stderr)
        raise BatchError(f"pdf2epub exited with status {code}")


def convert(fish, pdf, timeout):
    if has_epub(pdf):
        return False
    destination = pdf.with_suffix(".epub")
    if os.path.lexists(destination):
        raise BatchError(f"Output path is occupied: {destination.name!r}")
    before = fingerprint(pdf)
    # Publish only a complete, validated EPUB; failed conversions remain retryable.
    with tempfile.TemporaryDirectory(prefix=".prepare-ebooks-", dir=pdf.parent) as temporary:
        work = Path(temporary)
        output = work / destination.name
        try:
            run_converter(fish, pdf, output, work, timeout)
        finally:
            if fingerprint(pdf) != before:
                raise BatchError(f"Original PDF changed during conversion: {pdf.name!r}")
        if not stat.S_ISREG(output.lstat().st_mode):
            raise BatchError("The converter did not produce a regular EPUB file")
        validate_epub(output)
        if has_epub(pdf):
            return False
        rename_without_overwriting(output, destination)
    return True


def main():
    parser = argparse.ArgumentParser(
        prog="prepare-books",
        description=__doc__,
        epilog="Processes regular files directly in the directory; keeps every PDF and existing EPUB. Requires Python 3.11+, Linux, fish, Calibre and your pdf2epub fish function. Example: prepare-books --prefix OceanofPDF.com ~/Documents/Books/ToAdd",
    )
    parser.add_argument("directory", nargs="?", default=".", type=Path)
    parser.add_argument(
        "-p",
        "--prefix",
        action="append",
        default=[],
        metavar="TEXT",
        help="remove TEXT from the start of file names, ignoring case and any _, space or - around it; repeat for several prefixes; without it nothing is renamed",
    )
    parser.add_argument("--dry-run", action="store_true", help="show renames and conversions without changing files")
    parser.add_argument("--timeout", type=int, metavar="SECONDS", help="maximum time for each conversion; default: no limit")
    arguments = parser.parse_args()
    if arguments.timeout is not None and arguments.timeout <= 0:
        parser.error("--timeout must be a positive number of seconds")
    if any(not text.strip("_ -") for text in arguments.prefix):
        parser.error("--prefix needs text other than _, space and -")
    directory = arguments.directory.resolve(strict=True)
    if not directory.is_dir():
        raise BatchError("The directory argument must name a directory")
    renames, pending, skipped = plan(directory, prefix_pattern(arguments.prefix))
    if arguments.dry_run:
        for source, destination in renames:
            print(f"[WOULD RENAME] {source.name!r} -> {destination.name!r}")
        for pdf in pending:
            print(f"[WOULD CONVERT] {pdf.name!r} -> {pdf.with_suffix('.epub').name!r}")
        print(f"Dry run: {len(renames)} renames, {len(pending)} conversions, {skipped} PDFs already have EPUBs.")
        return 0
    fish = shutil.which("fish")
    if pending:
        if fish is None:
            raise BatchError("fish is not installed or is not on PATH")
        check = subprocess.run([fish, "-c", "type -q pdf2epub; and type -q ebook-convert"], capture_output=True)
        if check.returncode != 0:
            raise BatchError("fish must have both pdf2epub and ebook-convert available")
    for source, destination in renames:
        rename_without_overwriting(source, destination)
        print(f"[RENAMED] {source.name!r} -> {destination.name!r}", flush=True)
    converted = failed = 0
    for pdf in pending:
        print(f"[CONVERT] {pdf.name!r}", flush=True)
        try:
            if convert(fish, pdf, arguments.timeout):
                converted += 1
                print(f"[WROTE] {pdf.with_suffix('.epub').name!r}", flush=True)
            else:
                skipped += 1
                print(f"[SKIP] An EPUB already exists for {pdf.name!r}", flush=True)
        except (BatchError, OSError, zipfile.BadZipFile, KeyError, ET.ParseError) as error:
            failed += 1
            print(f"[ERROR] {pdf.name!r}: {str(error)!r}", file=sys.stderr, flush=True)
    print(f"Done: {len(renames)} renamed, {converted} converted, {skipped} skipped, {failed} failed.")
    return 1 if failed else 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print("\nInterrupted; original PDFs and existing EPUBs were retained.", file=sys.stderr)
        sys.exit(130)
    except (BatchError, OSError) as error:
        print(f"[ERROR] {str(error)!r}", file=sys.stderr)
        sys.exit(1)
