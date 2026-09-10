import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Pull requests opened and merged in the last day, from the record
// omnixy-source-control-record keeps. The panel only ever reads that file: a
// FileView watches it, so a timer run refreshes an open panel by itself, and
// `r` or a right-click on the bar icon asks the recorder for a fresh read now.
Panel {
  id: root
  moduleName: "omnixy.source-control"
  ipcTarget: "omnixy.source-control"
  manageIpc: false

  readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/omnixy"
  readonly property string statePath: stateDir + "/source-control.json"
  property var state: Model.parseState("")
  property var rows: Model.panelRows(state)
  // Stamped on each read and each open rather than ticking: the ages beside
  // the rows describe a record, not a live feed.
  property real nowMs: Date.now()
  property int cursorRow: -1
  property bool cursorActive: false
  property string lastError: ""
  property string _recordError: ""
  readonly property bool refreshing: recordProc.running
  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property string icon: "󰊤"

  function loadState(text) {
    state = Model.parseState(text)
    rows = Model.panelRows(state)
    nowMs = Date.now()
    ensureCursor()
  }

  function ensureCursor() {
    if (cursorRow === -1) return
    if (cursorRow >= rows.length || rows[cursorRow].kind !== "pr") cursorRow = Model.stepCursor(rows, -1, 1)
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

  function activateCursor() {
    if (cursorRow < 0 || cursorRow >= rows.length || rows[cursorRow].kind !== "pr") return
    openPullRequest(rows[cursorRow].pr)
  }

  function openPullRequest(pr) {
    if (!pr || !pr.url) return
    Qt.openUrlExternally(pr.url)
    root.close()
  }

  function refresh() {
    if (recordProc.running) return
    lastError = ""
    _recordError = ""
    recordProc.running = true
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
    if (rowColumn && cursorRow >= 0 && cursorRow < rowColumn.children.length) scrollItemIntoView(rowColumn.children[cursorRow])
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onOpenedChanged: if (opened) {
    cursorActive = false
    nowMs = Date.now()
    if (panelFlick) panelFlick.contentY = 0
    stateFile.reload()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }
  onCursorRowChanged: scrollCursorIntoView()

  // Re-read on change before loading: text() is stale inside the change
  // signal itself, so both paths go through reload → onLoaded.
  FileView {
    id: stateFile
    path: root.statePath
    watchChanges: true
    printErrors: false
    onLoaded: root.loadState(text())
    onFileChanged: reload()
    onLoadFailed: root.loadState("")
  }

  Process {
    id: recordProc
    command: ["omnixy-source-control-record"]
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: root._recordError = text.trim()
    }
    onExited: function(exitCode, exitStatus) {
      if (exitCode !== 0) root.lastError = root._recordError !== "" ? root._recordError : "The recorder failed"
    }
  }

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { root.refresh(); return "ok" }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.icon
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) root.refresh()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(440))
    contentHeight: panel.fittedContentHeight(column.implicitHeight, Style.space(600))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive) { root.cursorActive = true; return }
        root.moveCursor(dx, dy)
      }
      onActivateRequested: if (root.cursorActive) root.activateCursor()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "r" || t === "R") root.refresh()
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
            title: "Source control"
            meta: root.refreshing ? "Refreshing…" : Model.summaryText(root.state)
            detail: Model.updatedText(root.state.time, root.nowMs)
            foreground: root.foreground
            fontFamily: root.fontFamily
            iconComponent: Component {
              Text {
                textFormat: Text.PlainText
                text: root.icon
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.display
              }
            }
          }

          Text {
            textFormat: Text.PlainText
            visible: root.lastError !== ""
            width: parent.width
            text: root.lastError
            color: root.urgent
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            wrapMode: Text.WordWrap
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
                implicitHeight: kind === "pr" ? prRow.implicitHeight
                              : kind === "repo" ? repoRow.implicitHeight
                              : kind === "section" ? sectionRow.implicitHeight
                              : emptyRow.implicitHeight

                SectionRow {
                  id: sectionRow
                  visible: rowItem.kind === "section"
                  width: parent.width
                  row: rowItem.modelData
                  first: rowItem.index === 0
                }

                RepoRow {
                  id: repoRow
                  visible: rowItem.kind === "repo"
                  width: parent.width
                  row: rowItem.modelData
                }

                PullRequestRow {
                  id: prRow
                  visible: rowItem.kind === "pr"
                  width: parent.width
                  pr: rowItem.modelData.pr || null
                  rowIndex: rowItem.index
                }

                EmptyRow {
                  id: emptyRow
                  visible: rowItem.kind === "empty"
                  width: parent.width
                  row: rowItem.modelData
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

  component RepoRow: Item {
    property var row: ({})

    implicitHeight: repoName.implicitHeight + Style.space(6)

    Text {
      id: repoName
      textFormat: Text.PlainText
      anchors.left: parent.left
      anchors.right: repoCounts.left
      anchors.rightMargin: Style.space(8)
      anchors.bottom: parent.bottom
      text: row.repo || ""
      color: root.foreground
      opacity: 0.85
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      font.bold: true
      elide: Text.ElideMiddle
    }

    Text {
      id: repoCounts
      textFormat: Text.PlainText
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      text: Model.repoMeta(row)
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
    }
  }

  component PullRequestRow: CursorSurface {
    id: pullRequestRow
    property var pr: null
    property int rowIndex: -1
    readonly property bool merged: !!pr && Model.stateLabel(pr) === "merged"
    readonly property bool live: !!pr && (Model.stateLabel(pr) === "open" || Model.stateLabel(pr) === "draft")

    hasCursor: root.cursorActive && root.cursorRow === rowIndex
    foreground: root.foreground

    implicitHeight: prContent.implicitHeight + Style.spacing.rowPaddingX

    MouseArea {
      id: pullRequestMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: root.setCursor(pullRequestRow.rowIndex)
      onClicked: root.openPullRequest(pullRequestRow.pr)
    }

    RowLayout {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      spacing: Style.space(8)

      Text {
        textFormat: Text.PlainText
        text: pullRequestRow.pr ? Model.stateGlyph(pullRequestRow.pr) : ""
        color: pullRequestRow.merged ? Color.accent : (pullRequestRow.live ? root.foreground : root.dim)
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
        Layout.alignment: Qt.AlignVCenter

        PanelToolTip {
          visible: pullRequestMouse.containsMouse
          text: pullRequestRow.pr ? Model.stateLabel(pullRequestRow.pr) : ""
          fontFamily: root.fontFamily
        }
      }

      ColumnLayout {
        id: prContent
        Layout.fillWidth: true
        spacing: Style.space(1)

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: pullRequestRow.pr ? Model.prTitle(pullRequestRow.pr) : ""
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: pullRequestRow.pr ? Model.prMeta(pullRequestRow.pr, root.nowMs) : ""
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }
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
}
