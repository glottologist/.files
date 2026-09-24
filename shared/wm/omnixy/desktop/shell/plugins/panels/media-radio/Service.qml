import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "Model.js" as Model

// The radio half of the media-radio panel. Goodvibes holds the station
// library and does the playing; this item reads and drives it over the session
// bus, and leaves everything about the current track to MPRIS, which reports it
// without being asked.
//
// The daemon runs under omnixy-radio.service rather than being started here,
// so that playback survives a shell reload -- a theme change restarts
// quickshell, and a Process owned by the shell would die with it.
Item {
  id: root

  property bool running: false
  property var stations: []
  property var results: []
  property string query: ""
  // "library" lists what Goodvibes holds, "results" what the radio browser
  // last answered. The query box drives both, so the mode says which list the
  // rows are built from.
  property string mode: "library"
  property bool searching: false
  property string searchError: ""
  property string listError: ""
  property string lastError: ""

  readonly property bool busy: actionProc.running || daemonProc.running || listProc.running
  readonly property var players: Mpris.players ? Mpris.players.values : []
  readonly property var radioPlayer: findRadioPlayer()
  readonly property bool playing: !!(radioPlayer && radioPlayer.isPlaying)
  // Goodvibes publishes the station as the MPRIS artist and the stream's ICY
  // title as the track.
  readonly property string playingStation: radioPlayer ? String(radioPlayer.trackArtist || "") : ""
  readonly property string playingTitle: radioPlayer ? String(radioPlayer.trackTitle || "") : ""

  // Runs once the daemon is known to hold the bus name, starting it first if
  // it does not. Only one action is ever outstanding, which is all a panel
  // driven by clicks needs.
  property var _afterStart: null
  // The same Process serves both directions of the unit, so it has to say
  // which one it is running: a stop must not then wait for a bus name that is
  // meant to be going away.
  property bool _stoppingDaemon: false

  function findRadioPlayer() {
    for (var i = 0; i < players.length; i++) {
      var player = players[i]
      if (player && String(player.dbusName || "") === Model.MPRIS_NAME) return player
    }
    return null
  }

  function probe() {
    if (probeProc.running) return
    probeProc.command = Model.probeCommand()
    probeProc.running = true
  }

  function list() {
    if (listProc.running || !running) return
    listProc.command = Model.listCommand()
    listProc.running = true
  }

  function refresh() {
    listError = ""
    probe()
  }

  function withDaemon(action) {
    if (running) {
      action()
      return
    }
    if (daemonProc.running) return
    _afterStart = action
    _stoppingDaemon = false
    daemonProc.command = Model.startDaemonCommand()
    daemonProc.running = true
  }

  function runAction(command) {
    if (actionProc.running) return
    lastError = ""
    actionProc.command = command
    actionProc.running = true
  }

  function play(target) {
    withDaemon(function() { root.runAction(Model.playCommand(target)) })
  }

  function stop() {
    if (!running) return
    runAction(Model.stopCommand())
  }

  function addStation(uri, name) {
    withDaemon(function() { root.runAction(Model.addCommand(uri, name)) })
  }

  function removeStation(name) {
    if (!running) return
    runAction(Model.removeCommand(name))
  }

  function startDaemon() {
    withDaemon(function() { root.refresh() })
  }

  function stopDaemon() {
    if (daemonProc.running) return
    _afterStart = null
    _stoppingDaemon = true
    settle.stop()
    settle.pendingAction = null
    daemonProc.command = Model.stopDaemonCommand()
    daemonProc.running = true
  }

  function setQuery(text) {
    query = String(text || "")
    // Editing the box takes the panel back to the library, where the same text
    // filters what is already saved; the online search is a deliberate step
    // past that, taken from the row at the bottom of the list.
    if (mode === "results") {
      mode = "library"
      results = []
      searchError = ""
    }
  }

  function search() {
    var wanted = String(query || "").trim()
    if (!wanted || searchProc.running) return
    mode = "results"
    results = []
    searchError = ""
    searching = true
    searchProc.command = Model.searchCommand(wanted)
    searchProc.running = true
  }

  function clearSearch() {
    query = ""
    mode = "library"
    results = []
    searchError = ""
  }

  Process {
    id: probeProc
    running: false
    command: []
    stdout: StdioCollector { id: probeOut; waitForEnd: true }
    onExited: function(exitCode) {
      root.running = exitCode === 0 && Model.parseRunning(probeOut.text)
      if (!root.running) {
        root.stations = []
        return
      }
      root.list()
    }
  }

  Process {
    id: listProc
    running: false
    command: []
    stdout: StdioCollector { id: listOut; waitForEnd: true }
    stderr: StdioCollector { id: listErr; waitForEnd: true }
    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.listError = Model.errorText(listErr.text, "Could not read the station library")
        return
      }
      root.listError = ""
      root.stations = Model.parseStations(listOut.text)
    }
  }

  Process {
    id: actionProc
    running: false
    command: []
    stderr: StdioCollector { id: actionErr; waitForEnd: true }
    onExited: function(exitCode) {
      if (exitCode !== 0) root.lastError = Model.errorText(actionErr.text, "Goodvibes refused that")
      // Add and Remove change the library, and Play may resolve a bare uri to a
      // station name, so the list is re-read either way.
      root.list()
    }
  }

  Process {
    id: daemonProc
    running: false
    command: []
    stderr: StdioCollector { id: daemonErr; waitForEnd: true }
    onExited: function(exitCode) {
      var next = root._afterStart
      var stopping = root._stoppingDaemon
      root._afterStart = null
      root._stoppingDaemon = false

      if (exitCode !== 0) {
        root.lastError = Model.errorText(daemonErr.text,
          stopping ? "Could not stop the radio player" : "Could not start the radio player")
        if (!stopping) root.running = false
        return
      }

      if (stopping) {
        root.running = false
        root.stations = []
        root.listError = ""
        return
      }

      // systemctl returns as soon as the unit is active, which is before
      // Goodvibes has claimed its bus name; settle waits that out.
      settle.pendingAction = next
      settle.attempts = 0
      settle.restart()
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
        root.searchError = Model.errorText(searchErr.text, "The radio browser did not answer")
        return
      }
      root.results = Model.parseSearch(searchOut.text)
    }
  }

  // Polls the bus name after a start, then runs whatever was waiting on it.
  Timer {
    id: settle
    property var pendingAction: null
    property int attempts: 0
    interval: 150
    repeat: false
    onTriggered: {
      settleProbe.command = Model.probeCommand()
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
        if (settle.attempts < 20) {
          settle.restart()
          return
        }
        settle.pendingAction = null
        root.lastError = "The radio player did not come up"
        return
      }
      var action = settle.pendingAction
      settle.pendingAction = null
      root.list()
      if (action) action()
    }
  }
}
