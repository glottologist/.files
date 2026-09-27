import QtQuick
import Quickshell
import Quickshell.Io
import "Model.js" as Model

// The Plex half of the media-radio panel. Plex Media Server is a library and
// a streaming endpoint rather than a player, so the playing is done by an mpv
// daemon under omnixy-plex.service: the server is read over HTTP with curl,
// and the tracks chosen here are loaded into mpv down its IPC socket.
//
// Direct play is deliberate. The URL served at a part's key is the original
// file, so mpv reads the embedded tags itself and the shell's MPRIS service
// reports a real title, artist and album with nothing injected from here.
Item {
  id: root

  property string server: ""
  property string token: ""
  readonly property bool configured: server !== "" && token !== ""

  property bool running: false
  property bool loading: false
  property string error: ""
  property string sectionKey: ""
  property var recent: []
  property var results: ({ tracks: [], albums: [], artists: [] })

  readonly property string socketPath: Model.plexSocketPath(Quickshell.env("XDG_RUNTIME_DIR"))
  readonly property bool busy: unitProc.running || itemProc.running || mpvProc.running || settle.running

  property var _afterStart: null
  property bool _stopping: false
  property bool _appendNext: false

  function applyConfig(text) {
    var config = Model.parsePlexConfig(text)
    server = config.server
    token = config.token
    if (configured) refresh()
  }

  function probe() {
    if (probeProc.running) return
    probeProc.command = Model.mpvReadyCommand(socketPath)
    probeProc.running = true
  }

  function refresh() {
    error = ""
    probe()
    if (!configured || sectionsProc.running) return
    loading = true
    sectionsProc.command = Model.plexSectionsCommand(server, token)
    sectionsProc.running = true
  }

  function loadRecent() {
    if (!configured || sectionKey === "" || recentProc.running) return
    loading = true
    recentProc.command = Model.plexRecentCommand(server, token, sectionKey)
    recentProc.running = true
  }

  function search(query) {
    var wanted = String(query || "").trim()
    if (!configured || !wanted || searchProc.running) return
    loading = true
    error = ""
    results = { tracks: [], albums: [], artists: [] }
    searchProc.command = Model.plexSearchCommand(server, token, wanted)
    searchProc.running = true
  }

  function clearResults() {
    results = { tracks: [], albums: [], artists: [] }
  }

  // A track is fetched on its own; an album or an artist is expanded into
  // every track beneath it, which becomes the queue.
  function play(item, append) {
    if (!configured || !item || itemProc.running) return
    error = ""
    _appendNext = append === true
    itemProc.command = Model.plexItemCommand(server, token, item.ratingKey, String(item.kind || "") !== "plexTrack")
    itemProc.running = true
  }

  function queue(item) {
    play(item, true)
  }

  function stop() {
    if (!running) return
    sendToMpv(Model.mpvStopPayload())
  }

  function sendToMpv(payload) {
    if (!payload || mpvProc.running) return
    withDaemon(function() {
      mpvProc.payload = payload
      mpvProc.command = Model.mpvCommand(root.socketPath)
      mpvProc.running = true
    })
  }

  function withDaemon(action) {
    if (running) {
      action()
      return
    }
    if (unitProc.running) return
    _afterStart = action
    _stopping = false
    unitProc.command = Model.startUnitCommand(Model.PLEX_UNIT)
    unitProc.running = true
  }

  function startDaemon() {
    withDaemon(function() { root.probe() })
  }

  function stopDaemon() {
    if (unitProc.running) return
    _afterStart = null
    _stopping = true
    settle.stop()
    settle.pendingAction = null
    unitProc.command = Model.stopUnitCommand(Model.PLEX_UNIT)
    unitProc.running = true
  }

  FileView {
    id: configFile
    path: Model.plexConfigPath(Quickshell.env("HOME"))
    watchChanges: true
    printErrors: false
    onLoaded: root.applyConfig(text())
    onLoadFailed: root.applyConfig("")
    onFileChanged: reload()
  }

  Process {
    id: probeProc
    running: false
    command: []
    onExited: function(exitCode) {
      root.running = exitCode === 0
    }
  }

  Process {
    id: sectionsProc
    running: false
    command: []
    stdout: StdioCollector { id: sectionsOut; waitForEnd: true }
    stderr: StdioCollector { id: sectionsErr; waitForEnd: true }
    onExited: function(exitCode) {
      root.loading = false
      if (exitCode !== 0) {
        root.error = Model.errorText(sectionsErr.text, "The Plex server did not answer")
        return
      }
      var sections = Model.parsePlexSections(sectionsOut.text)
      if (sections.length === 0) {
        root.sectionKey = ""
        root.recent = []
        root.error = "That Plex server has no music library."
        return
      }
      root.error = ""
      root.sectionKey = sections[0].key
      root.loadRecent()
    }
  }

  Process {
    id: recentProc
    running: false
    command: []
    stdout: StdioCollector { id: recentOut; waitForEnd: true }
    stderr: StdioCollector { id: recentErr; waitForEnd: true }
    onExited: function(exitCode) {
      root.loading = false
      if (exitCode !== 0) {
        root.error = Model.errorText(recentErr.text, "The Plex server did not answer")
        return
      }
      root.error = ""
      root.recent = Model.parsePlexAlbums(recentOut.text)
    }
  }

  Process {
    id: searchProc
    running: false
    command: []
    stdout: StdioCollector { id: searchOut; waitForEnd: true }
    stderr: StdioCollector { id: searchErr; waitForEnd: true }
    onExited: function(exitCode) {
      root.loading = false
      if (exitCode !== 0) {
        root.error = Model.errorText(searchErr.text, "The Plex server did not answer")
        return
      }
      root.error = ""
      root.results = Model.parsePlexSearch(searchOut.text)
    }
  }

  Process {
    id: itemProc
    running: false
    command: []
    stdout: StdioCollector { id: itemOut; waitForEnd: true }
    stderr: StdioCollector { id: itemErr; waitForEnd: true }
    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.error = Model.errorText(itemErr.text, "The Plex server did not answer")
        return
      }
      var urls = Model.plexStreamUrls(itemOut.text, root.server, root.token)
      if (urls.length === 0) {
        root.error = "Plex holds no playable file for that."
        return
      }
      root.sendToMpv(Model.mpvLoadPayload(urls, root._appendNext))
    }
  }

  // socat carries one batch of IPC commands and then leaves; closing stdin is
  // what ends it, so the write channel is shut as soon as the payload is in.
  Process {
    id: mpvProc
    property string payload: ""
    running: false
    command: []
    stdinEnabled: true
    stderr: StdioCollector { id: mpvErr; waitForEnd: true }
    onStarted: {
      write(payload)
      payload = ""
      stdinEnabled = false
    }
    onExited: function(exitCode) {
      stdinEnabled = true
      if (exitCode !== 0) root.error = Model.errorText(mpvErr.text, "The Plex player did not accept that")
    }
  }

  Process {
    id: unitProc
    running: false
    command: []
    stderr: StdioCollector { id: unitErr; waitForEnd: true }
    onExited: function(exitCode) {
      var next = root._afterStart
      var stopping = root._stopping
      root._afterStart = null
      root._stopping = false

      if (exitCode !== 0) {
        root.error = Model.errorText(unitErr.text,
          stopping ? "Could not stop the Plex player" : "Could not start the Plex player")
        if (!stopping) root.running = false
        return
      }

      if (stopping) {
        root.running = false
        return
      }

      settle.pendingAction = next
      settle.attempts = 0
      settle.restart()
    }
  }

  // mpv creates its IPC socket a moment after the unit reports active, and a
  // command written before then would find nothing listening, so the wait is
  // on a connection that succeeds rather than on systemd's word.
  Timer {
    id: settle
    property var pendingAction: null
    property int attempts: 0
    interval: 150
    repeat: false
    onTriggered: {
      settleProbe.command = Model.mpvReadyCommand(root.socketPath)
      settleProbe.running = true
    }
  }

  Process {
    id: settleProbe
    running: false
    command: []
    onExited: function(exitCode) {
      root.running = exitCode === 0
      if (!root.running) {
        settle.attempts = settle.attempts + 1
        if (settle.attempts < 20) {
          settle.restart()
          return
        }
        settle.pendingAction = null
        root.error = "The Plex player did not come up"
        return
      }
      var action = settle.pendingAction
      settle.pendingAction = null
      if (action) action()
    }
  }
}
