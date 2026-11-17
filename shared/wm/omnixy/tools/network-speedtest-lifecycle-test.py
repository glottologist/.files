#!/usr/bin/env python3
"""A cancelled speed test must leave no traffic workers behind."""

import os
from pathlib import Path
import signal
import subprocess
import tempfile
import time
import unittest

SCRIPT = Path(__file__).resolve().parent.parent / "desktop/bin/omnixy-network-speedtest"

CURL = r'''#!/usr/bin/env python3
import json
import os
from pathlib import Path
import sys
import time

if any("api.fast.com/" in arg for arg in sys.argv):
    print(json.dumps({"targets": [{"url": "https://example.invalid/speedtest"}]}))
else:
    with Path(os.environ["TEST_PIDS"]).open("a") as log:
        log.write(f"{os.getpid()} {os.getppid()}\n")
    time.sleep(0.2)
'''


def alive(pid):
    try:
        state = (Path("/proc") / str(pid) / "stat").read_text().rsplit(")", 1)[1].split()[0]
        return state not in ("Z", "X")
    except FileNotFoundError:
        return False


def recorded_pids(path):
    if not path.exists():
        return set(), set()
    rows = [line.split() for line in path.read_text().splitlines()]
    rows = [row for row in rows if len(row) == 2]
    return {int(row[0]) for row in rows}, {int(row[1]) for row in rows}


class WorkerLifetime(unittest.TestCase):
    def test_cancellation_stops_download_and_upload_workers(self):
        for direction in ("down", "up"):
            for sig in (signal.SIGTERM, signal.SIGKILL):
                with self.subTest(direction=direction, signal=sig.name):
                    self.check_cancellation(direction, sig)

    def check_cancellation(self, direction, sig):
        with tempfile.TemporaryDirectory(prefix="network-speedtest-test-") as tmp:
            root = Path(tmp)
            mocks = {
                "ip": "#!/bin/sh\necho '1.1.1.1 dev lo src 127.0.0.1'\n",
                "omnixy-cmd-present": "#!/bin/sh\nexit 0\n",
                "curl": CURL,
            }
            for name, content in mocks.items():
                path = root / name
                path.write_text(content)
                path.chmod(0o755)
            log = root / "pids"
            env = dict(os.environ, PATH=f"{root}:{os.environ['PATH']}", TEST_PIDS=str(log))
            process = subprocess.Popen(
                ["bash", str(SCRIPT), direction], env=env,
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                start_new_session=True,
            )
            try:
                deadline = time.monotonic() + 5
                while time.monotonic() < deadline:
                    _, workers = recorded_pids(log)
                    if len(workers) == 8:
                        break
                    time.sleep(0.02)
                self.assertEqual(len(workers), 8, "traffic workers did not start")
                process.send_signal(sig)
                process.wait(timeout=3)
                deadline = time.monotonic() + 2
                remaining = set()
                while time.monotonic() < deadline:
                    requests, workers = recorded_pids(log)
                    remaining = {pid for pid in requests | workers if alive(pid)}
                    if not remaining:
                        break
                    time.sleep(0.02)
                self.assertFalse(remaining, f"traffic survives {sig.name}: {remaining}")
            finally:
                try:
                    os.killpg(process.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
                process.wait(timeout=3)


if __name__ == "__main__":
    unittest.main()
