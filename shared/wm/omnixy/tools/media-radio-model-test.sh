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

// --- Sources --------------------------------------------------------------

assert.deepStrictEqual(Model.SOURCES, ["radio", "spotify", "plex"])
assert.strictEqual(Model.stepSource("radio", 1), "spotify")
assert.strictEqual(Model.stepSource("plex", 1), "radio", "the sources wrap round")
assert.strictEqual(Model.stepSource("radio", -1), "plex")
assert.strictEqual(Model.stepSource("nonsense", 1), "spotify", "an unknown source starts from the first")
assert.strictEqual(Model.sourceLabel("plex"), "Plex")
assert.strictEqual(Model.powerTooltip("spotify", true), "Stop the Spotify player")
assert.strictEqual(Model.powerTooltip("radio", false), "Start the radio player")

assert.deepStrictEqual(Model.startUnitCommand("x.service"), ["systemctl", "--user", "start", "x.service"])
assert.deepStrictEqual(Model.stopUnitCommand("x.service"), ["systemctl", "--user", "stop", "x.service"])
const namePresent = Model.namePresentCommand(Model.SPOTIFY_MPRIS)
assert.strictEqual(namePresent[4], "org.freedesktop.DBus", "readiness is asked of the broker, not of the player")
assert.strictEqual(namePresent[namePresent.length - 1], "org.mpris.MediaPlayer2.spotify_player")

// --- Spotify --------------------------------------------------------------

assert.deepStrictEqual(Model.spotifySearchCommand("  boards of canada  "),
  ["spotify_player", "search", "boards of canada"])
assert.deepStrictEqual(Model.spotifyTrackCommand("4uLU6hMCjMI75M1A2tKUQC").slice(-4),
  ["start", "track", "--id", "4uLU6hMCjMI75M1A2tKUQC"])
assert.deepStrictEqual(Model.spotifyContextCommand("album", "1A2GTWGtFfWp7KSQTwWOyo").slice(-4),
  ["context", "album", "--id", "1A2GTWGtFfWp7KSQTwWOyo"])
assert.deepStrictEqual(Model.spotifyLikedCommand().slice(-1), ["liked"])

const spotifyReply = JSON.stringify({
  tracks: [
    { id: "t1", name: "Roygbiv", artists: [{ id: "a1", name: "Boards of Canada" }], album: { id: "b1", name: "Music Has the Right to Children" } },
    { id: "t2", name: "Olson", artists: [], album: null },
    { name: "no id" }
  ],
  albums: [{ id: "b1", name: "Geogaddi", artists: [{ id: "a1", name: "Boards of Canada" }], release_date: "2002-02-18" }],
  playlists: [{ id: "p1", name: "Evening", owner: ["Jason", "u1"] }],
  artists: [{ id: "a1", name: "Boards of Canada" }],
  shows: [],
  episodes: []
})
const spotify = Model.parseSpotifySearch(spotifyReply)
assert.strictEqual(spotify.tracks.length, 2, "a track without an id is dropped")
assert.strictEqual(spotify.tracks[0].meta, "Boards of Canada · Music Has the Right to Children")
assert.strictEqual(spotify.tracks[1].meta, "", "a track with neither artist nor album has no second line")
assert.strictEqual(spotify.albums[0].meta, "Boards of Canada · 2002", "the release date shows as a year")
assert.strictEqual(spotify.playlists[0].meta, "by Jason")
assert.strictEqual(Model.spotifyResultCount(spotify), 5)
assert.strictEqual(Model.spotifyResultCount(Model.parseSpotifySearch("not json")), 0)

// --- Plex -----------------------------------------------------------------

assert.deepStrictEqual(Model.parsePlexConfig('{"server":"http://corvus.hs:32400","token":"abc"}'),
  { server: "http://corvus.hs:32400", token: "abc" })
assert.deepStrictEqual(Model.parsePlexConfig(""), { server: "", token: "" })

const plexGet = Model.plexGetCommand("http://corvus.hs:32400/", "tok", "/identity")
assert.strictEqual(plexGet[plexGet.length - 1], "http://corvus.hs:32400/identity", "a trailing slash is not doubled")
assert.ok(plexGet.indexOf("X-Plex-Token: tok") !== -1)
const plexUrlOf = function(command) { return command[command.length - 1] }
assert.match(plexUrlOf(Model.plexSearchCommand("http://s", "tok", " Aphex Twin ")), /query=Aphex%20Twin$/)
assert.match(plexUrlOf(Model.plexRecentCommand("http://s", "tok", "3")), /\/library\/sections\/3\/recentlyAdded\?/)
assert.match(plexUrlOf(Model.plexItemCommand("http://s", "tok", "941", true)), /\/library\/metadata\/941\/allLeaves$/)
assert.match(plexUrlOf(Model.plexItemCommand("http://s", "tok", "941", false)), /\/library\/metadata\/941$/)
assert.strictEqual(Model.plexStreamUrl("http://s", "t o k", "/library/parts/1/2/file.flac"),
  "http://s/library/parts/1/2/file.flac?X-Plex-Token=t%20o%20k")

const sectionsReply = JSON.stringify({ MediaContainer: { Directory: [
  { key: "1", type: "movie", title: "Films" },
  { key: "3", type: "artist", title: "Music" }
] } })
assert.deepStrictEqual(Model.parsePlexSections(sectionsReply), [{ key: "3", title: "Music" }])
assert.deepStrictEqual(Model.parsePlexSections("not json"), [])

const recentReply = JSON.stringify({ MediaContainer: { Metadata: [
  { ratingKey: "9", type: "album", title: "Geogaddi", parentTitle: "Boards of Canada", year: 2002 },
  { ratingKey: "10", type: "track", title: "Not an album" }
] } })
const recent = Model.parsePlexAlbums(recentReply)
assert.strictEqual(recent.length, 1, "only albums belong in the recently-added list")
assert.deepStrictEqual(recent[0], { ratingKey: "9", kind: "plexAlbum", name: "Geogaddi", meta: "Boards of Canada · 2002" })

const hubsReply = JSON.stringify({ MediaContainer: { Hub: [
  { type: "track", Metadata: [{ ratingKey: "41", title: "Sunshine Recorder", grandparentTitle: "Boards of Canada", parentTitle: "Geogaddi" }] },
  { type: "album", Metadata: [{ ratingKey: "9", title: "Geogaddi", parentTitle: "Boards of Canada", year: 2002 }] },
  { type: "artist", Directory: [{ ratingKey: "3", title: "Boards of Canada" }] },
  { type: "movie", Metadata: [{ ratingKey: "77", title: "Not music" }] }
] } })
const plexResults = Model.parsePlexSearch(hubsReply)
assert.strictEqual(Model.plexResultCount(plexResults), 3, "the film hub is dropped")
assert.strictEqual(plexResults.tracks[0].meta, "Boards of Canada · Geogaddi")
assert.strictEqual(plexResults.artists[0].kind, "plexArtist", "artists arrive as a Directory, not as Metadata")

const leavesReply = JSON.stringify({ MediaContainer: { Metadata: [
  { ratingKey: "41", Media: [{ Part: [{ key: "/library/parts/1/2/one.flac" }] }] },
  { ratingKey: "42", Media: [{ Part: [{ key: "" }, { key: "/library/parts/3/4/two.flac" }] }] },
  { ratingKey: "43", Media: [] }
] } })
assert.deepStrictEqual(Model.parsePlexParts(leavesReply),
  ["/library/parts/1/2/one.flac", "/library/parts/3/4/two.flac"], "a track with no part is skipped")
const urls = Model.plexStreamUrls(leavesReply, "http://s", "tok")
assert.strictEqual(urls[0], "http://s/library/parts/1/2/one.flac?X-Plex-Token=tok")

// --- mpv ------------------------------------------------------------------

assert.deepStrictEqual(Model.mpvCommand("/run/user/1000/omnixy-plex.sock").slice(-1),
  ["UNIX-CONNECT:/run/user/1000/omnixy-plex.sock"])
const load = Model.mpvLoadPayload(["a", "b"], false).trim().split("\n")
assert.deepStrictEqual(JSON.parse(load[0]).command, ["loadfile", "a", "replace"], "the first track replaces the playlist")
assert.deepStrictEqual(JSON.parse(load[1]).command, ["loadfile", "b", "append-play"], "the rest queue behind it")
const queued = Model.mpvLoadPayload(["a"], true).trim().split("\n")
assert.deepStrictEqual(JSON.parse(queued[0]).command, ["loadfile", "a", "append-play"], "a queued track never replaces")
assert.strictEqual(Model.mpvLoadPayload([], false), "")
assert.deepStrictEqual(JSON.parse(Model.mpvStopPayload()).command, ["stop"])
assert.ok(Model.mpvReadyCommand("/s").indexOf("UNIX-CONNECT:/s") !== -1)

// --- Rows for the new sources ---------------------------------------------

const spotifyDown = Model.panelRows({ source: "spotify", query: "", mode: "library", spotify: { running: false } })
assert.strictEqual(spotifyDown[1].kind, "start", "a stopped Spotify daemon offers to start")
assert.strictEqual(spotifyDown[1].source, "spotify")
assert.ok(spotifyDown[2].text.indexOf("authenticate") !== -1, "the one-off sign-in is named before it is needed")

const spotifyIdle = Model.panelRows({ source: "spotify", query: "", mode: "library", spotify: { running: true } })
assert.strictEqual(spotifyIdle[1].kind, "spotifyLiked")

const spotifyFound = Model.panelRows({
  source: "spotify", query: "boards", mode: "results", playingTitle: "Roygbiv",
  spotify: { running: true, results: spotify }
})
const spotifyKinds = spotifyFound.map(function(row) { return row.kind })
assert.ok(spotifyKinds.indexOf("spotifyTrack") !== -1)
assert.ok(spotifyKinds.indexOf("spotifyPlaylist") !== -1)
assert.strictEqual(spotifyFound[spotifyFound.length - 1].kind, "search", "a typed query can always be sent on")
const playingRow = spotifyFound.filter(function(row) { return row.kind === "spotifyTrack" && row.playing })
assert.strictEqual(playingRow.length, 1, "the track MPRIS reports is marked as playing")

const plexUnlinked = Model.panelRows({ source: "plex", query: "", mode: "library", plex: { configured: false } })
assert.strictEqual(plexUnlinked[1].text, Model.PLEX_AUTH_HINT)
assert.strictEqual(Model.stepCursor(plexUnlinked, -1, 1), -1, "nothing on the unlinked page is selectable")

const plexRecent = Model.panelRows({
  source: "plex", query: "", mode: "library",
  plex: { configured: true, running: true, recent: recent }
})
assert.strictEqual(plexRecent[0].title, "RECENTLY ADDED")
assert.strictEqual(plexRecent[1].kind, "plexAlbum")
assert.strictEqual(Model.isQueueRow(plexRecent[1]), true, "a Plex row can be queued rather than played")
assert.strictEqual(Model.isQueueRow({ kind: "spotifyTrack" }), false)
assert.strictEqual(Model.isCursorRow({ kind: "plexAlbum" }), true)

// The radio rows are reached by default, so the older half keeps working
// without the panel having to name its source.
assert.strictEqual(Model.panelRows({ running: false, stations: [] })[1].kind, "start")
EOF

[ $? -eq 0 ] || fail "media-radio model assertions"
echo "PASS media-radio model"
