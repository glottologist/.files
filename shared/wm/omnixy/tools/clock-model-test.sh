#!/usr/bin/env bash
# World-clock and calendar helpers in the clock Model.js.
set -uo pipefail
model="$(cd "$(dirname "$0")" && pwd)/../desktop/shell/plugins/panels/clock/Model.js"
fail() { echo "FAIL $1"; exit 1; }
[ -f "$model" ] || fail "Model.js missing"

node --input-type=commonjs - "$model" <<'EOF'
const assert = require("assert")
const Model = require(process.argv[2])
const epoch = Date.parse("2026-09-08T13:07:00Z")
const nextDay = Date.parse("2026-09-08T16:00:00Z")

assert.deepStrictEqual(Model.parseTimeZones(null), [])
assert.deepStrictEqual(Model.parseTimeZones("America/New_York"), ["America/New_York"])
assert.deepStrictEqual(
  Model.parseTimeZones(["America/New_York", "nope", "America/New_York", "Asia/Tokyo"]),
  ["America/New_York", "Asia/Tokyo"]
)
assert.strictEqual(Model.parseTimeZones(new Array(12).fill("UTC").map((_, i) => "UTC")).length, 1)
assert.strictEqual(
  Model.parseTimeZones([
    "Pacific/Honolulu", "America/Los_Angeles", "America/Denver", "America/Chicago",
    "America/New_York", "Europe/London", "Asia/Tokyo", "Australia/Sydney", "Pacific/Auckland"
  ]).length,
  Model.MAX_WORLD_CLOCKS
)

assert.deepStrictEqual(Model.addTimeZone([], "Asia/Tokyo"), ["Asia/Tokyo"])
assert.deepStrictEqual(Model.addTimeZone(["Asia/Tokyo"], "Asia/Tokyo"), ["Asia/Tokyo"])
assert.deepStrictEqual(Model.addTimeZone(["Asia/Tokyo"], "not a zone"), ["Asia/Tokyo"])
assert.deepStrictEqual(Model.removeTimeZone(["Asia/Tokyo", "Europe/London"], "Asia/Tokyo"), ["Europe/London"])

assert.strictEqual(Model.timeZoneLabel("America/New_York"), "New York")
assert.strictEqual(Model.timeZoneLabel("Pacific/Port_Moresby"), "Port Moresby")
assert.strictEqual(Model.usesHour12("dddd HH:mm"), false)
assert.strictEqual(Model.usesHour12("h:mm AP"), true)

assert.strictEqual(Model.formatTimeInZone(epoch, "America/New_York", false), "09:07")
assert.strictEqual(Model.formatTimeInZone(epoch, "Asia/Tokyo", false), "22:07")
assert.strictEqual(Model.zoneDayOffset(nextDay, "Asia/Tokyo", "Europe/London"), 1)
assert.strictEqual(Model.zoneDayOffset(nextDay, "America/New_York", "Europe/London"), 0)

const rows = Model.worldClockRows(["America/New_York", "Asia/Tokyo"], nextDay, { localTimeZone: "Europe/London" })
assert.strictEqual(rows[0].label, "New York")
assert.strictEqual(rows[1].dayOffset, 1)
assert.strictEqual(rows[1].dayOffsetLabel, "+1")

const popular = Model.matchingTimeZones("", ["America/New_York"])
assert.ok(popular.every((z) => z.id !== "America/New_York"))
assert.ok(popular.some((z) => z.id === "Europe/London"))
assert.ok(popular.length <= 6)
const tokyo = Model.matchingTimeZones("tokyo", [])
assert.strictEqual(tokyo[0].id, "Asia/Tokyo")
assert.ok(Model.isTimeZoneId("America/Argentina/Buenos_Aires"))
assert.ok(!Model.isTimeZoneId("../etc/passwd"))

console.log("PASS")
EOF
