import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

// Pushover unread badge for the Omnixy bar, replacing waybar's
// custom/pushover module. The pushover-bridge daemon owns the counter
// file; this widget only reads it, and clearing writes the same zero the
// daemon itself starts from. Mounted from shell.json as a custom qml
// module (settings.source), so the bar injects bar/moduleName/settings
// through the BarWidget base. The file watch replaces waybar's
// RTMIN-signal mechanism: the daemon's write is the notification.
BarWidget {
  id: root

  property int unread: 0
  readonly property string stateFile:
    (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/pushover/unread"

  visible: unread > 0
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function clear() {
    Quickshell.execDetached(
      ["bash", "-c", 'mkdir -p "$(dirname "$0")" && printf "0\\n" >"$0"', root.stateFile])
  }

  FileView {
    id: stateView
    path: root.stateFile
    watchChanges: true
    printErrors: false
    onLoaded: {
      var n = parseInt(String(text()).trim(), 10)
      root.unread = isNaN(n) || n < 0 ? 0 : n
    }
    onLoadFailed: root.unread = 0
    onFileChanged: reload()
  }

  // The watch cannot see the counter's first creation when the shell
  // starts before the daemon's directory exists; this poll is only that
  // backstop.
  Timer {
    interval: 60000
    running: true
    repeat: true
    onTriggered: stateView.reload()
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: " " + root.unread
    tooltipText: root.unread + " unread Pushover alert(s) — click to clear"
    onPressed: root.clear()
  }
}
