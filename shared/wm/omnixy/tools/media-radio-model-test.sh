#!/usr/bin/env bash
# The media-radio panel's Model.js helpers.
set -uo pipefail
model="$(cd "$(dirname "$0")" && pwd)/../desktop/shell/plugins/panels/media-radio/Model.js"
fail() { echo "FAIL $1"; exit 1; }
[ -f "$model" ] || fail "Model.js missing"

node --input-type=commonjs - "$model" <<'EOF'
const assert = require("assert")
const Model = require(process.argv[2])

// --- Commands -------------------------------------------------------------

// The probe must ask the bus broker, never the Goodvibes name itself: calling
// the name would activate it, and activation starts the GTK window.
const probe = Model.probeCommand()
assert.strictEqual(probe[4], "org.freedesktop.DBus")
assert.strictEqual(probe[probe.length - 2], "s")
assert.strictEqual(probe[probe.length - 1], "io.gitlab.Goodvibes")
assert.ok(probe.indexOf("NameHasOwner") !== -1)
assert.ok(probe.indexOf("--json=short") !== -1)

assert.deepStrictEqual(Model.listCommand().slice(-2), ["io.gitlab.Goodvibes.Stations", "List"])
assert.deepStrictEqual(Model.playCommand("FIP Jazz").slice(-3), ["Play", "s", "FIP Jazz"])
assert.deepStrictEqual(Model.playCommand(null).slice(-1), [""])
assert.deepStrictEqual(Model.stopCommand().slice(-1), ["Stop"])
assert.deepStrictEqual(Model.addCommand("https://x/y", "Y").slice(-6), ["Add", "ssss", "https://x/y", "Y", "", ""])
assert.deepStrictEqual(Model.removeCommand("Y").slice(-3), ["Remove", "s", "Y"])
assert.deepStrictEqual(Model.startDaemonCommand(), ["systemctl", "--user", "start", "omnixy-radio.service"])
assert.deepStrictEqual(Model.stopDaemonCommand(), ["systemctl", "--user", "stop", "omnixy-radio.service"])

const search = Model.searchCommand("BBC nan Gàidheal")
assert.strictEqual(search[0], "curl")
assert.match(search[search.length - 1], /name=BBC%20nan%20G%C3%A0idheal$/)
assert.match(Model.searchUrl("  jazz  "), /name=jazz$/, "the query is trimmed before it is sent")

// --- Replies --------------------------------------------------------------

// busctl wraps a method's return values in an array and every value in a
// {type, data} pair.
assert.strictEqual(Model.parseRunning('{"type":"b","data":[true]}'), true)
assert.strictEqual(Model.parseRunning('{"type":"b","data":[false]}'), false)
assert.strictEqual(Model.parseRunning(""), false)
assert.strictEqual(Model.parseRunning("not json"), false)

const listReply = JSON.stringify({
  type: "aa{sv}",
  data: [[
    { uri: { type: "s", data: "https://somafm.com/groovesalad130.pls" }, name: { type: "s", data: "SomaFM Groove Salad" } },
    { uri: { type: "s", data: "https://stream.radiofrance.fr/fipjazz/fipjazz.m3u8" }, name: { type: "s", data: "FIP Jazz" } },
    { uri: { type: "s", data: "https://example.invalid/unnamed" } },
    { name: { type: "s", data: "no uri" } }
  ]]
})
const stations = Model.parseStations(listReply)
assert.strictEqual(stations.length, 3, "a station without a uri is dropped")
assert.deepStrictEqual(stations[0], { name: "SomaFM Groove Salad", uri: "https://somafm.com/groovesalad130.pls" })
assert.strictEqual(stations[2].name, "https://example.invalid/unnamed", "a nameless station falls back to its uri")
assert.deepStrictEqual(Model.parseStations("{}"), [])
assert.deepStrictEqual(Model.parseStations(""), [])

const searchReply = JSON.stringify([
  { name: " BBC Radio nan Gàidheal ", url: "http://a/1", url_resolved: "http://a/resolved", country: "Scotland", codec: "MP3", bitrate: 128 },
  { name: "Duplicate", url_resolved: "http://a/resolved" },
  { name: "No codec", url_resolved: "http://b/2", country: "Ireland", codec: "UNKNOWN", bitrate: 0 },
  { name: "", url_resolved: "http://c/3" },
  { name: "No url", url_resolved: "" }
])
const results = Model.parseSearch(searchReply)
assert.strictEqual(results.length, 2, "duplicates, nameless and url-less rows are dropped")
assert.strictEqual(results[0].name, "BBC Radio nan Gàidheal")
assert.strictEqual(results[0].uri, "http://a/resolved", "url_resolved wins over url")
assert.strictEqual(results[0].meta, "Scotland · MP3 128k")
assert.strictEqual(results[1].meta, "Ireland", "an unknown codec and a zero bitrate are left out")
assert.deepStrictEqual(Model.parseSearch("nonsense"), [])

assert.strictEqual(Model.errorText("Call failed: 'x' is neither a known station or a valid uri\ntrailing", "fallback"),
  "'x' is neither a known station or a valid uri")
assert.strictEqual(Model.errorText("   ", "fallback"), "fallback")
assert.strictEqual(Model.errorText("", ""), "")

// --- Derived views --------------------------------------------------------

assert.strictEqual(Model.hasStation(stations, "HTTPS://SomaFM.com/groovesalad130.pls"), true)
assert.strictEqual(Model.hasStation(stations, "http://nowhere"), false)
assert.strictEqual(Model.hasStation(stations, ""), false)

assert.deepStrictEqual(Model.filterStations(stations, "jazz").map(s => s.name), ["FIP Jazz"])
assert.deepStrictEqual(Model.filterStations(stations, "somafm.com").map(s => s.name), ["SomaFM Groove Salad"],
  "the uri is searched as well as the name")
assert.strictEqual(Model.filterStations(stations, "  ").length, 3)

assert.strictEqual(Model.isPlayingStation(stations[1], "fip jazz"), true)
assert.strictEqual(Model.isPlayingStation(stations[1], ""), false)
assert.strictEqual(Model.isPlayingStation(null, "FIP Jazz"), false)

const base = { running: true, stations: stations, results: [], query: "", mode: "library", playingStation: "FIP Jazz" }

const libraryRows = Model.panelRows(base)
assert.deepStrictEqual(libraryRows.map(r => r.kind), ["section", "station", "station", "station"])
assert.strictEqual(libraryRows[0].title, "STATIONS")
assert.strictEqual(libraryRows[0].count, 3)
assert.strictEqual(libraryRows[2].playing, true, "the playing station is marked by name")
assert.strictEqual(libraryRows[1].playing, false)

const filtered = Model.panelRows(Object.assign({}, base, { query: "jazz" }))
assert.deepStrictEqual(filtered.map(r => r.kind), ["section", "station", "search"])
assert.match(filtered[2].text, /radio browser/)

const noMatch = Model.panelRows(Object.assign({}, base, { query: "zzz" }))
assert.deepStrictEqual(noMatch.map(r => r.kind), ["section", "empty", "search"])

// Nothing can be listed until Goodvibes is up, so the library section offers
// to start it instead of pretending to be empty.
const stopped = Model.panelRows({ running: false, stations: [], query: "" })
assert.deepStrictEqual(stopped.map(r => r.kind), ["section", "start"])
assert.strictEqual(stopped[1].text, "Start the radio player")
assert.strictEqual(Model.panelRows({ running: false, starting: true, stations: [] })[1].text, "Starting the radio player…")
assert.strictEqual(Model.panelRows({ running: true, stations: [], listError: "boom" })[1].kind, "empty")
assert.strictEqual(Model.panelRows({ running: true, stations: [] })[1].text, "No stations yet.")

const resultRows = Model.panelRows(Object.assign({}, base, {
  mode: "results", query: "radio",
  results: [{ name: "Known", uri: "https://somafm.com/groovesalad130.pls" }, { name: "New", uri: "http://new" }]
}))
assert.deepStrictEqual(resultRows.map(r => r.kind), ["section", "result", "result"])
assert.strictEqual(resultRows[0].title, "SEARCH RESULTS")
assert.strictEqual(resultRows[1].known, true, "a result already in the library is marked")
assert.strictEqual(resultRows[2].known, false)
assert.strictEqual(Model.panelRows({ mode: "results", searching: true })[1].text, "Searching the radio browser…")
assert.strictEqual(Model.panelRows({ mode: "results", searchError: "no answer" })[1].text, "no answer")
assert.match(Model.panelRows({ mode: "results", results: [] })[1].text, /knows nothing/)

// --- Cursor ---------------------------------------------------------------

assert.deepStrictEqual(Model.cursorRowIndexes(filtered), [1, 2])
assert.strictEqual(Model.stepCursor(filtered, -1, 1), 1, "no cursor steps onto the first stop going down")
assert.strictEqual(Model.stepCursor(filtered, -1, -1), 2, "no cursor steps onto the last stop going up")
assert.strictEqual(Model.stepCursor(filtered, 1, 1), 2)
assert.strictEqual(Model.stepCursor(filtered, 2, 1), 2, "the cursor stops at the end")
assert.strictEqual(Model.stepCursor(filtered, 1, -1), 1, "the cursor stops at the start")
assert.strictEqual(Model.stepCursor(filtered, 1, 0), 1, "no movement leaves the cursor alone")
assert.strictEqual(Model.stepCursor([{ kind: "section" }], -1, 1), -1, "a list with no stops has no cursor")
assert.strictEqual(Model.isCursorRow({ kind: "section" }), false)
assert.strictEqual(Model.isCursorRow({ kind: "empty" }), false)
assert.strictEqual(Model.isCursorRow({ kind: "start" }), true)

// --- Labels ---------------------------------------------------------------

assert.strictEqual(Model.truncate("abcdefghij", 5), "abcd…")
assert.strictEqual(Model.truncate("abc", 5), "abc")
assert.strictEqual(Model.truncate("abc", 0), "abc", "a zero width means no limit")
assert.strictEqual(Model.barLabel("R", "Song", "Artist", 10), "R  Song")
assert.strictEqual(Model.barLabel("R", "", "Artist", 10), "R  Artist", "the artist stands in for a missing title")
assert.strictEqual(Model.barLabel("R", "", "", 10), "R")
assert.strictEqual(Model.barTooltip("Song", "Artist", "Spotify"), "Song — Artist (Spotify)")
assert.strictEqual(Model.barTooltip("", "", ""), "Nothing playing")
assert.strictEqual(Model.barTooltip("", "", "Spotify"), "Spotify")
assert.strictEqual(Model.heroMeta("Artist", "Album"), "Artist · Album")
assert.strictEqual(Model.heroMeta("", ""), "")
assert.strictEqual(Model.hostOf("https://somafm.com/groovesalad130.pls"), "somafm.com")
assert.strictEqual(Model.hostOf("not a url"), "not a url")
assert.strictEqual(Model.stationMeta(stations[1], true), "Playing")
assert.strictEqual(Model.stationMeta(stations[1], false), "stream.radiofrance.fr")
assert.strictEqual(Model.suggestedName({ name: "  X  " }), "X")
EOF

[ $? -eq 0 ] || fail "media-radio model assertions"
echo "PASS media-radio model"
