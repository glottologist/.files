#!/usr/bin/env python3
"""Rebuild PDF text in reading order so two-column pages are not mashed.

Calibre's PDF engine reads across the page, so a left-column line is joined
to the right-column line at the same height. Poppler's bbox-layout output
keeps word boxes; this script groups them into columns and emits HTML that
ebook-convert can turn into an EPUB.

A page is two-column when substantial blocks cluster on both sides of a
wide interior gutter. Article columns are read top-to-bottom, left then
right. Aligned IF/THEN-style rows are read left-to-right across each row.
Full-width titles stay in place and split those bands.

Exit status: 0 wrote HTML, 2 no two-column page (caller should use Calibre),
1 error.
"""

from __future__ import annotations

import argparse
import html
import re
import subprocess
import sys
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path
from statistics import median


COLUMN_WIDTH_MIN = 0.18
COLUMN_WIDTH_MAX = 0.52
GUTTER_MIN_FRACTION = 0.12
MIN_COLUMN_BLOCKS = 2
MIN_COLUMN_CHARS = 80
MIN_COLUMN_MEDIAN = 25
FOOTER_Y_FRACTION = 0.88
GUTTER_SPAN_SLACK = 10.0
ROW_Y0_SLACK = 20.0
TABLE_Y0_SLACK = 8.0
TABLE_ALIGN_FRACTION = 0.8
DOCTYPE = re.compile(r"<!DOCTYPE[^>]*>", re.IGNORECASE)
# XML 1.0 forbids C0 controls other than tab/LF/CR. pdftotext copies them
# out of PDF text (music notation, etc.) into <word> elements.
ILLEGAL_XML_CHARS = re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f]")


@dataclass(frozen=True)
class Block:
    x0: float
    y0: float
    x1: float
    y1: float
    lines: tuple[str, ...]

    @property
    def width(self) -> float:
        return self.x1 - self.x0

    @property
    def height(self) -> float:
        return self.y1 - self.y0

    @property
    def mid_x(self) -> float:
        return (self.x0 + self.x1) / 2

    @property
    def text(self) -> str:
        return join_lines(self.lines)


@dataclass(frozen=True)
class Page:
    width: float
    height: float
    blocks: tuple[Block, ...]


def join_lines(lines: tuple[str, ...] | list[str]) -> str:
    parts: list[str] = []
    for raw in lines:
        line = " ".join(raw.split())
        if not line:
            continue
        if parts and re.search(r"\S(?:-|\u00ad)$", parts[-1]) and line[:1].isalpha():
            parts[-1] = parts[-1].rstrip("-\u00ad") + line
        else:
            if parts:
                parts.append(" ")
            parts.append(line)
    return "".join(parts)


def parse_bbox_layout(document: str) -> list[Page]:
    stripped = ILLEGAL_XML_CHARS.sub("", DOCTYPE.sub("", document, count=1)).strip()
    if not stripped:
        return []
    root = ET.fromstring(stripped)
    pages: list[Page] = []
    for page_el in root.findall(".//{*}page"):
        blocks: list[Block] = []
        for block_el in page_el.findall(".//{*}block"):
            lines: list[str] = []
            for line_el in block_el.findall("{*}line"):
                words = [(word.text or "") for word in line_el.findall("{*}word")]
                line = " ".join(word for word in words if word)
                if line:
                    lines.append(line)
            if not lines:
                continue
            blocks.append(
                Block(
                    x0=float(block_el.attrib["xMin"]),
                    y0=float(block_el.attrib["yMin"]),
                    x1=float(block_el.attrib["xMax"]),
                    y1=float(block_el.attrib["yMax"]),
                    lines=tuple(lines),
                )
            )
        pages.append(
            Page(
                width=float(page_el.attrib["width"]),
                height=float(page_el.attrib["height"]),
                blocks=tuple(blocks),
            )
        )
    return pages


def is_page_number(block: Block, page: Page) -> bool:
    text = block.text.strip()
    return bool(text.isdigit() and len(text) <= 4 and block.y0 >= FOOTER_Y_FRACTION * page.height)


def column_cut(page: Page) -> float | None:
    body = [
        block
        for block in page.blocks
        if block.y0 < 0.9 * page.height and block.width > 0.05 * page.width
    ]
    columnish = [
        block
        for block in body
        if COLUMN_WIDTH_MIN * page.width < block.width < COLUMN_WIDTH_MAX * page.width
        and len(block.text) > 20
    ]
    if len(columnish) < 4:
        return None
    mids = sorted(block.mid_x for block in columnish)
    gap, cut = max(
        ((mids[index + 1] - mids[index], (mids[index] + mids[index + 1]) / 2) for index in range(len(mids) - 1)),
        default=(0.0, 0.0),
    )
    if gap < GUTTER_MIN_FRACTION * page.width:
        return None
    left = [block for block in columnish if block.mid_x < cut]
    right = [block for block in columnish if block.mid_x >= cut]
    if len(left) < MIN_COLUMN_BLOCKS or len(right) < MIN_COLUMN_BLOCKS:
        return None
    if not _substantial(left) or not _substantial(right):
        return None
    return cut


def _substantial(group: list[Block]) -> bool:
    lengths = [len(block.text) for block in group]
    return sum(lengths) >= MIN_COLUMN_CHARS and median(lengths) >= MIN_COLUMN_MEDIAN


def document_has_columns(pages: list[Page]) -> bool:
    return any(column_cut(page) is not None for page in pages)


def reading_order(page: Page) -> list[Block]:
    kept = [block for block in page.blocks if not is_page_number(block, page)]
    cut = column_cut(page)
    if cut is None:
        return sorted(kept, key=lambda block: (block.y0, block.x0))
    full: list[Block] = []
    left: list[Block] = []
    right: list[Block] = []
    for block in kept:
        if block.x0 < cut - GUTTER_SPAN_SLACK and block.x1 > cut + GUTTER_SPAN_SLACK:
            full.append(block)
        elif block.mid_x < cut:
            left.append(block)
        else:
            right.append(block)
    ordered: list[Block] = []
    previous_bottom = -1.0
    columns = left + right
    for banner in sorted(full, key=lambda block: block.y0):
        band = [block for block in columns if previous_bottom <= block.y0 < banner.y0]
        ordered.extend(_emit_column_band(band, cut, page))
        ordered.append(banner)
        previous_bottom = banner.y1
    tail = [block for block in columns if block.y0 >= previous_bottom]
    ordered.extend(_emit_column_band(tail, cut, page))
    return ordered


def _emit_column_band(band: list[Block], cut: float, page: Page) -> list[Block]:
    left = sorted((block for block in band if block.mid_x < cut), key=lambda block: block.y0)
    right = sorted((block for block in band if block.mid_x >= cut), key=lambda block: block.y0)
    if _is_table(left, right, page):
        return _pair_rows(left, right)
    return left + right


def _y_overlap(left: Block, right: Block) -> float:
    return max(0.0, min(left.y1, right.y1) - max(left.y0, right.y0))


def _cells(group: list[Block], page: Page) -> list[Block]:
    return [
        block
        for block in group
        if COLUMN_WIDTH_MIN * page.width < block.width < COLUMN_WIDTH_MAX * page.width
        and len(block.text) > 20
    ]


def _is_table(left: list[Block], right: list[Block], page: Page) -> bool:
    cells_left = _cells(left, page)
    cells_right = _cells(right, page)
    if len(cells_left) < 3 or len(cells_right) < 3:
        return False
    if abs(len(cells_left) - len(cells_right)) > 1:
        return False
    aligned = sum(
        1
        for block in cells_left
        if any(abs(block.y0 - other.y0) <= TABLE_Y0_SLACK for other in cells_right)
    )
    return aligned / len(cells_left) >= TABLE_ALIGN_FRACTION


def _pair_rows(left: list[Block], right: list[Block]) -> list[Block]:
    index = other = 0
    ordered: list[Block] = []
    while index < len(left) or other < len(right):
        if index == len(left):
            ordered.extend(right[other:])
            break
        if other == len(right):
            ordered.extend(left[index:])
            break
        this, that = left[index], right[other]
        overlap = _y_overlap(this, that)
        if abs(this.y0 - that.y0) <= ROW_Y0_SLACK or overlap > 0.3 * min(this.height, that.height):
            ordered.append(this)
            ordered.append(that)
            index += 1
            other += 1
        elif this.y0 < that.y0:
            ordered.append(this)
            index += 1
        else:
            ordered.append(that)
            other += 1
    return ordered


def pages_to_html(pages: list[Page], title: str) -> str:
    parts = [
        "<!DOCTYPE html>",
        '<html lang="en">',
        "<head>",
        '<meta charset="utf-8"/>',
        f"<title>{html.escape(title, quote=True)}</title>",
        "</head>",
        "<body>",
    ]
    for page in pages:
        for block in reading_order(page):
            text = block.text.strip()
            if text:
                parts.append(f"<p>{html.escape(text)}</p>")
    parts.extend(["</body>", "</html>", ""])
    return "\n".join(parts)


def bbox_layout_from_pdf(pdf: Path) -> str:
    result = subprocess.run(
        ["pdftotext", "-bbox-layout", str(pdf), "-"],
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        err = result.stderr.decode("utf-8", "replace").strip() or f"pdftotext exited {result.returncode}"
        raise RuntimeError(err)
    return result.stdout.decode("utf-8", "replace")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pdf", type=Path, help="input PDF")
    parser.add_argument("html", nargs="?", type=Path, help="output HTML; omit with --check")
    parser.add_argument("--check", action="store_true", help="exit 0 if two-column, 2 otherwise; write nothing")
    arguments = parser.parse_args(argv)
    pdf = arguments.pdf.expanduser()
    if not pdf.is_file():
        print(f"[ERROR] Not a file: {pdf}", file=sys.stderr)
        return 1
    try:
        pages = parse_bbox_layout(bbox_layout_from_pdf(pdf))
    except FileNotFoundError:
        print("[ERROR] pdftotext is not installed", file=sys.stderr)
        return 1
    except RuntimeError as error:
        print(f"[ERROR] {error}", file=sys.stderr)
        return 1
    has_columns = document_has_columns(pages)
    if arguments.check:
        return 0 if has_columns else 2
    if arguments.html is None:
        parser.error("HTML output path is required unless --check is set")
    if not has_columns:
        return 2
    arguments.html.write_text(pages_to_html(pages, pdf.stem), encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
