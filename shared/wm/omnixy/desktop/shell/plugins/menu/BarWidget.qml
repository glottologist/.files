import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "omnixy.menu"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    // The NixOS logo from the bar's Nerd Font, as on the classic desktop's
    // launcher, in place of the upstream logo glyph from the icon font.
    text: "\uf313"
    horizontalMargin: 7.5
    onPressed: function(button) {
      if (!root.bar) return
      if (button === Qt.RightButton) root.bar.run("xdg-terminal-exec")
      else root.bar.run("omnixy-shell shell toggle omnixy.menu '{\"menu\":\"root\"}'")
    }
  }
}
