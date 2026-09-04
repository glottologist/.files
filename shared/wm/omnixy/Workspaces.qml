import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// Workspace switcher for the Omnixy bar, replacing omnixy.workspaces.
// Upstream's widget seeds ids 1-5 and ignores anything above 10, but the
// classic keybindings this session replays cover twenty-two workspaces
// (SUPER+1..9, SUPER+0 for ten, SUPER+F1..F12 for eleven to twenty-two).
// Only workspaces that exist are shown, which is how classic's waybar
// behaves, so the bar stays narrow until the higher ones are in use.
BarWidget {
  id: root

  readonly property int maxWorkspace: 22

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  // The focused workspace is added explicitly: Hyprland drops an empty
  // workspace from its list the moment the last window leaves it, and a bar
  // that hid the workspace you are standing on would read as a glitch.
  function workspaceIds() {
    var ids = []
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= root.maxWorkspace && ids.indexOf(id) === -1) ids.push(id)
    }

    var focused = Hyprland.focusedWorkspace
    if (focused !== null && focused.id > 0 && focused.id <= root.maxWorkspace
        && ids.indexOf(focused.id) === -1) ids.push(focused.id)

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : Math.max(1, root.workspaceIds().length)
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

        bar: root.bar
        text: focused ? "󱓻" : String(modelData)
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        // Workspaces ten and up are two digits wide, so the fixed slot
        // upstream uses for single digits would clip them.
        fixedWidth: root.vertical ? root.barSize : Style.space(modelData >= 10 ? 26 : 20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
