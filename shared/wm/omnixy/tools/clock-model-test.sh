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

assert.deepStrictEqual(Model.zoneOffsetCommand([]), [])
const command = Model.zoneOffsetCommand(["America/New_York", "Asia/Tokyo"])
assert.strictEqual(command[0], "bash")
assert.deepStrictEqual(command.slice(3), ["bash", "America/New_York", "Asia/Tokyo"])
assert.deepStrictEqual(
  Model.parseZoneOffsets("America/New_York -0400\nAsia/Tokyo +0900\nAsia/Kathmandu +0545\nnope +0100\nUTC junk\n"),
  { "America/New_York": -240, "Asia/Tokyo": 540, "Asia/Kathmandu": 345 }
)

assert.strictEqual(Model.formatTimeAtOffset(epoch, -240, false), "09:07")
assert.strictEqual(Model.formatTimeAtOffset(epoch, 540, false), "22:07")
assert.strictEqual(Model.formatTimeAtOffset(epoch, 540, true), "10:07 PM")
assert.strictEqual(Model.formatTimeAtOffset(epoch, -780, true), "12:07 AM")
assert.strictEqual(Model.formatTimeAtOffset(epoch, null, false), "")
assert.strictEqual(Model.offsetLabel(0), "GMT")
assert.strictEqual(Model.offsetLabel(-240), "GMT-4")
assert.strictEqual(Model.offsetLabel(345), "GMT+5:45")
assert.strictEqual(Model.offsetLabel(null), "")
assert.strictEqual(Model.zoneDayOffset(nextDay, 540, 60), 1)
assert.strictEqual(Model.zoneDayOffset(nextDay, -240, 60), 0)
assert.strictEqual(Model.zoneDayOffset(nextDay, null, 60), 0)

const offsets = { "America/New_York": -240, "Asia/Tokyo": 540 }
const rows = Model.worldClockRows(["America/New_York", "Asia/Tokyo"], nextDay, { offsets, localOffsetMinutes: 60 })
assert.strictEqual(rows[0].label, "New York")
assert.strictEqual(rows[0].time, "12:00")
assert.strictEqual(rows[0].offset, "GMT-4")
assert.strictEqual(rows[1].dayOffset, 1)
assert.strictEqual(rows[1].dayOffsetLabel, "+1")
assert.strictEqual(Model.worldClockRows(["Asia/Tokyo"], nextDay, {})[0].time, "\u2014")

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
