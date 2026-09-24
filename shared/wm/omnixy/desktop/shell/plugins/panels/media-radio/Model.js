// The station library and the radio-browser search behind the media-radio
// panel. Goodvibes owns radio playback and answers on the session bus, so
// every command the panel runs is built here as an argv array and every reply
// is parsed here, which lets tools/media-radio-model-test.sh hold the whole
// data path still under node.
//
// Now-playing state deliberately does not appear in this file. It reaches the
// panel through the shell's own MPRIS service instead, which watches every
// player -- Goodvibes, Spotify, a browser tab -- and pushes changes as they
// happen, so nothing here has to poll for a track title.

var SERVICE = "io.gitlab.Goodvibes"
var OBJECT = "/io/gitlab/Goodvibes"
var UNIT = "omnixy-radio.service"
var MPRIS_NAME = "org.mpris.MediaPlayer2.Goodvibes"
var SEARCH_ENDPOINT = "https://de1.api.radio-browser.info/json/stations/search"
var SEARCH_LIMIT = 25

// --- Commands -------------------------------------------------------------

// NameHasOwner answers without activating the name. That distinction matters:
// installing Goodvibes also installs its D-Bus service file, so a bare call to
// io.gitlab.Goodvibes would start the daemon with its GTK window attached.
// Every read below is gated on this probe, and the daemon is only ever started
// through its systemd unit, which passes --without-ui.
function probeCommand() {
  return ["busctl", "--user", "--json=short", "call", "org.freedesktop.DBus",
          "/org/freedesktop/DBus", "org.freedesktop.DBus", "NameHasOwner", "s", SERVICE]
}

function listCommand() {
  return ["busctl", "--user", "--json=short", "call", SERVICE, OBJECT,
          SERVICE + ".Stations", "List"]
}

// Goodvibes resolves the argument as a station name first and as a stream URI
// second, so a search result can be played without being saved.
function playCommand(target) {
  return ["busctl", "--user", "call", SERVICE, OBJECT, SERVICE + ".Player",
          "Play", "s", String(target || "")]
}

function stopCommand() {
  return ["busctl", "--user", "call", SERVICE, OBJECT, SERVICE + ".Player", "Stop"]
}

// Add takes the uri, the name, and a position given as a keyword and an anchor
// station. An empty keyword appends.
function addCommand(uri, name) {
  return ["busctl", "--user", "call", SERVICE, OBJECT, SERVICE + ".Stations",
          "Add", "ssss", String(uri || ""), String(name || ""), "", ""]
}

function removeCommand(name) {
  return ["busctl", "--user", "call", SERVICE, OBJECT, SERVICE + ".Stations",
          "Remove", "s", String(name || "")]
}

function startDaemonCommand() {
  return ["systemctl", "--user", "start", UNIT]
}

// Stopping the unit stops playback with it, which is what the power control in
// the panel header means.
function stopDaemonCommand() {
  return ["systemctl", "--user", "stop", UNIT]
}

function searchCommand(query) {
  return ["curl", "-fsS", "--max-time", "8",
          "-H", "User-Agent: omnixy-media-radio/1.0", searchUrl(query)]
}

function searchUrl(query) {
  return SEARCH_ENDPOINT
    + "?limit=" + SEARCH_LIMIT
    + "&hidebroken=true&order=votes&reverse=true&name="
    + encodeURIComponent(String(query || "").trim())
}

// --- Replies --------------------------------------------------------------

// busctl --json=short wraps a method's return values in an array, one entry
// per out-argument, and every value in a {type, data} pair.
function busctlReturn(raw) {
  var doc
  try {
    doc = JSON.parse(String(raw || ""))
  } catch (error) {
    return null
  }
  if (!doc || !Array.isArray(doc.data) || doc.data.length === 0) return null
  return doc.data[0]
}

function variantValue(value) {
  if (value && typeof value === "object" && !Array.isArray(value) && "data" in value) return value.data
  return value
}

function parseRunning(raw) {
  return busctlReturn(raw) === true
}

function parseStations(raw) {
  var list = busctlReturn(raw)
  if (!Array.isArray(list)) return []

  var stations = []
  for (var i = 0; i < list.length; i++) {
    var entry = list[i] || {}
    var uri = String(variantValue(entry.uri) || "").trim()
    if (!uri) continue
    var name = String(variantValue(entry.name) || "").trim()
    stations.push({ name: name || uri, uri: uri })
  }
  return stations
}

// radio-browser returns a row per station; url_resolved has already followed
// the playlist redirects, so it is the one worth keeping. Duplicate streams are
// common in that database and are dropped on first sight.
function parseSearch(raw) {
  var list
  try {
    list = JSON.parse(String(raw || ""))
  } catch (error) {
    return []
  }
  if (!Array.isArray(list)) return []

  var seen = {}
  var results = []
  for (var i = 0; i < list.length; i++) {
    var row = list[i] || {}
    var uri = String(row.url_resolved || row.url || "").trim()
    var name = String(row.name || "").trim()
    if (!uri || !name || seen[uri]) continue
    seen[uri] = true
    results.push({ name: name, uri: uri, meta: searchMeta(row) })
  }
  return results
}

function searchMeta(row) {
  var parts = []
  var country = String(row.country || "").trim()
  var codec = String(row.codec || "").trim().toUpperCase()
  var bitrate = Number(row.bitrate)
  if (country) parts.push(country)
  // The codec and the bitrate describe one thing, so they stay together rather
  // than becoming two more dot-separated fields.
  var format = codec && codec !== "UNKNOWN" ? codec : ""
  if (isFinite(bitrate) && bitrate > 0) format = format ? format + " " + bitrate + "k" : bitrate + "k"
  if (format) parts.push(format)
  return parts.join(" · ")
}

// busctl reports a refused call as "Call failed: <reason>", and Goodvibes'
// reasons are already written for a reader ("... is neither a known station or
// a valid uri"), so the prefix is all that needs removing.
function errorText(raw, fallback) {
  var text = String(raw || "").trim()
  if (!text) return String(fallback || "")
  text = text.split("\n")[0].trim()
  text = text.replace(/^Call failed:\s*/, "")
  return text || String(fallback || "")
}

// --- Derived views --------------------------------------------------------

function normalise(value) {
  return String(value || "").trim().toLowerCase()
}

function hasStation(stations, uri) {
  var wanted = normalise(uri)
  if (!wanted) return false
  var list = Array.isArray(stations) ? stations : []
  for (var i = 0; i < list.length; i++) if (normalise(list[i].uri) === wanted) return true
  return false
}

function filterStations(stations, query) {
  var list = Array.isArray(stations) ? stations : []
  var wanted = normalise(query)
  if (!wanted) return list

  var matches = []
  for (var i = 0; i < list.length; i++) {
    var station = list[i]
    if (normalise(station.name).indexOf(wanted) !== -1 || normalise(station.uri).indexOf(wanted) !== -1)
      matches.push(station)
  }
  return matches
}

// Goodvibes publishes the station name as the MPRIS artist and the ICY title as
// the track, so the playing row is found by artist rather than by uri; a
// station played straight from a search result still resolves to its name.
function isPlayingStation(station, playingStation) {
  if (!station) return false
  var current = normalise(playingStation)
  if (!current) return false
  return normalise(station.name) === current || normalise(station.uri) === current
}

// One flat row list drives both the repeater and the keyboard cursor, so the
// two can never disagree about what the nth row is.
function panelRows(state) {
  var view = state || {}
  var query = String(view.query || "").trim()
  var stations = Array.isArray(view.stations) ? view.stations : []
  var rows = []

  if (view.mode === "results") {
    var results = Array.isArray(view.results) ? view.results : []
    rows.push({ kind: "section", title: "SEARCH RESULTS", count: results.length })
    if (view.searching) {
      rows.push({ kind: "empty", text: "Searching the radio browser…" })
    } else if (view.searchError) {
      rows.push({ kind: "empty", text: view.searchError })
    } else if (results.length === 0) {
      rows.push({ kind: "empty", text: "The radio browser knows nothing by that name." })
    } else {
      for (var r = 0; r < results.length; r++)
        rows.push({ kind: "result", station: results[r], known: hasStation(stations, results[r].uri) })
    }
    return rows
  }

  var shown = filterStations(stations, query)
  rows.push({ kind: "section", title: "STATIONS", count: shown.length })

  if (view.listError) {
    rows.push({ kind: "empty", text: view.listError })
  } else if (!view.running) {
    // Goodvibes holds the library, so there is nothing to list until it is up.
    // Starting it is an explicit step rather than something opening the panel
    // does, since the panel is just as often opened to pause Spotify.
    rows.push({ kind: "start", text: view.starting ? "Starting the radio player…" : "Start the radio player" })
  } else if (stations.length === 0) {
    rows.push({ kind: "empty", text: "No stations yet." })
  } else if (shown.length === 0) {
    rows.push({ kind: "empty", text: "No station in the library matches that." })
  } else {
    for (var s = 0; s < shown.length; s++)
      rows.push({ kind: "station", station: shown[s], playing: isPlayingStation(shown[s], view.playingStation) })
  }

  if (query) rows.push({ kind: "search", text: "Search the radio browser for “" + query + "”" })
  return rows
}

function isCursorRow(row) {
  if (!row) return false
  return row.kind === "station" || row.kind === "result" || row.kind === "search" || row.kind === "start"
}

function stepCursor(rows, index, delta) {
  var list = Array.isArray(rows) ? rows : []
  if (delta === 0) return index

  var start = index
  if (start < 0 || start >= list.length || !isCursorRow(list[start])) {
    // No cursor yet: step onto the first row going down, the last going up.
    for (var seek = delta > 0 ? 0 : list.length - 1; seek >= 0 && seek < list.length; seek += delta > 0 ? 1 : -1)
      if (isCursorRow(list[seek])) return seek
    return -1
  }

  for (var next = start + delta; next >= 0 && next < list.length; next += delta)
    if (isCursorRow(list[next])) return next
  return start
}

function cursorRowIndexes(rows) {
  var list = Array.isArray(rows) ? rows : []
  var indexes = []
  for (var i = 0; i < list.length; i++) if (isCursorRow(list[i])) indexes.push(i)
  return indexes
}

// --- Labels ---------------------------------------------------------------

function truncate(text, max) {
  var value = String(text || "")
  var limit = Number(max)
  if (!isFinite(limit) || limit <= 0 || value.length <= limit) return value
  return value.slice(0, Math.max(1, limit - 1)).replace(/\s+$/, "") + "…"
}

// The bar carries the glyph alone until something is playing, then the track
// beside it. Two spaces rather than one: a Nerd Font glyph sits tight against
// what follows it at bar sizes.
function barLabel(icon, title, artist, max) {
  var label = truncate(title || artist || "", max)
  return label ? icon + "  " + label : icon
}

function barTooltip(title, artist, identity) {
  var track = String(title || "").trim()
  var by = String(artist || "").trim()
  var source = String(identity || "").trim()
  var line = track && by ? track + " — " + by : (track || by)
  if (line && source) return line + " (" + source + ")"
  return line || source || "Nothing playing"
}

function heroMeta(artist, album) {
  var parts = []
  if (String(artist || "").trim()) parts.push(String(artist).trim())
  if (String(album || "").trim()) parts.push(String(album).trim())
  return parts.join(" · ")
}

function stationMeta(station, playing) {
  if (playing) return "Playing"
  return hostOf(station ? station.uri : "")
}

// The host alone, so a row shows where a stream comes from without wrapping a
// hundred-character URL across the panel.
function hostOf(uri) {
  var match = /^[a-z]+:\/\/([^\/?#]+)/i.exec(String(uri || ""))
  return match ? match[1] : String(uri || "")
}

// A search result keeps the name the radio browser gave it when it is saved,
// which is what the user just read and clicked.
function suggestedName(station) {
  return station && station.name ? String(station.name).trim() : ""
}

if (typeof module !== "undefined") {
  module.exports = {
    SERVICE: SERVICE,
    UNIT: UNIT,
    MPRIS_NAME: MPRIS_NAME,
    probeCommand: probeCommand,
    listCommand: listCommand,
    playCommand: playCommand,
    stopCommand: stopCommand,
    addCommand: addCommand,
    removeCommand: removeCommand,
    startDaemonCommand: startDaemonCommand,
    stopDaemonCommand: stopDaemonCommand,
    searchCommand: searchCommand,
    searchUrl: searchUrl,
    busctlReturn: busctlReturn,
    parseRunning: parseRunning,
    parseStations: parseStations,
    parseSearch: parseSearch,
    searchMeta: searchMeta,
    errorText: errorText,
    hasStation: hasStation,
    filterStations: filterStations,
    isPlayingStation: isPlayingStation,
    panelRows: panelRows,
    isCursorRow: isCursorRow,
    stepCursor: stepCursor,
    cursorRowIndexes: cursorRowIndexes,
    truncate: truncate,
    barLabel: barLabel,
    barTooltip: barTooltip,
    heroMeta: heroMeta,
    stationMeta: stationMeta,
    hostOf: hostOf,
    suggestedName: suggestedName
  }
}
