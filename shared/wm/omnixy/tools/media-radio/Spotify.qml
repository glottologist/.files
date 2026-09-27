import QtQuick
import Quickshell
import Quickshell.Io
import "Model.js" as Model

// The Spotify half of the media-radio panel. spotify-player runs headless
// under omnixy-spotify.service, streaming through librespot, and answers the
// CLI over a local socket; this item searches the catalogue and starts
// playback, and leaves now-playing to MPRIS as the radio half does.
//
// Every command is gated on the daemon holding its MPRIS name. That gate is
// not decoration: the CLI starts a client of its own when it finds no running
// instance, and an unauthenticated client opens a browser window at Spotify's
// authorisation page.
Item {
  id: root

  property bool running: false
  property bool searching: false
  property string error: ""
  property var results: ({ tracks: [], albums: [], playlists: [], artists: [] })

  readonly property bool busy: unitProc.running || actionProc.running || settle.running
  property var _afterStart: null
  property bool _stopping: false

  function probe() {
    if (probeProc.running) return
    probeProc.command = Model.namePresentCommand(Model.SPOTIFY_MPRIS)
    probeProc.running = true
  }

  function refresh() {
    error = ""
    probe()
  }

  function withDaemon(action) {
    if (running) {
      action()
      return
    }
    if (unitProc.running) return
    _afterStart = action
    _stopping = false
    unitProc.command = Model.startUnitCommand(Model.SPOTIFY_UNIT)
    unitProc.running = true
  }

  function runAction(command) {
    if (actionProc.running) return
    error = ""
    actionProc.command = command
    actionProc.running = true
  }

  function startDaemon() {
    withDaemon(function() { root.refresh() })
  }

  function stopDaemon() {
    if (unitProc.running) return
    _afterStart = null
    _stopping = true
    settle.stop()
    settle.pendingAction = null
    unitProc.command = Model.stopUnitCommand(Model.SPOTIFY_UNIT)
    unitProc.running = true
  }

  function search(query) {
    var wanted = String(query || "").trim()
    if (!wanted || searchProc.running) return
    withDaemon(function() {
      root.searching = true
      root.error = ""
      root.results = { tracks: [], albums: [], playlists: [], artists: [] }
      searchProc.command = Model.spotifySearchCommand(wanted)
      searchProc.running = true
    })
  }

  function clearResults() {
    results = { tracks: [], albums: [], playlists: [], artists: [] }
    error = ""
  }

  function playTrack(id) {
    withDaemon(function() { root.runAction(Model.spotifyTrackCommand(id)) })
  }

  function playContext(kind, id) {
    withDaemon(function() { root.runAction(Model.spotifyContextCommand(kind, id)) })
  }

  function playLiked() {
    withDaemon(function() { root.runAction(Model.spotifyLikedCommand()) })
  }

  Process {
    id: probeProc
    running: false
    command: []
    stdout: StdioCollector { id: probeOut; waitForEnd: true }
    onExited: function(exitCode) {
      root.running = exitCode === 0 && Model.parseRunning(probeOut.text)
    }
  }

  Process {
    id: searchProc
    running: false
    command: []
    stdout: StdioCollector { id: searchOut; waitForEnd: true }
    stderr: StdioCollector { id: searchErr; waitForEnd: true }
    onExited: function(exitCode) {
      root.searching = false
      if (exitCode !== 0) {
        root.error = Model.errorText(searchErr.text, "Spotify did not answer")
        return
      }
      root.results = Model.parseSpotifySearch(searchOut.text)
    }
  }

  Process {
    id: actionProc
    running: false
    command: []
    stderr: StdioCollector { id: actionErr; waitForEnd: true }
    onExited: function(exitCode) {
      // The CLI's own message is worth more than anything this panel could
      // invent: "no active device" and "premium required" both arrive here.
      if (exitCode !== 0) root.error = Model.errorText(actionErr.text, "Spotify refused that")
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
          stopping ? "Could not stop the Spotify player" : "Could not start the Spotify player")
        if (!stopping) root.running = false
        return
      }

      if (stopping) {
        root.running = false
        root.clearResults()
        return
      }

      settle.pendingAction = next
      settle.attempts = 0
      settle.restart()
    }
  }

  // systemctl returns once the unit is active, which is before librespot has
  // authenticated and taken its MPRIS name. Signing in takes a moment longer
  // than Goodvibes does, so the wait is correspondingly longer.
  Timer {
    id: settle
    property var pendingAction: null
    property int attempts: 0
    interval: 250
    repeat: false
    onTriggered: {
      settleProbe.command = Model.namePresentCommand(Model.SPOTIFY_MPRIS)
      settleProbe.running = true
    }
  }

  Process {
    id: settleProbe
    running: false
    command: []
    stdout: StdioCollector { id: settleOut; waitForEnd: true }
    onExited: function(exitCode) {
      root.running = exitCode === 0 && Model.parseRunning(settleOut.text)
      if (!root.running) {
        settle.attempts = settle.attempts + 1
        if (settle.attempts < 40) {
          settle.restart()
          return
        }
        settle.pendingAction = null
        root.error = "The Spotify player did not come up. Run spotify_player authenticate in a terminal."
        return
      }
      var action = settle.pendingAction
      settle.pendingAction = null
      if (action) action()
    }
  }
}
