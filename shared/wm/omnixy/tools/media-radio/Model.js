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

// The three things the panel can play. Radio came first and still owns the
// file's older half; Spotify and Plex were added on 2026-09-27 (record:
// agents/2026-09-27-001) and each follows the same shape -- a daemon under a
// user unit, an MPRIS name the shell's media service picks up on its own, and
// a library this file knows how to query.
var SOURCES = ["radio", "spotify", "plex"]

var SPOTIFY_UNIT = "omnixy-spotify.service"
var SPOTIFY_MPRIS = "org.mpris.MediaPlayer2.spotify_player"
var SPOTIFY_TRACK_LIMIT = 8
var SPOTIFY_CONTEXT_LIMIT = 4

var PLEX_UNIT = "omnixy-plex.service"
var PLEX_MPRIS = "org.mpris.MediaPlayer2.mpv"
var PLEX_CONFIG = "/.config/omnixy/plex.json"
var PLEX_SOCKET = "/omnixy-plex.sock"
var PLEX_LIMIT = 20
var PLEX_AUTH_HINT = "Not linked to Plex yet. Run omnixy-plex-auth in a terminal."

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

function startUnitCommand(unit) {
  return ["systemctl", "--user", "start", String(unit || "")]
}

// Stopping the unit stops playback with it, which is what the power control in
// the panel header means.
function stopUnitCommand(unit) {
  return ["systemctl", "--user", "stop", String(unit || "")]
}

function startDaemonCommand() {
  return startUnitCommand(UNIT)
}

function stopDaemonCommand() {
  return stopUnitCommand(UNIT)
}

// Goodvibes and spotify-player are judged up or down by whether they hold
// their MPRIS name, which costs nothing to ask and activates nothing. The
// Plex daemon is asked differently, by connecting to its socket: see
// mpvReadyCommand below.
function namePresentCommand(name) {
  return ["busctl", "--user", "--json=short", "call", "org.freedesktop.DBus",
          "/org/freedesktop/DBus", "org.freedesktop.DBus", "NameHasOwner", "s", String(name || "")]
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

// --- Spotify commands -----------------------------------------------------

// spotify-player's CLI reaches a running instance over a UDP socket, and if it
// finds none it quietly starts a client of its own -- which authenticates, and
// so opens a browser window at Spotify's authorisation page. Every command
// below is therefore only ever run once the daemon is known to hold its MPRIS
// name, exactly as the Goodvibes calls are gated on NameHasOwner.
function spotifySearchCommand(query) {
  return ["spotify_player", "search", String(query || "").trim()]
}

function spotifyTrackCommand(id) {
  return ["spotify_player", "playback", "start", "track", "--id", String(id || "")]
}

// A context is an album, a playlist or an artist; the kind is a positional
// argument and the identifier the bare base62 one that search returns.
function spotifyContextCommand(kind, id) {
  return ["spotify_player", "playback", "start", "context", String(kind || ""), "--id", String(id || "")]
}

function spotifyLikedCommand() {
  return ["spotify_player", "playback", "start", "liked"]
}

// --- Plex commands --------------------------------------------------------

function plexConfigPath(home) {
  return String(home || "") + PLEX_CONFIG
}

function plexSocketPath(runtimeDir) {
  return String(runtimeDir || "") + PLEX_SOCKET
}

function plexUrl(server, path) {
  return String(server || "").replace(/\/+$/, "") + String(path || "")
}

function plexGetCommand(server, token, path) {
  return ["curl", "-fsS", "--max-time", "8",
          "-H", "Accept: application/json",
          "-H", "X-Plex-Token: " + String(token || ""),
          plexUrl(server, path)]
}

function plexSectionsCommand(server, token) {
  return plexGetCommand(server, token, "/library/sections")
}

// What the list shows before anything has been typed. Plex orders this newest
// first, so it needs no sort of ours.
function plexRecentCommand(server, token, sectionKey) {
  return plexGetCommand(server, token,
    "/library/sections/" + encodeURIComponent(String(sectionKey || "")) +
    "/recentlyAdded?X-Plex-Container-Start=0&X-Plex-Container-Size=" + PLEX_LIMIT)
}

function plexSearchCommand(server, token, query) {
  return plexGetCommand(server, token,
    "/hubs/search?limit=" + PLEX_LIMIT + "&query=" + encodeURIComponent(String(query || "").trim()))
}

// One track answers with its own metadata; an album or an artist answers with
// every track beneath it, which is the queue the panel then loads.
function plexItemCommand(server, token, ratingKey, deep) {
  var path = "/library/metadata/" + encodeURIComponent(String(ratingKey || ""))
  return plexGetCommand(server, token, deep ? path + "/allLeaves" : path)
}

// Plex serves the original file at the part's key, so mpv reads the embedded
// tags itself and MPRIS carries a real title, artist and album without the
// panel injecting any metadata.
function plexStreamUrl(server, token, partKey) {
  return plexUrl(server, partKey) + "?X-Plex-Token=" + encodeURIComponent(String(token || ""))
}

// --- mpv control ----------------------------------------------------------

// MPRIS can start a track but not queue one -- mpv-mpris maps OpenUri to a
// bare loadfile, which replaces the playlist -- so playback goes down mpv's
// own IPC socket, where append-play exists.
function mpvCommand(socketPath) {
  return ["socat", "-t", "1", "-", "UNIX-CONNECT:" + String(socketPath || "")]
}

function mpvLoadPayload(urls, append) {
  var list = Array.isArray(urls) ? urls : []
  var lines = []
  for (var i = 0; i < list.length; i++) {
    var replace = !append && i === 0
    lines.push(JSON.stringify({ command: ["loadfile", String(list[i]), replace ? "replace" : "append-play"] }))
  }
  return lines.length ? lines.join("\n") + "\n" : ""
}

function mpvStopPayload() {
  return JSON.stringify({ command: ["stop"] }) + "\n"
}

// mpv opens the socket a moment after systemd reports the unit active, so
// readiness is a connection that succeeds rather than a unit that exists.
// Connecting with nothing to send costs mpv one accepted client.
function mpvReadyCommand(socketPath) {
  return ["socat", "-u", "OPEN:/dev/null", "UNIX-CONNECT:" + String(socketPath || "")]
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

// --- Spotify replies ------------------------------------------------------

function parseJson(raw) {
  try {
    return JSON.parse(String(raw || ""))
  } catch (error) {
    return null
  }
}

function spotifyList(value) {
  return Array.isArray(value) ? value : []
}

function spotifyArtistNames(artists) {
  var list = spotifyList(artists)
  var names = []
  for (var i = 0; i < list.length; i++) {
    var name = String((list[i] || {}).name || "").trim()
    if (name) names.push(name)
  }
  return names.join(", ")
}

// spotify-player prints its SearchResults structure whole. Every identifier in
// it is an rspotify newtype over a string, so each id arrives as the bare
// base62 one the playback commands ask for rather than as a spotify: URI.
function parseSpotifySearch(raw) {
  var doc = parseJson(raw) || {}
  var results = { tracks: [], albums: [], playlists: [], artists: [] }

  var tracks = spotifyList(doc.tracks)
  for (var t = 0; t < tracks.length && results.tracks.length < SPOTIFY_TRACK_LIMIT; t++) {
    var track = tracks[t] || {}
    if (!track.id || !track.name) continue
    var album = track.album ? String(track.album.name || "").trim() : ""
    results.tracks.push({
      id: String(track.id),
      kind: "spotifyTrack",
      name: String(track.name),
      meta: joinMeta([spotifyArtistNames(track.artists), album])
    })
  }

  var albums = spotifyList(doc.albums)
  for (var a = 0; a < albums.length && results.albums.length < SPOTIFY_CONTEXT_LIMIT; a++) {
    var record = albums[a] || {}
    if (!record.id || !record.name) continue
    results.albums.push({
      id: String(record.id),
      kind: "spotifyAlbum",
      name: String(record.name),
      meta: joinMeta([spotifyArtistNames(record.artists), String(record.release_date || "").slice(0, 4)])
    })
  }

  var playlists = spotifyList(doc.playlists)
  for (var p = 0; p < playlists.length && results.playlists.length < SPOTIFY_CONTEXT_LIMIT; p++) {
    var playlist = playlists[p] || {}
    if (!playlist.id || !playlist.name) continue
    // The owner is a (display name, user id) pair.
    var owner = Array.isArray(playlist.owner) ? String(playlist.owner[0] || "").trim() : ""
    results.playlists.push({
      id: String(playlist.id),
      kind: "spotifyPlaylist",
      name: String(playlist.name),
      meta: owner ? "by " + owner : ""
    })
  }

  var artists = spotifyList(doc.artists)
  for (var r = 0; r < artists.length && results.artists.length < SPOTIFY_CONTEXT_LIMIT; r++) {
    var artist = artists[r] || {}
    if (!artist.id || !artist.name) continue
    results.artists.push({ id: String(artist.id), kind: "spotifyArtist", name: String(artist.name), meta: "" })
  }

  return results
}

function spotifyResultCount(results) {
  var view = results || {}
  return spotifyList(view.tracks).length + spotifyList(view.albums).length
       + spotifyList(view.playlists).length + spotifyList(view.artists).length
}

// --- Plex replies ---------------------------------------------------------

function joinMeta(parts) {
  var list = Array.isArray(parts) ? parts : []
  var kept = []
  for (var i = 0; i < list.length; i++) {
    var part = String(list[i] || "").trim()
    if (part) kept.push(part)
  }
  return kept.join(" · ")
}

function plexContainer(raw) {
  var doc = parseJson(raw)
  return doc && doc.MediaContainer ? doc.MediaContainer : null
}

function plexEntries(container) {
  var view = container || {}
  var metadata = Array.isArray(view.Metadata) ? view.Metadata : []
  var directory = Array.isArray(view.Directory) ? view.Directory : []
  return metadata.concat(directory)
}

function parsePlexConfig(raw) {
  var doc = parseJson(raw) || {}
  return {
    server: String(doc.server || "").trim(),
    token: String(doc.token || "").trim()
  }
}

// A Plex server holds libraries of several kinds; the music ones are those
// whose directory type is "artist".
function parsePlexSections(raw) {
  var entries = plexEntries(plexContainer(raw))
  var sections = []
  for (var i = 0; i < entries.length; i++) {
    var entry = entries[i] || {}
    if (String(entry.type || "") !== "artist") continue
    var key = String(entry.key || "").trim()
    if (!key) continue
    sections.push({ key: key, title: String(entry.title || "Music") })
  }
  return sections
}

function plexAlbumRow(entry) {
  return {
    ratingKey: String(entry.ratingKey || ""),
    kind: "plexAlbum",
    name: String(entry.title || ""),
    meta: joinMeta([String(entry.parentTitle || ""), String(entry.year || "")])
  }
}

function plexTrackRow(entry) {
  return {
    ratingKey: String(entry.ratingKey || ""),
    kind: "plexTrack",
    name: String(entry.title || ""),
    meta: joinMeta([String(entry.grandparentTitle || ""), String(entry.parentTitle || "")])
  }
}

function plexArtistRow(entry) {
  return {
    ratingKey: String(entry.ratingKey || ""),
    kind: "plexArtist",
    name: String(entry.title || ""),
    meta: ""
  }
}

function parsePlexAlbums(raw) {
  var entries = plexEntries(plexContainer(raw))
  var albums = []
  for (var i = 0; i < entries.length; i++) {
    var entry = entries[i] || {}
    if (String(entry.type || "") !== "album" || !entry.ratingKey) continue
    albums.push(plexAlbumRow(entry))
  }
  return albums
}

// The search hubs cover every library on the server, films and photographs
// included; only the three music types are kept, and each of them is playable.
function parsePlexSearch(raw) {
  var container = plexContainer(raw) || {}
  var hubs = Array.isArray(container.Hub) ? container.Hub : []
  var results = { tracks: [], albums: [], artists: [] }

  for (var h = 0; h < hubs.length; h++) {
    var hub = hubs[h] || {}
    var type = String(hub.type || "")
    var entries = plexEntries(hub)
    for (var i = 0; i < entries.length; i++) {
      var entry = entries[i] || {}
      if (!entry.ratingKey) continue
      if (type === "track") results.tracks.push(plexTrackRow(entry))
      else if (type === "album") results.albums.push(plexAlbumRow(entry))
      else if (type === "artist") results.artists.push(plexArtistRow(entry))
    }
  }
  return results
}

function plexResultCount(results) {
  var view = results || {}
  return (Array.isArray(view.tracks) ? view.tracks.length : 0)
       + (Array.isArray(view.albums) ? view.albums.length : 0)
       + (Array.isArray(view.artists) ? view.artists.length : 0)
}

// Whatever was asked for -- one track, or every track beneath an album or an
// artist -- comes back as the same list of metadata, each with the parts that
// hold the audio. A track with no part is skipped rather than queued as a
// URL that would fail to open.
function firstPartKey(entry) {
  var media = Array.isArray((entry || {}).Media) ? entry.Media : []
  for (var m = 0; m < media.length; m++) {
    var parts = Array.isArray((media[m] || {}).Part) ? media[m].Part : []
    for (var p = 0; p < parts.length; p++) {
      var key = String((parts[p] || {}).key || "").trim()
      if (key) return key
    }
  }
  return ""
}

function parsePlexParts(raw) {
  var entries = plexEntries(plexContainer(raw))
  var keys = []
  for (var i = 0; i < entries.length; i++) {
    var key = firstPartKey(entries[i])
    if (key) keys.push(key)
  }
  return keys
}

function plexStreamUrls(raw, server, token) {
  var keys = parsePlexParts(raw)
  var urls = []
  for (var i = 0; i < keys.length; i++) urls.push(plexStreamUrl(server, token, keys[i]))
  return urls
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
// two can never disagree about what the nth row is. The selected source
// decides which list that is; the hero and the transport row above it are
// fed by MPRIS and so belong to no source in particular.
function panelRows(state) {
  var view = state || {}
  var source = String(view.source || "radio")
  if (source === "spotify") return spotifyRows(view)
  if (source === "plex") return plexRows(view)
  return radioRows(view)
}

function radioRows(state) {
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

// A section of playable rows, or nothing at all when the search found none of
// that kind. Spotify and Plex both answer in these groups.
function appendGroup(rows, title, items, playingTitle) {
  var list = Array.isArray(items) ? items : []
  if (list.length === 0) return
  rows.push({ kind: "section", title: title, count: list.length })
  for (var i = 0; i < list.length; i++) {
    var item = list[i]
    rows.push({
      kind: item.kind,
      item: item,
      playing: isPlayingItem(item, playingTitle)
    })
  }
}

function spotifyRows(state) {
  var view = state || {}
  var spotify = view.spotify || {}
  var query = String(view.query || "").trim()
  var rows = []

  if (!spotify.running) {
    rows.push({ kind: "section", title: "SPOTIFY" })
    rows.push({
      kind: "start",
      source: "spotify",
      text: spotify.starting ? "Starting the Spotify player…" : "Start the Spotify player"
    })
    // Without cached credentials the daemon starts and then fails to play, so
    // the panel says where the one-off sign-in happens before it is needed.
    rows.push({ kind: "empty", text: "First time: run spotify_player authenticate in a terminal." })
    return rows
  }

  // A failed search or a refused play is reported on the panel's error line,
  // above the list, so it is not repeated as a row here.
  if (spotify.searching) {
    rows.push({ kind: "section", title: "SPOTIFY" })
    rows.push({ kind: "empty", text: "Searching Spotify…" })
  } else if (view.mode === "results") {
    var results = spotify.results || {}
    if (spotifyResultCount(results) === 0) {
      rows.push({ kind: "section", title: "SEARCH RESULTS", count: 0 })
      rows.push({ kind: "empty", text: "Spotify knows nothing by that name." })
    } else {
      appendGroup(rows, "TRACKS", results.tracks, view.playingTitle)
      appendGroup(rows, "ALBUMS", results.albums, view.playingTitle)
      appendGroup(rows, "PLAYLISTS", results.playlists, view.playingTitle)
      appendGroup(rows, "ARTISTS", results.artists, view.playingTitle)
    }
  } else {
    rows.push({ kind: "section", title: "SPOTIFY" })
    rows.push({ kind: "spotifyLiked", text: "Play your liked songs" })
    rows.push({ kind: "empty", text: "Type to search Spotify." })
  }

  if (query) rows.push({ kind: "search", source: "spotify", text: "Search Spotify for “" + query + "”" })
  return rows
}

function plexRows(state) {
  var view = state || {}
  var plex = view.plex || {}
  var query = String(view.query || "").trim()
  var rows = []

  if (!plex.configured) {
    rows.push({ kind: "section", title: "PLEX" })
    rows.push({ kind: "empty", text: PLEX_AUTH_HINT })
    return rows
  }

  if (plex.loading) {
    rows.push({ kind: "section", title: "PLEX" })
    rows.push({ kind: "empty", text: "Asking Plex…" })
  } else if (view.mode === "results") {
    var results = plex.results || {}
    if (plexResultCount(results) === 0) {
      rows.push({ kind: "section", title: "SEARCH RESULTS", count: 0 })
      rows.push({ kind: "empty", text: "Nothing in the library matches that." })
    } else {
      appendGroup(rows, "TRACKS", results.tracks, view.playingTitle)
      appendGroup(rows, "ALBUMS", results.albums, view.playingTitle)
      appendGroup(rows, "ARTISTS", results.artists, view.playingTitle)
    }
  } else {
    var recent = Array.isArray(plex.recent) ? plex.recent : []
    if (recent.length === 0) {
      rows.push({ kind: "section", title: "RECENTLY ADDED", count: 0 })
      rows.push({ kind: "empty", text: "Nothing recent in the music library." })
    } else {
      appendGroup(rows, "RECENTLY ADDED", recent, view.playingTitle)
    }
  }

  if (query) rows.push({ kind: "search", source: "plex", text: "Search Plex for “" + query + "”" })
  return rows
}

var CURSOR_KINDS = ["station", "result", "search", "start", "spotifyLiked",
                    "spotifyTrack", "spotifyAlbum", "spotifyPlaylist", "spotifyArtist",
                    "plexTrack", "plexAlbum", "plexArtist"]

function isCursorRow(row) {
  if (!row) return false
  return CURSOR_KINDS.indexOf(String(row.kind || "")) !== -1
}

// A queue is the one secondary action the new sources have: a Plex row can be
// added to what mpv is already playing rather than replacing it.
function isQueueRow(row) {
  if (!row) return false
  var kind = String(row.kind || "")
  return kind === "plexTrack" || kind === "plexAlbum" || kind === "plexArtist"
}

// The shell's media service reports the track of whichever player is live, so
// a row is marked as playing when its own name is that track. Albums and
// artists seldom match, which is right: what plays is a track.
function isPlayingItem(item, playingTitle) {
  if (!item) return false
  var current = normalise(playingTitle)
  if (!current) return false
  return normalise(item.name) === current
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

function sourceLabel(source) {
  if (source === "spotify") return "Spotify"
  if (source === "plex") return "Plex"
  return "Radio"
}

function stepSource(source, delta) {
  var index = SOURCES.indexOf(String(source || "radio"))
  if (index === -1) index = 0
  var next = (index + delta) % SOURCES.length
  if (next < 0) next += SOURCES.length
  return SOURCES[next]
}

function searchPlaceholder(source) {
  if (source === "spotify") return "Search Spotify for a track, album or playlist"
  if (source === "plex") return "Search the Plex music library"
  return "Filter stations, or search the radio browser"
}

function powerTooltip(source, running) {
  var name = source === "spotify" ? "Spotify player"
           : source === "plex" ? "Plex player"
           : "radio player"
  return (running ? "Stop the " : "Start the ") + name
}

if (typeof module !== "undefined") {
  module.exports = {
    SERVICE: SERVICE,
    UNIT: UNIT,
    MPRIS_NAME: MPRIS_NAME,
    SOURCES: SOURCES,
    SPOTIFY_UNIT: SPOTIFY_UNIT,
    SPOTIFY_MPRIS: SPOTIFY_MPRIS,
    PLEX_UNIT: PLEX_UNIT,
    PLEX_MPRIS: PLEX_MPRIS,
    PLEX_AUTH_HINT: PLEX_AUTH_HINT,
    startUnitCommand: startUnitCommand,
    stopUnitCommand: stopUnitCommand,
    namePresentCommand: namePresentCommand,
    spotifySearchCommand: spotifySearchCommand,
    spotifyTrackCommand: spotifyTrackCommand,
    spotifyContextCommand: spotifyContextCommand,
    spotifyLikedCommand: spotifyLikedCommand,
    parseSpotifySearch: parseSpotifySearch,
    spotifyResultCount: spotifyResultCount,
    plexConfigPath: plexConfigPath,
    plexSocketPath: plexSocketPath,
    plexUrl: plexUrl,
    plexGetCommand: plexGetCommand,
    plexSectionsCommand: plexSectionsCommand,
    plexRecentCommand: plexRecentCommand,
    plexSearchCommand: plexSearchCommand,
    plexItemCommand: plexItemCommand,
    plexStreamUrl: plexStreamUrl,
    plexStreamUrls: plexStreamUrls,
    parsePlexConfig: parsePlexConfig,
    parsePlexSections: parsePlexSections,
    parsePlexAlbums: parsePlexAlbums,
    parsePlexSearch: parsePlexSearch,
    parsePlexParts: parsePlexParts,
    plexResultCount: plexResultCount,
    mpvCommand: mpvCommand,
    mpvLoadPayload: mpvLoadPayload,
    mpvStopPayload: mpvStopPayload,
    mpvReadyCommand: mpvReadyCommand,
    isQueueRow: isQueueRow,
    isPlayingItem: isPlayingItem,
    sourceLabel: sourceLabel,
    stepSource: stepSource,
    searchPlaceholder: searchPlaceholder,
    powerTooltip: powerTooltip,
    joinMeta: joinMeta,
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
