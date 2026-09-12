import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "custom.meshtastic"
  ipcTarget: "custom.meshtastic"

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property string icon: "󰐻"
  readonly property var clients: [
    { name: "Meshtastic", detail: "Native graphical client", command: ["@client@"] },
    { name: "MeshCore", detail: "CLI with Bluetooth / USB device selector",
      command: ["@terminal@", "-e", "@meshcore@"] }
  ]
  property int selectedClient: 0

  function launchClient(index) {
    if (index < 0 || index >= clients.length) return
    Quickshell.execDetached(clients[index].command)
    close()
  }

  function moveSelection(direction) {
    selectedClient = (selectedClient + direction + clients.length) % clients.length
  }

  onOpenedChanged: if (opened) selectedClient = 0

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.icon
    onPressed: root.toggle()
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(340))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onActivateRequested: root.launchClient(root.selectedClient)
      onMoveRequested: function(dx, dy) { if (dy !== 0) root.moveSelection(dy) }
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        width: parent.width
        spacing: Style.space(16)

        PanelHero {
          width: parent.width
          title: "Mesh"
          meta: "Meshtastic and MeshCore"
          foreground: root.foreground
          fontFamily: root.fontFamily
        }

        Repeater {
          model: root.clients

          Column {
            required property int index
            required property var modelData
            width: column.width
            spacing: Style.space(6)

            Button {
              width: parent.width
              text: "Open " + modelData.name
              iconText: root.icon
              foreground: root.foreground
              fontFamily: root.fontFamily
              bordered: true
              hasCursor: keyCatcher.activeFocus && root.selectedClient === index
              onHovered: function(hovered) { if (hovered) root.selectedClient = index }
              onClicked: root.launchClient(index)
            }

            Text {
              width: parent.width
              text: modelData.detail
              textFormat: Text.PlainText
              wrapMode: Text.WordWrap
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
            }
          }
        }
      }
    }
  }
}
