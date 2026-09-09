#!/usr/bin/env bash
# Speedtest history helpers in the network Model.js.
set -uo pipefail
model="$(cd "$(dirname "$0")" && pwd)/../desktop/shell/plugins/panels/network/Model.js"
fail() { echo "FAIL $1"; exit 1; }
[ -f "$model" ] || fail "Model.js missing"

# The clock helper reads local time, so the test fixes the zone.
TZ=UTC node --input-type=commonjs - "$model" <<'EOF'
const assert = require("assert")
const Model = require(process.argv[2])

// epoch, down, up, ping, jitter, loss, server -- as the recorder prints it.
const raw = [
  "1788966372\t94.23\t18.14\t12.4\t1.2\t0\tTruespeed Communications, Colchester",
  "1788965472\t8.4\t2.1\t121.548\t66.066\t\tBT, London",
  "1788964572\t38.4\t17.2\t31\t4\t2.5\t",
  "",
  "torn line"
].join("\n")

const history = Model.parseSpeedTestHistory(raw)
assert.strictEqual(history.length, 3, "blank and torn lines are dropped")

assert.deepStrictEqual(history[0], {
  time: 1788966372,
  down: 94.23,
  up: 18.14,
  ping: 12.4,
  jitter: 1.2,
  loss: 0,
  server: "Truespeed Communications, Colchester"
})

// An unmeasured packet loss is -1, not 0: the run never established one.
assert.strictEqual(history[1].loss, -1)
assert.strictEqual(history[2].server, "")

assert.deepStrictEqual(Model.parseSpeedTestHistory(null), [])
assert.deepStrictEqual(Model.parseSpeedTestHistory("1788966372\t\t\t"), [])
assert.deepStrictEqual(Model.parseSpeedTestHistory("0\t94\t18"), [])

assert.strictEqual(Model.latestSpeedTest(history).down, 94.23)
assert.strictEqual(Model.latestSpeedTest([]), null)
assert.strictEqual(Model.latestSpeedTest(null), null)

assert.deepStrictEqual(Model.speedTestHistoryRows(history, 4).map(r => r.down), [8.4, 38.4])
assert.deepStrictEqual(Model.speedTestHistoryRows(history, 1).map(r => r.down), [8.4])
assert.deepStrictEqual(Model.speedTestHistoryRows(history, 0), [])
assert.deepStrictEqual(Model.speedTestHistoryRows([], 4), [])

assert.strictEqual(Model.formatSpeedTestMbps(94.23), "94")
assert.strictEqual(Model.formatSpeedTestMbps(8.44), "8.4")
assert.strictEqual(Model.formatSpeedTestMbps(-1), "--")
assert.strictEqual(Model.formatSpeedTestMbps(undefined), "--")

assert.strictEqual(Model.formatSpeedTestPing(12.44), "12 ms")
assert.strictEqual(Model.formatSpeedTestPing(8.44), "8.4 ms")
assert.strictEqual(Model.formatSpeedTestPing(-1), "--")

assert.strictEqual(Model.formatSpeedTestLoss(0), "0%")
assert.strictEqual(Model.formatSpeedTestLoss(2.5), "3%")
assert.strictEqual(Model.formatSpeedTestLoss(-1), "--")

const now = 1788966372 * 1000
assert.strictEqual(Model.formatSpeedTestAge(1788966372, now), "JUST NOW")
assert.strictEqual(Model.formatSpeedTestAge(1788966372, now + 15 * 60 * 1000), "15M AGO")
assert.strictEqual(Model.formatSpeedTestAge(1788966372, now + 2 * 3600 * 1000), "2H AGO")
assert.strictEqual(Model.formatSpeedTestAge(1788966372, now + 3 * 86400 * 1000), "3D AGO")
assert.strictEqual(Model.formatSpeedTestAge(0, now), "")
assert.strictEqual(Model.formatSpeedTestAge(1788966372, NaN), "")

assert.strictEqual(Model.formatSpeedTestClock(1788966372), "15:06")
assert.strictEqual(Model.formatSpeedTestClock(1788923400), "03:10")
assert.strictEqual(Model.formatSpeedTestClock(0), "")
EOF

[ $? -eq 0 ] || fail "network speedtest model assertions"
echo "PASS network speedtest model"
