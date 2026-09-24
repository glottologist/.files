import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

// One widget for both halves of "what is playing": the transport at the top
// drives whichever MPRIS player the shell has settled on -- Spotify, a browser
// tab, Goodvibes itself -- and the list below it is the internet-radio library
// Goodvibes keeps, with the radio-browser database a keystroke away.
//
// Nothing here duplicates the shell's own media service. The hero and the
// transport buttons call into omnixy.media, which already knows how to pick
// the right player out of several and how to show an OSD for the action.
Panel {
  id: root
  moduleName: "omnixy.media-radio"
  ipcTarget: "omnixy.media-radio"
  manageIpc: false

  readonly property var mediaService: bar && bar.shell ? bar.shell.firstPartyServiceFor("omnixy.media") : null
  readonly property var activePlayer: mediaService ? mediaService.activePlayer : null
  readonly property bool hasMedia: !!activePlayer && !!(activePlayer.trackTitle || activePlayer.trackArtist)
  readonly property bool mediaPlaying: !!activePlayer && !!activePlayer.isPlaying
  readonly property string trackTitle: activePlayer ? String(activePlayer.trackTitle || "") : ""
  readonly property string trackArtist: activePlayer ? String(activePlayer.trackArtist || "") : ""
  readonly property string trackAlbum: activePlayer ? String(activePlayer.trackAlbum || "") : ""
  readonly property string trackArt: activePlayer ? String(activePlayer.trackArtUrl || "") : ""
  readonly property string sourceName: activePlayer ? String(activePlayer.identity || activePlayer.desktopEntry || "") : ""

  readonly property int maxTitleChars: setting("maxTitleChars", 28)
  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  readonly property string icon: "󰐹"
  readonly property string towerIcon: "󰐻"
  readonly property string playIcon: "󰐊"
  readonly property string pauseIcon: "󰏤"
  readonly property string nextIcon: "󰒭"
  readonly property string previousIcon: "󰒮"
  readonly property string stopIcon: "󰓛"
  readonly property string musicIcon: "󰝚"
  readonly property string searchIcon: "󰍉"
  readonly property string addIcon: "󰐕"
  readonly property string removeIcon: "󰆴"
  readonly property string powerIcon: "󰐥"

  property int cursorRow: -1
  property bool cursorActive: false

  readonly property var rows: Model.panelRows({
    running: radio.running,
    starting: radio.busy && !radio.running,
    stations: radio.stations,
    results: radio.results,
    query: radio.query,
    mode: radio.mode,
    searching: radio.searching,
    searchError: radio.searchError,
    listError: radio.listError,
    playingStation: radio.playing ? radio.playingStation : ""
  })

  function ensureCursor() {
    if (cursorRow >= 0 && cursorRow < rows.length && Model.isCursorRow(rows[cursorRow])) return
    cursorRow = Model.stepCursor(rows, -1, 1)
  }

  function moveCursor(dx, dy) {
    cursorActive = true
    if (dy === 0) return
    var next = Model.stepCursor(rows, cursorRow, dy)
    if (next === -1) return
    cursorRow = next
    scrollCursorIntoView()
  }

  function setCursor(index) {
    cursorActive = true
    cursorRow = index
    scrollCursorIntoView()
  }

  function rowAt(index) {
    return index >= 0 && index < rows.length ? rows[index] : null
  }

  function activateCursor() {
    activateRow(rowAt(cursorRow))
  }

  function activateRow(row) {
    if (!row) return
    if (row.kind === "station") radio.play(row.station.name)
    else if (row.kind === "result") radio.play(row.station.uri)
    else if (row.kind === "search") radio.search()
    else if (row.kind === "start" && !radio.busy) radio.startDaemon()
  }

  // The destructive-looking key on a row: a saved station is forgotten, a
  // search result is saved. Both are the row's one secondary action, so they
  // share the key and the trailing button.
  function secondaryForRow(row) {
    if (!row) return
    if (row.kind === "station") radio.removeStation(row.station.name)
    else if (row.kind === "result" && !row.known) radio.addStation(row.station.uri, Model.suggestedName(row.station))
  }

  function focusSearch() {
    cursorActive = false
    searchField.forceActiveFocus()
    searchField.selectAll()
  }

  function leaveSearch() {
    keyCatcher.forceActiveFocus()
    cursorActive = true
    ensureCursor()
    scrollCursorIntoView()
  }

  function scrollItemIntoView(item) {
    if (!panelFlick || !item) return
    Qt.callLater(function() {
      if (!item) return
      var margin = Style.space(6)
      var point = item.mapToItem(panelFlick.contentItem, 0, 0)
      var top = point.y
      var bottom = top + item.height
      var viewTop = panelFlick.contentY
      var viewBottom = viewTop + panelFlick.height
      var maxY = Math.max(0, panelFlick.contentHeight - panelFlick.height)
      if (top < viewTop + margin) panelFlick.contentY = Math.max(0, top - margin)
      else if (bottom > viewBottom - margin) panelFlick.contentY = Math.min(maxY, bottom + margin - panelFlick.height)
    })
  }

  function scrollCursorIntoView() {
    if (rowColumn && cursorRow >= 0 && cursorRow < rowColumn.children.length)
      scrollItemIntoView(rowColumn.children[cursorRow])
  }

  function transport(action) {
    if (mediaService) mediaService.runAction(action, false)
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onOpenedChanged: if (opened) {
    cursorActive = false
    cursorRow = -1
    if (panelFlick) panelFlick.contentY = 0
    radio.refresh()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }
  onCursorRowChanged: scrollCursorIntoView()

  Service {
    id: radio
  }

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { radio.refresh(); return "ok" }
    function play(station: string): string { radio.play(station); return "ok" }
    function stop(): string { radio.stop(); return "ok" }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: Model.barLabel(root.icon, root.trackTitle, root.trackArtist, root.maxTitleChars)
    tooltipText: Model.barTooltip(root.trackTitle, root.trackArtist, root.sourceName)
    foreground: root.hasMedia ? root.barForeground : Qt.darker(root.barForeground, 1.55)
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.MiddleButton) root.transport("playPause")
      else if (buttonCode === Qt.RightButton) radio.refresh()
      else root.toggle()
    }
    onWheelMoved: function(delta) {
      root.transport(delta > 0 ? "previous" : "next")
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(420))
    contentHeight: panel.fittedContentHeight(column.implicitHeight, Style.space(620))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: searchField.activeFocus
      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive) { root.cursorActive = true; root.ensureCursor(); return }
        root.moveCursor(dx, dy)
      }
      onActivateRequested: if (root.cursorActive) root.activateCursor()
      onDeleteRequested: if (root.cursorActive) root.secondaryForRow(root.rowAt(root.cursorRow))
      onCloseRequested: {
        if (radio.mode === "results" || radio.query !== "") radio.clearSearch()
        else root.close()
      }
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "/") root.focusSearch()
        else if (t === "p") root.transport("playPause")
        else if (t === "n") root.transport("next")
        else if (t === "b") root.transport("previous")
      }

      Flickable {
        id: panelFlick
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
          id: column
          width: panelFlick.width
          spacing: Style.space(12)

          PanelHero {
            width: parent.width
            title: root.trackTitle !== "" ? root.trackTitle : (root.hasMedia ? root.trackArtist : "Nothing playing")
            meta: root.hasMedia ? Model.heroMeta(root.trackArtist, root.trackAlbum) : "No player is running"
            detail: root.sourceName
            foreground: root.foreground
            fontFamily: root.fontFamily
            iconComponent: Component {
              BorderSurface {
                width: Style.space(56)
                height: Style.space(56)
                radius: Style.spacing.labelGap
                color: Style.normalFillFor(root.foreground, Color.accent)
                borderSpec: Border.controlSpec("normal", root.foreground, Color.accent)

                Image {
                  anchors.fill: parent
                  anchors.margins: Style.space(2)
                  fillMode: Image.PreserveAspectCrop
                  asynchronous: true
                  source: root.trackArt
                  visible: root.trackArt !== ""
                }

                Text {
                  textFormat: Text.PlainText
                  anchors.centerIn: parent
                  visible: root.trackArt === ""
                  text: radio.playing ? root.towerIcon : root.musicIcon
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.display
                }
              }
            }
          }

          Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Style.space(6)

            Button {
              iconText: root.previousIcon
              tooltipText: "Previous"
              foreground: root.foreground
              enabled: !!root.activePlayer && root.activePlayer.canGoPrevious
              opacity: enabled ? 1.0 : 0.4
              onClicked: root.transport("previous")
            }

            Button {
              iconText: root.mediaPlaying ? root.pauseIcon : root.playIcon
              tooltipText: root.mediaPlaying ? "Pause" : "Play"
              foreground: root.foreground
              enabled: !!root.activePlayer
              opacity: enabled ? 1.0 : 0.4
              onClicked: root.transport("playPause")
            }

            Button {
              iconText: root.nextIcon
              tooltipText: "Next"
              foreground: root.foreground
              enabled: !!root.activePlayer && root.activePlayer.canGoNext
              opacity: enabled ? 1.0 : 0.4
              onClicked: root.transport("next")
            }

            // A live stream has nothing to pause into, so the radio gets a stop
            // of its own rather than borrowing the play/pause button.
            Button {
              iconText: root.stopIcon
              tooltipText: "Stop the radio"
              foreground: root.foreground
              visible: radio.playing
              onClicked: radio.stop()
            }
          }

          Text {
            textFormat: Text.PlainText
            visible: radio.lastError !== ""
            width: parent.width
            text: radio.lastError
            color: root.urgent
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            wrapMode: Text.WordWrap
          }

          PanelSeparator { foreground: root.foreground }

          Row {
            width: parent.width
            spacing: Style.space(6)

            TextField {
              id: searchField
              width: parent.width - clearButton.width - powerButton.width - Style.space(12)
              anchors.verticalCenter: parent.verticalCenter
              foreground: root.foreground
              placeholderText: "Filter stations, or search the radio browser"
              text: radio.query
              onTextEdited: radio.setQuery(text)

              Connections {
                target: radio
                function onQueryChanged() {
                  if (searchField.text !== radio.query) searchField.text = radio.query
                }
              }
              Keys.onDownPressed: root.leaveSearch()
              Keys.onEscapePressed: root.leaveSearch()
              onAccepted: {
                if (radio.query.trim() === "") return
                radio.search()
                root.leaveSearch()
              }
            }

            PanelActionButton {
              id: clearButton
              anchors.verticalCenter: parent.verticalCenter
              iconText: "󰅖"
              tooltipText: "Clear"
              foreground: root.foreground
              visible: radio.query !== "" || radio.mode === "results"
              onClicked: {
                radio.clearSearch()
                root.leaveSearch()
              }
            }

            PanelActionButton {
              id: powerButton
              anchors.verticalCenter: parent.verticalCenter
              iconText: root.powerIcon
              tooltipText: radio.running ? "Stop the radio player" : "Start the radio player"
              foreground: radio.running ? root.foreground : root.dim
              hoverColor: radio.running ? root.urgent : root.foreground
              enabled: !radio.busy
              onClicked: radio.running ? radio.stopDaemon() : radio.startDaemon()
            }
          }

          Column {
            id: rowColumn
            width: parent.width
            spacing: Style.space(4)

            Repeater {
              model: root.rows
              Item {
                id: rowItem
                required property var modelData
                required property int index
                readonly property string kind: modelData.kind
                width: rowColumn.width
                implicitHeight: kind === "section" ? sectionRow.implicitHeight
                              : kind === "empty" ? emptyRow.implicitHeight
                              : actionRow.implicitHeight

                SectionRow {
                  id: sectionRow
                  visible: rowItem.kind === "section"
                  width: parent.width
                  row: rowItem.modelData
                  first: rowItem.index === 0
                }

                EmptyRow {
                  id: emptyRow
                  visible: rowItem.kind === "empty"
                  width: parent.width
                  row: rowItem.modelData
                }

                ActionRow {
                  id: actionRow
                  visible: rowItem.kind !== "section" && rowItem.kind !== "empty"
                  width: parent.width
                  row: rowItem.modelData
                  rowIndex: rowItem.index
                }
              }
            }
          }
        }
      }
    }
  }

  component SectionRow: Item {
    property var row: ({})
    property bool first: false

    implicitHeight: sectionHeader.implicitHeight + (first ? 0 : Style.space(10))

    PanelSectionHeader {
      id: sectionHeader
      text: row.title || ""
      foreground: root.foreground
      fontFamily: root.fontFamily
      anchors.left: parent.left
      anchors.bottom: parent.bottom
    }

    PanelSectionHeader {
      text: String(row.count === undefined ? "" : row.count)
      foreground: root.foreground
      fontFamily: root.fontFamily
      anchors.right: parent.right
      anchors.bottom: parent.bottom
    }
  }

  component EmptyRow: Item {
    property var row: ({})

    implicitHeight: emptyText.implicitHeight + Style.space(4)

    Text {
      id: emptyText
      textFormat: Text.PlainText
      width: parent.width
      text: row.text || ""
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      wrapMode: Text.WordWrap
      horizontalAlignment: Text.AlignHCenter
    }
  }

  // One row type covers a saved station, a search result and the two standalone
  // actions: they differ only in the glyph, the second line and what the
  // trailing button does.
  component ActionRow: CursorSurface {
    id: actionRow
    property var row: ({})
    property int rowIndex: -1
    readonly property string kind: row ? String(row.kind || "") : ""
    readonly property var station: row && row.station ? row.station : null
    readonly property bool isStation: kind === "station"
    readonly property bool isResult: kind === "result"
    readonly property bool playingHere: isStation && row.playing === true

    readonly property string glyph: isStation || isResult ? root.towerIcon
                                  : (kind === "search" ? root.searchIcon : root.powerIcon)
    readonly property string primary: station ? station.name : String(row.text || "")
    readonly property string secondary: isStation ? Model.stationMeta(station, playingHere)
                                      : (isResult ? (station.meta || Model.hostOf(station.uri)) : "")
    readonly property string secondaryGlyph: isStation ? root.removeIcon : (isResult && !row.known ? root.addIcon : "")

    hasCursor: root.cursorActive && root.cursorRow === rowIndex
    current: playingHere
    foreground: root.foreground

    implicitHeight: rowLabels.implicitHeight + Style.spacing.rowPaddingX

    MouseArea {
      id: rowMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: root.setCursor(actionRow.rowIndex)
      onClicked: root.activateRow(actionRow.row)
    }

    RowLayout {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(6)
      spacing: Style.space(8)

      Text {
        textFormat: Text.PlainText
        text: actionRow.playingHere ? root.playIcon : actionRow.glyph
        color: actionRow.playingHere ? Color.accent : root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
        Layout.alignment: Qt.AlignVCenter
      }

      ColumnLayout {
        id: rowLabels
        Layout.fillWidth: true
        spacing: Style.space(1)

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: actionRow.primary
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          visible: actionRow.secondary !== ""
          text: actionRow.secondary
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }

      Text {
        textFormat: Text.PlainText
        visible: actionRow.isResult && actionRow.row.known === true
        text: "Saved"
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        Layout.alignment: Qt.AlignVCenter
      }

      PanelActionButton {
        visible: actionRow.secondaryGlyph !== ""
        iconText: actionRow.secondaryGlyph
        tooltipText: actionRow.isStation ? "Remove from the library" : "Save to the library"
        foreground: root.foreground
        hoverColor: actionRow.isStation ? root.urgent : root.foreground
        enabled: !radio.busy
        Layout.alignment: Qt.AlignVCenter
        onClicked: root.secondaryForRow(actionRow.row)
      }
    }
  }
}
