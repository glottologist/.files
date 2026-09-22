import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import "Model.js" as Model

Item {
  id: root

  property var settings: ({})
  property string omnixyPath: Quickshell.env("OMNIXY_PATH")

  property bool installed: false
  property bool running: false
  property bool authenticated: false

  // Optimistic sync state so the UI reacts the instant you click, rather than
  // waiting for dropboxd to actually settle. _desired is -1 while we just
  // follow the real state, or 0/1 while a pause/resume is still catching up.
  property int _desired: -1
  readonly property bool active: _desired === -1 ? running : (_desired === 1)
  property bool refreshing: false
  property string statusText: "Checking…"
  property string accountPath: ""
  property string plan: ""
  property double usedBytes: 0
  property double quotaBytes: 0
  property double usagePercent: 0
  property bool quotaKnown: false
  property var files: []
  property string actionStatus: ""
  property string lastError: ""

  // Settings read back from the daemon on every refresh (see status.py).
  property string rootPath: ""
  property var excluded: []
  property var bandwidth: Model.normaliseBandwidth(null)
  property bool lanSync: true
  property bool lanSyncRecorded: false
  property var autostart: Model.normaliseAutostart(null)

  // Selective-sync browser: the folder being shown and its entries.
  property string browsePath: ""
  property var browseFolders: []
  property string browseError: ""
  readonly property bool browsing: foldersProcess.running
  readonly property bool settingsBusy: settingsProcess.running

  readonly property int refreshIntervalSec: intSetting("refreshIntervalSec", 60, 10, 3600)
  readonly property bool busy: statusProcess.running || loginProcess.running || controlProcess.running
  readonly property string helperPath: (omnixyPath || "") + "/shell/plugins/panels/dropbox/status.py"

  property string _statusOutput: ""
  property string _statusError: ""
  property string _loginOutput: ""
  property string _loginError: ""
  property bool _loginUrlOpened: false
  property string _controlOutput: ""
  property string _controlError: ""
  property string _foldersOutput: ""
  property string _foldersError: ""
  property string _settingsOutput: ""
  property string _settingsError: ""
  property bool _settingsReloadFolders: false

  function setting(name, fallback) {
    var value = settings ? settings[name] : undefined
    return value === undefined || value === null ? fallback : value
  }

  function intSetting(name, fallback, min, max) {
    var n = parseInt(String(setting(name, fallback)), 10)
    if (!isFinite(n)) n = fallback
    if (n < min) n = min
    if (n > max) n = max
    return n
  }

  function refresh() {
    if (statusProcess.running || helperPath === "/shell/plugins/panels/dropbox/status.py") return
    _statusOutput = ""
    _statusError = ""
    refreshing = true
    statusProcess.command = ["python3", helperPath, "25"]
    statusProcess.running = true
  }

  function applyStatus(raw) {
    var parsed = Model.parseStatus(raw)
    if (!parsed.ok) {
      lastError = parsed.lastError || "Failed to read Dropbox status"
      return
    }
    installed = parsed.installed === true
    running = parsed.running === true
    authenticated = parsed.authenticated === true
    // Reality caught up to the pending pause/resume — stop overriding.
    if (_desired !== -1 && running === (_desired === 1)) _desired = -1
    statusText = String(parsed.statusText || (installed ? "Stopped" : "Not installed"))
    accountPath = String(parsed.accountPath || "")
    plan = String(parsed.plan || "")
    usedBytes = Number(parsed.usedBytes || 0)
    quotaBytes = Number(parsed.quotaBytes || 0)
    usagePercent = Number(parsed.usagePercent || 0)
    quotaKnown = parsed.quotaKnown === true
    files = parsed.files || []
    rootPath = parsed.rootPath
    excluded = parsed.excluded
    bandwidth = parsed.bandwidth
    lanSync = parsed.lanSync
    lanSyncRecorded = parsed.lanSyncRecorded
    autostart = parsed.autostart
    if (browsePath === "" && rootPath !== "") browsePath = rootPath
    lastError = ""
  }

  function browse(path) {
    if (foldersProcess.running || helperPath === "/shell/plugins/panels/dropbox/status.py") return
    var target = String(path || browsePath || rootPath)
    if (target === "") return
    browsePath = target
    _foldersOutput = ""
    _foldersError = ""
    foldersProcess.command = ["python3", helperPath, "folders", target]
    foldersProcess.running = true
  }

  function browseUp() {
    browse(Model.parentPath(browsePath, rootPath))
  }

  function browseInto(folder) {
    if (!folder || !folder.path || folder.excluded) return
    browse(String(folder.path))
  }

  function applyFolders(raw) {
    var parsed = Model.parseFolders(raw)
    if (!parsed.ok) {
      browseError = parsed.error
      return
    }
    browseError = ""
    browsePath = parsed.path
    browseFolders = parsed.folders
  }

  function setFolderSynced(folder, synced) {
    if (!folder || !folder.path) return
    var name = String(folder.name || folder.path)
    runSettings(["dropbox-cli", "exclude", synced ? "remove" : "add", String(folder.path)],
                (synced ? "Syncing " : "Excluding ") + name + "…", true)
  }

  function setBandwidth(patch) {
    var next = {
      known: true,
      downloadMode: bandwidth.downloadMode,
      uploadMode: bandwidth.uploadMode,
      downloadLimit: bandwidth.downloadLimit,
      uploadLimit: bandwidth.uploadLimit
    }
    for (var key in patch) next[key] = patch[key]
    next = Model.normaliseBandwidth(next)
    var args = Model.throttleArgs(next)
    if (!runSettings(["dropbox-cli", "throttle", args[0], args[1]], "Setting bandwidth…", false)) return
    bandwidth = next
  }

  function setLanSync(enabled) {
    if (!runSettings(["python3", helperPath, "lansync", enabled ? "y" : "n"], enabled ? "Enabling LAN sync…" : "Disabling LAN sync…", false)) return
    lanSync = enabled
    lanSyncRecorded = true
  }

  function setAutostart(enabled) {
    if (autostart.managed !== "desktop") return
    if (!runSettings(["dropbox-cli", "autostart", enabled ? "y" : "n"], enabled ? "Enabling autostart…" : "Disabling autostart…", false)) return
    autostart = { managed: "desktop", enabled: enabled }
  }

  // dropbox-cli exits 0 even when the daemon refuses, so the result is judged
  // on its text: "isn't running", "isn't responding", "Couldn't …" and the
  // helper's {"ok": false} all count as failure.
  function settingsFailed(exitCode, output) {
    if (exitCode !== 0) return true
    var text = String(output || "")
    return /isn't|Couldn't|Could not|"ok":\s*false/.test(text)
  }

  function runSettings(command, label, reloadFolders) {
    if (!installed || settingsProcess.running) return false
    _settingsOutput = ""
    _settingsError = ""
    _settingsReloadFolders = reloadFolders
    actionStatus = label
    settingsProcess.command = command
    settingsProcess.running = true
    return true
  }

  function elideStatus(text) {
    var value = String(text || "").replace(/\s+/g, " ").trim()
    return value.length > 140 ? value.substring(0, 137) + "…" : value
  }

  function login() {
    if (!installed || loginProcess.running) return
    _loginOutput = ""
    _loginError = ""
    _loginUrlOpened = false
    actionStatus = "Starting Dropbox login…"
    loginProcess.command = ["dropbox-cli", "start"]
    loginProcess.running = true
  }

  function pause() {
    runControl(["dropbox-cli", "stop"], 0)
  }

  function resume() {
    runControl(["dropbox-cli", "start"], 1)
  }

  function toggleRunning() {
    if (active) pause()
    else resume()
  }

  function runControl(command, desired) {
    // No progress status here — the greyed icon and hero phrase already convey
    // the pause/resume; only surface a message if the command fails.
    if (!installed || controlProcess.running) return
    _desired = desired
    _controlOutput = ""
    _controlError = ""
    controlProcess.command = command
    controlProcess.running = true
  }

  function openFile(file) {
    if (!file || !file.path) return
    Quickshell.execDetached(["uwsm-app", "--", "nautilus", "--select", fileUri(String(file.path))])
  }

  function fileUri(path) {
    var parts = String(path || "").split("/")
    for (var i = 0; i < parts.length; i++) parts[i] = encodeURIComponent(parts[i])
    return "file://" + parts.join("/")
  }

  function openAuthUrlFrom(text) {
    if (_loginUrlOpened) return true
    var match = String(text || "").match(/https?:\/\/\S+/)
    if (match && match[0]) {
      _loginUrlOpened = true
      Qt.openUrlExternally(match[0])
      actionStatus = "Opened Dropbox login"
      actionStatusTimer.restart()
      return true
    }
    return false
  }

  function handleLoginOutput(data, isError) {
    var text = String(data || "")
    if (isError) _loginError += text + "\n"
    else _loginOutput += text + "\n"
    openAuthUrlFrom(text)
  }

  Timer {
    id: refreshTimer
    interval: root.refreshIntervalSec * 1000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Timer {
    // After a fresh boot the startup poll usually lands before dropboxd has
    // finished its respawn dance, which left the icon stale until the next
    // periodic refresh. Poll quickly until the daemon shows up, or give up
    // after ~30 seconds.
    id: startupRamp
    property int ticks: 0
    interval: 2000
    repeat: true
    running: true
    onTriggered: {
      ticks += 1
      if (root.running || ticks >= 15) startupRamp.running = false
      else root.refresh()
    }
  }

  Timer {
    id: delayedRefresh
    interval: 1000
    repeat: false
    onTriggered: root.refresh()
  }

  Timer {
    id: actionStatusTimer
    interval: 2200
    repeat: false
    onTriggered: root.actionStatus = ""
  }

  Timer {
    // dropboxd takes a few (variable) seconds to settle after stop/start, so
    // re-poll a handful of times to reflect the new state without waiting for
    // the next periodic refresh.
    id: settleTimer
    property int ticks: 0
    interval: 1500
    repeat: true
    running: false
    onTriggered: {
      settleTimer.ticks += 1
      root.refresh()
      if (settleTimer.ticks >= 4) {
        settleTimer.ticks = 0
        settleTimer.running = false
        root._desired = -1
      }
    }
  }

  Process {
    id: statusProcess
    running: false
    command: []
    stdout: StdioCollector { id: statusStdout; waitForEnd: true; onStreamFinished: root._statusOutput = text }
    stderr: StdioCollector { id: statusStderr; waitForEnd: true; onStreamFinished: root._statusError = text }
    onExited: function(exitCode) {
      root.refreshing = false
      var stdout = String(statusStdout.text || root._statusOutput || "")
      var stderr = String(statusStderr.text || root._statusError || "")
      if (exitCode === 0) root.applyStatus(stdout)
      else root.lastError = root.elideStatus(stderr || stdout || "Could not read Dropbox status")
    }
  }

  Process {
    id: loginProcess
    running: false
    command: []
    stdout: SplitParser { onRead: function(data) { root.handleLoginOutput(data, false) } }
    stderr: SplitParser { onRead: function(data) { root.handleLoginOutput(data, true) } }
    onExited: function(exitCode) {
      var combined = String(root._loginOutput || "") + "\n" + String(root._loginError || "")
      var opened = root.openAuthUrlFrom(combined)
      if (exitCode !== 0 && !opened) {
        root.lastError = root.elideStatus(combined || "Dropbox login failed")
        root.actionStatus = root.lastError
      } else if (!opened) {
        root.actionStatus = ""
        root.lastError = ""
      }
      delayedRefresh.restart()
    }
  }

  Process {
    id: controlProcess
    running: false
    command: []
    stdout: StdioCollector { id: controlStdout; waitForEnd: true; onStreamFinished: root._controlOutput = text }
    stderr: StdioCollector { id: controlStderr; waitForEnd: true; onStreamFinished: root._controlError = text }
    onExited: function(exitCode) {
      var stdout = String(controlStdout.text || root._controlOutput || "")
      var stderr = String(controlStderr.text || root._controlError || "")
      if (exitCode !== 0) {
        root._desired = -1
        root.lastError = root.elideStatus(stderr || stdout || "Dropbox command failed")
        root.actionStatus = root.lastError
      } else {
        root.lastError = ""
        root.actionStatus = ""
      }
      settleTimer.ticks = 0
      settleTimer.restart()
      delayedRefresh.restart()
    }
  }

  Process {
    id: foldersProcess
    running: false
    command: []
    stdout: StdioCollector { id: foldersStdout; waitForEnd: true; onStreamFinished: root._foldersOutput = text }
    stderr: StdioCollector { id: foldersStderr; waitForEnd: true; onStreamFinished: root._foldersError = text }
    onExited: function(exitCode) {
      var stdout = String(foldersStdout.text || root._foldersOutput || "")
      var stderr = String(foldersStderr.text || root._foldersError || "")
      if (exitCode === 0) root.applyFolders(stdout)
      else root.browseError = root.elideStatus(stderr || stdout || "Could not read Dropbox folders")
    }
  }

  Process {
    // One settings write at a time: exclude add/remove, throttle, lansync,
    // autostart. Excluding can take a while because dropboxd resyncs, so the
    // action status stays up until the command returns.
    id: settingsProcess
    running: false
    command: []
    stdout: StdioCollector { id: settingsStdout; waitForEnd: true; onStreamFinished: root._settingsOutput = text }
    stderr: StdioCollector { id: settingsStderr; waitForEnd: true; onStreamFinished: root._settingsError = text }
    onExited: function(exitCode) {
      var stdout = String(settingsStdout.text || root._settingsOutput || "")
      var stderr = String(settingsStderr.text || root._settingsError || "")
      if (root.settingsFailed(exitCode, stdout + "\n" + stderr)) {
        root.lastError = root.elideStatus(stderr || stdout || "Dropbox settings command failed")
        root.actionStatus = root.lastError
      } else {
        root.lastError = ""
        root.actionStatus = ""
      }
      if (root._settingsReloadFolders) root.browse(root.browsePath)
      delayedRefresh.restart()
    }
  }
}
