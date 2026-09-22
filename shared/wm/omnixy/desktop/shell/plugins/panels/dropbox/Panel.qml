import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root
  moduleName: "omnixy.dropbox"
  ipcTarget: "omnixy.dropbox"
  manageIpc: false

  property string omnixyPath: Quickshell.env("OMNIXY_PATH")
  property string focusSection: "login"
  property int fileIndex: 0
  property bool cursorActive: false
  // "overview" is the status + recent files page; "settings" holds selective
  // sync, bandwidth, LAN sync and autostart. Escape steps back to the overview
  // before it closes the panel.
  property string view: "overview"
  // Cursor key on the settings page: "up", "folder:<n>", "downLimit",
  // "downRate", "upLimit", "upRate", "lansync" or "autostart".
  property string settingsCursor: ""
  // "download" or "upload" while a rate field owns the keyboard.
  property string editingRate: ""
  readonly property bool inSettings: view === "settings"
  readonly property bool atBrowseRoot: dropbox.browsePath === "" || dropbox.browsePath === dropbox.rootPath
  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property color iconColor: dropbox.authenticated && dropbox.active ? foreground : dim
  readonly property string toggleHint: dropbox.active ? "Pause syncing" : "Resume syncing"
  readonly property color barIconColor: dropbox.authenticated && dropbox.active ? barForeground : Qt.darker(barForeground, 1.55)
  // Only claim the header cursor when the switch is actually on screen —
  // "header" stays navigable, but an absent CLI leaves nothing to highlight.
  readonly property bool headerHasCursor: cursorActive && !inSettings && focusSection === "header" && dropbox.installed

  function ensureCursor() {
    if (!dropbox.authenticated) {
      focusSection = "login"
      fileIndex = 0
      return
    }
    if (dropbox.files.length === 0) {
      focusSection = "header"
      fileIndex = 0
      return
    }
    if (focusSection !== "files" && focusSection !== "header") focusSection = "files"
    if (fileIndex >= dropbox.files.length) fileIndex = Math.max(0, dropbox.files.length - 1)
    if (fileIndex < 0) fileIndex = 0
  }

  function moveCursor(dx, dy) {
    cursorActive = true
    if (inSettings) {
      moveSettingsCursor(dx, dy)
      return
    }
    ensureCursor()
    if (dy === 0) return
    if (focusSection === "header") {
      if (dy > 0 && dropbox.files.length > 0) {
        focusSection = "files"
        fileIndex = 0
        scrollCursorIntoView()
      }
      return
    }
    if (focusSection === "files") {
      if (dy < 0 && fileIndex === 0) {
        setHeaderCursor()
        return
      }
      fileIndex = Math.max(0, Math.min(dropbox.files.length - 1, fileIndex + dy))
      scrollCursorIntoView()
    }
  }

  function setHeaderCursor() {
    cursorActive = true
    focusSection = "header"
    if (panelFlick) panelFlick.contentY = 0
  }

  function toggleRunning() {
    if (dropbox.installed && !dropbox.busy) dropbox.toggleRunning()
  }

  function activateCursor() {
    if (inSettings) {
      ensureSettingsCursor()
      activateSettings(settingsCursor)
      return
    }
    ensureCursor()
    if (focusSection === "login") dropbox.login()
    else if (focusSection === "header") toggleRunning()
    else if (focusSection === "files") dropbox.openFile(selectedFile())
  }

  function showSettings() {
    view = "settings"
    cursorActive = false
    settingsCursor = ""
    editingRate = ""
    if (panelFlick) panelFlick.contentY = 0
    dropbox.browse(dropbox.browsePath || dropbox.rootPath)
  }

  function showOverview() {
    view = "overview"
    cursorActive = false
    editingRate = ""
    if (panelFlick) panelFlick.contentY = 0
    Qt.callLater(function() { if (keyCatcher) keyCatcher.forceActiveFocus() })
  }

  function toggleView() {
    if (inSettings) showOverview()
    else showSettings()
  }

  // Every cursor stop on the settings page, top to bottom, so vertical
  // movement is one index step regardless of which rows are showing.
  function settingsTargets() {
    var targets = []
    if (!atBrowseRoot) targets.push("up")
    for (var i = 0; i < dropbox.browseFolders.length; i++) targets.push("folder:" + i)
    targets.push("downLimit")
    if (dropbox.bandwidth.downloadMode === "manual") targets.push("downRate")
    targets.push("upLimit")
    if (dropbox.bandwidth.uploadMode === "manual") targets.push("upRate")
    targets.push("lansync")
    if (dropbox.autostart.managed === "desktop") targets.push("autostart")
    return targets
  }

  function ensureSettingsCursor() {
    var targets = settingsTargets()
    if (targets.length === 0) {
      settingsCursor = ""
      return
    }
    if (targets.indexOf(settingsCursor) < 0) settingsCursor = targets[0]
  }

  function setSettingsCursor(key) {
    cursorActive = true
    settingsCursor = key
  }

  function cursorFolder() {
    var match = /^folder:(\d+)$/.exec(settingsCursor)
    if (!match) return null
    var index = parseInt(match[1], 10)
    return index >= 0 && index < dropbox.browseFolders.length ? dropbox.browseFolders[index] : null
  }

  function moveSettingsCursor(dx, dy) {
    ensureSettingsCursor()
    if (dx !== 0) {
      var onBrowser = settingsCursor === "up" || settingsCursor.indexOf("folder:") === 0
      if (!onBrowser) return
      if (dx < 0 && !atBrowseRoot) dropbox.browseUp()
      else if (dx > 0) dropbox.browseInto(cursorFolder())
      return
    }
    if (dy === 0) return
    var targets = settingsTargets()
    var index = targets.indexOf(settingsCursor)
    settingsCursor = targets[Math.max(0, Math.min(targets.length - 1, index + dy))]
  }

  function activateSettings(key) {
    if (dropbox.settingsBusy) return
    if (key === "up") dropbox.browseUp()
    else if (key.indexOf("folder:") === 0) {
      var folder = cursorFolder()
      if (folder) dropbox.setFolderSynced(folder, folder.excluded === true)
    }
    else if (key === "downLimit") dropbox.setBandwidth({ downloadMode: dropbox.bandwidth.downloadMode === "manual" ? "unlimited" : "manual" })
    else if (key === "downRate") startEditingRate("download")
    else if (key === "upLimit") dropbox.setBandwidth({ uploadMode: Model.nextUploadMode(dropbox.bandwidth.uploadMode) })
    else if (key === "upRate") startEditingRate("upload")
    else if (key === "lansync") dropbox.setLanSync(!dropbox.lanSync)
    else if (key === "autostart") dropbox.setAutostart(!dropbox.autostart.enabled)
  }

  function rateField(which) {
    return which === "download" ? downRateRow.field : upRateRow.field
  }

  function startEditingRate(which) {
    editingRate = which
    setSettingsCursor(which === "download" ? "downRate" : "upRate")
    var field = rateField(which)
    Qt.callLater(function() {
      field.text = String(which === "download" ? dropbox.bandwidth.downloadLimit : dropbox.bandwidth.uploadLimit)
      field.selectAll()
      field.forceActiveFocus()
    })
  }

  function cancelEditingRate() {
    editingRate = ""
    Qt.callLater(function() { if (keyCatcher) keyCatcher.forceActiveFocus() })
  }

  function commitRate() {
    var which = editingRate
    if (which === "") return
    var value = parseInt(rateField(which).text, 10)
    cancelEditingRate()
    if (!isFinite(value) || value <= 0) return
    dropbox.setBandwidth(which === "download" ? { downloadLimit: value } : { uploadLimit: value })
  }

  function selectedFile() {
    if (dropbox.files.length === 0) return null
    return dropbox.files[Math.max(0, Math.min(fileIndex, dropbox.files.length - 1))]
  }

  function setFileCursor(index) {
    cursorActive = true
    focusSection = "files"
    fileIndex = index
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
    if (focusSection === "files" && fileColumn && fileIndex >= 0 && fileIndex < fileColumn.children.length) {
      scrollItemIntoView(fileColumn.children[fileIndex])
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onOpenedChanged: if (opened) {
    cursorActive = false
    view = "overview"
    editingRate = ""
    if (panelFlick) panelFlick.contentY = 0
    dropbox.refresh()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }
  onFileIndexChanged: scrollCursorIntoView()

  Service {
    id: dropbox
    settings: root.settings
    omnixyPath: root.omnixyPath
  }

  Connections {
    target: dropbox
    function onAuthenticatedChanged() { root.ensureCursor() }
    function onFilesChanged() { root.ensureCursor() }
    function onBrowseFoldersChanged() { if (root.inSettings && root.cursorActive) root.ensureSettingsCursor() }
  }

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { dropbox.refresh(); return "ok" }
    function settings(): void { root.open(); root.showSettings() }
    function login(): string { dropbox.login(); return "ok" }
    function status(): string { return dropbox.statusText }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    iconComponent: Component {
      Item {
        DropboxIcon {
          anchors.centerIn: parent
          iconSize: Style.space(12)
          color: root.barIconColor
          opacity: dropbox.active ? 1.0 : 0.6
        }
      }
    }
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) dropbox.refresh()
      else if (buttonCode === Qt.MiddleButton) dropbox.login()
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
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(column.implicitHeight, Style.space(560))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: root.editingRate !== ""
      onMoveRequested: function(dx, dy) {
        if (!root.cursorActive) { root.cursorActive = true; return }
        root.moveCursor(dx, dy)
      }
      onActivateRequested: if (root.cursorActive) root.activateCursor()
      onCloseRequested: if (root.inSettings) root.showOverview(); else root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (t === "r" || t === "R") {
          dropbox.refresh()
          if (root.inSettings) dropbox.browse(dropbox.browsePath)
        }
        else if (t === "l" || t === "L") dropbox.login()
        else if (t === "p" || t === "P") root.toggleRunning()
        else if (t === "s" || t === "S") root.toggleView()
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

          Item {
            id: header
            visible: dropbox.authenticated && !root.inSettings
            width: parent.width
            implicitHeight: hero.implicitHeight
            // Exposed for the hero's trailingControl, whose `root` resolves to
            // PanelHero (not this Panel) — reach panel state via `header`.
            readonly property bool ringVisible: root.headerHasCursor
            function focusHero() { root.setHeaderCursor() }

            PanelHero {
              id: hero
              width: parent.width
              title: "Dropbox"
              meta: dropbox.active ? dropbox.statusText : "Syncing paused"
              foreground: root.foreground
              fontFamily: root.fontFamily
              iconOpacity: dropbox.active ? 1.0 : 0.5
              // Status only — the switch owns toggling, mouse and keyboard alike.
              iconComponent: Component {
                DropboxIcon {
                  iconSize: Style.font.display
                  color: root.iconColor
                }
              }

              // Compact on/off switch on the trailing edge of the hero, and the
              // header's only cursor target. The service already flips `active`
              // optimistically, so the knob throws the instant you click it.
              trailingControl: Component {
                Row {
                  visible: dropbox.installed
                  spacing: Style.space(10)

                  PanelActionButton {
                    iconText: "󰒓"
                    tooltipText: "Settings (s)"
                    foreground: hero.foreground
                    fontFamily: hero.fontFamily
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: root.showSettings()
                  }

                  ToggleSwitch {
                    id: powerSwitch
                    anchors.verticalCenter: parent.verticalCenter
                    checked: dropbox.active
                    busy: dropbox.busy
                    hasCursor: header.ringVisible
                    foreground: hero.foreground
                    onHovered: function(on) { if (on) header.focusHero() }
                    onToggled: root.toggleRunning()

                    PanelToolTip {
                      visible: powerSwitch.containsMouse
                      text: root.toggleHint
                      fontFamily: hero.fontFamily
                    }
                  }
                }
              }
            }
          }

          Text {
            textFormat: Text.PlainText
            visible: dropbox.actionStatus !== "" || dropbox.lastError !== ""
            width: parent.width
            text: dropbox.actionStatus !== "" ? dropbox.actionStatus : dropbox.lastError
            color: dropbox.lastError !== "" && dropbox.actionStatus === "" ? root.urgent : root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            wrapMode: Text.WordWrap
          }

          LoginButton {
            visible: !dropbox.authenticated && !root.inSettings
            width: parent.width
          }

          Column {
            visible: dropbox.authenticated && !root.inSettings
            width: parent.width
            spacing: Style.spacing.labelGap

            Column {
              width: parent.width
              spacing: Style.spacing.labelGap
              InfoPair { label: "Stored"; value: Model.usageText(dropbox.usedBytes, dropbox.quotaBytes, dropbox.quotaKnown) }
            }
          }

          PanelSeparator {
            visible: dropbox.authenticated && !root.inSettings
            foreground: root.foreground
          }

          Column {
            visible: dropbox.authenticated && !root.inSettings
            width: parent.width
            spacing: Style.space(10)

            PanelSectionHeader {
              text: "RECENT FILES"
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            Text {
              visible: dropbox.files.length === 0
              width: parent.width
              text: "No synced files found."
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
              horizontalAlignment: Text.AlignHCenter
            }

            Column {
              id: fileColumn
              visible: dropbox.files.length > 0
              width: parent.width
              spacing: Style.space(6)

              Repeater {
                model: dropbox.files
                FileRow {
                  required property var modelData
                  required property int index
                  width: fileColumn.width
                  file: modelData
                  rowIndex: index
                }
              }
            }
          }

          // ---- Settings page -------------------------------------------------

          PanelHero {
            id: settingsHero
            visible: root.inSettings
            width: parent.width
            title: "Settings"
            meta: "Dropbox"
            foreground: root.foreground
            fontFamily: root.fontFamily
            iconComponent: Component {
              DropboxIcon {
                iconSize: Style.font.display
                color: root.iconColor
              }
            }
            trailingControl: Component {
              PanelActionButton {
                iconText: "󰁍"
                tooltipText: "Back (Esc)"
                foreground: settingsHero.foreground
                fontFamily: settingsHero.fontFamily
                onClicked: root.showOverview()
              }
            }
          }

          Column {
            visible: root.inSettings
            width: parent.width
            spacing: Style.space(10)

            PanelSectionHeader {
              text: "SYNC FOLDERS"
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            Text {
              textFormat: Text.PlainText
              width: parent.width
              text: Model.relativeFolder(dropbox.browsePath, dropbox.rootPath)
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              elide: Text.ElideMiddle
            }

            Text {
              textFormat: Text.PlainText
              visible: dropbox.browseError !== ""
              width: parent.width
              text: dropbox.browseError
              color: root.urgent
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              wrapMode: Text.WordWrap
            }

            Text {
              visible: !dropbox.running && dropbox.installed
              width: parent.width
              text: "Start Dropbox to change which folders sync."
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              wrapMode: Text.WordWrap
            }

            SettingRow {
              visible: !root.atBrowseRoot
              width: parent.width
              cursorKey: "up"
              glyph: "󰅁"
              label: ".."
              description: "Up one folder"
            }

            Text {
              visible: dropbox.browseFolders.length === 0 && !dropbox.browsing && dropbox.browseError === ""
              width: parent.width
              text: "No folders here."
              color: root.dim
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
              horizontalAlignment: Text.AlignHCenter
            }

            Column {
              id: folderColumn
              width: parent.width
              spacing: Style.space(6)

              Repeater {
                model: dropbox.browseFolders
                FolderRow {
                  required property var modelData
                  required property int index
                  width: folderColumn.width
                  folder: modelData
                  rowIndex: index
                }
              }
            }

            PanelSeparator { foreground: root.foreground }

            PanelSectionHeader {
              text: "BANDWIDTH"
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            SettingRow {
              width: parent.width
              cursorKey: "downLimit"
              label: "Limit download rate"
              description: Model.bandwidthLabel(dropbox.bandwidth.downloadMode, dropbox.bandwidth.downloadLimit)
              showSwitch: true
              checked: dropbox.bandwidth.downloadMode === "manual"
            }

            RateRow {
              id: downRateRow
              visible: dropbox.bandwidth.downloadMode === "manual"
              width: parent.width
              which: "download"
              cursorKey: "downRate"
              label: "Download rate"
            }

            SettingRow {
              width: parent.width
              cursorKey: "upLimit"
              label: "Upload rate"
              description: "Unlimited, automatic or a fixed rate"
              valueText: Model.bandwidthLabel(dropbox.bandwidth.uploadMode, dropbox.bandwidth.uploadLimit) + " 󰅂"
            }

            RateRow {
              id: upRateRow
              visible: dropbox.bandwidth.uploadMode === "manual"
              width: parent.width
              which: "upload"
              cursorKey: "upRate"
              label: "Upload rate"
            }

            PanelSeparator { foreground: root.foreground }

            PanelSectionHeader {
              text: "NETWORK"
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            SettingRow {
              width: parent.width
              cursorKey: "lansync"
              label: "LAN sync"
              description: dropbox.lanSyncRecorded ? "Sync directly over this network" : "Dropbox default; not read back"
              showSwitch: true
              checked: dropbox.lanSync
            }

            PanelSeparator { foreground: root.foreground }

            PanelSectionHeader {
              text: "STARTUP"
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            SettingRow {
              width: parent.width
              cursorKey: "autostart"
              label: "Start at login"
              description: dropbox.autostart.managed === "systemd" ? "systemd user service, declared in NixOS" : "Desktop autostart entry"
              showSwitch: dropbox.autostart.managed === "desktop"
              checked: dropbox.autostart.enabled
              valueText: dropbox.autostart.managed === "systemd" ? "systemd" : ""
              interactive: dropbox.autostart.managed === "desktop"
            }
          }
        }
      }
    }
  }

  // Generic settings row: label + description, and on the trailing edge either
  // a switch (`showSwitch`) or a value caption. The row owns the click, as the
  // kit's `Toggle` does, so the switch itself is not interactive.
  component SettingRow: CursorSurface {
    id: settingRow
    property string cursorKey: ""
    property string glyph: ""
    property string label: ""
    property string description: ""
    property string valueText: ""
    property bool showSwitch: false
    property bool checked: false
    property bool interactive: true

    hasCursor: root.cursorActive && root.inSettings && root.settingsCursor === cursorKey
    foreground: root.foreground
    implicitHeight: settingContent.implicitHeight + Style.spacing.rowPaddingX

    onHasCursorChanged: if (hasCursor) root.scrollItemIntoView(settingRow)

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: settingRow.interactive && !dropbox.settingsBusy ? Qt.PointingHandCursor : Qt.ArrowCursor
      onEntered: if (settingRow.interactive) root.setSettingsCursor(settingRow.cursorKey)
      onClicked: if (settingRow.interactive) root.activateSettings(settingRow.cursorKey)
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
        visible: settingRow.glyph !== ""
        text: settingRow.glyph
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
        Layout.alignment: Qt.AlignVCenter
      }

      ColumnLayout {
        id: settingContent
        Layout.fillWidth: true
        spacing: Style.space(1)

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: settingRow.label
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          visible: settingRow.description !== ""
          Layout.fillWidth: true
          text: settingRow.description
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }

      Text {
        textFormat: Text.PlainText
        visible: !settingRow.showSwitch && settingRow.valueText !== ""
        text: settingRow.valueText
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        Layout.alignment: Qt.AlignVCenter
      }

      ToggleSwitch {
        visible: settingRow.showSwitch
        interactive: false
        checked: settingRow.checked
        busy: dropbox.settingsBusy
        hasCursor: settingRow.hasCursor
        foreground: root.foreground
        Layout.alignment: Qt.AlignVCenter
      }
    }
  }

  // One folder in the sync browser. The row toggles sync; the chevron on the
  // right (or l / Right) descends into a synced folder.
  component FolderRow: CursorSurface {
    id: folderRow
    property var folder: null
    property int rowIndex: 0
    readonly property string cursorKey: "folder:" + rowIndex
    readonly property bool excluded: folder ? folder.excluded === true : false
    readonly property string folderName: folder ? String(folder.name || "Untitled") : "Untitled"

    hasCursor: root.cursorActive && root.inSettings && root.settingsCursor === cursorKey
    foreground: root.foreground
    implicitHeight: folderContent.implicitHeight + Style.spacing.rowPaddingX

    onHasCursorChanged: if (hasCursor) root.scrollItemIntoView(folderRow)

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: dropbox.settingsBusy ? Qt.ArrowCursor : Qt.PointingHandCursor
      onEntered: root.setSettingsCursor(folderRow.cursorKey)
      onClicked: root.activateSettings(folderRow.cursorKey)
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
        text: folderRow.excluded ? "󰉖" : "󰉋"
        color: root.foreground
        opacity: folderRow.excluded ? 0.5 : 1.0
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
        Layout.alignment: Qt.AlignVCenter
      }

      ColumnLayout {
        id: folderContent
        Layout.fillWidth: true
        spacing: Style.space(1)

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: folderRow.folderName
          color: root.foreground
          opacity: folderRow.excluded ? 0.6 : 1.0
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: Model.folderMeta(folderRow.folder)
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }

      ToggleSwitch {
        interactive: false
        checked: !folderRow.excluded
        busy: dropbox.settingsBusy
        hasCursor: folderRow.hasCursor
        foreground: root.foreground
        Layout.alignment: Qt.AlignVCenter
      }

      PanelActionButton {
        iconText: "󰅂"
        tooltipText: "Open folder (l)"
        foreground: root.foreground
        fontFamily: root.fontFamily
        // Keep the slot so the switches line up; an excluded folder has no
        // local tree to open.
        opacity: folderRow.excluded ? 0 : 1
        enabled: !folderRow.excluded && !dropbox.browsing
        Layout.alignment: Qt.AlignVCenter
        onClicked: dropbox.browseInto(folderRow.folder)
      }
    }
  }

  // Inline KB/s editor for one throttle direction. Activating the row hands
  // the keyboard to the field (the key catcher is blocked meanwhile); Enter
  // applies the rate, Escape abandons it.
  component RateRow: CursorSurface {
    id: rateRow
    property string which: "download"
    property string cursorKey: ""
    property string label: ""
    readonly property alias field: rateField
    readonly property int currentLimit: which === "download" ? dropbox.bandwidth.downloadLimit : dropbox.bandwidth.uploadLimit

    hasCursor: root.cursorActive && root.inSettings && root.settingsCursor === cursorKey
    foreground: root.foreground
    implicitHeight: rateContent.implicitHeight + Style.spacing.rowPaddingX

    onHasCursorChanged: if (hasCursor) root.scrollItemIntoView(rateRow)

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: root.setSettingsCursor(rateRow.cursorKey)
      onClicked: root.startEditingRate(rateRow.which)
    }

    RowLayout {
      id: rateContent
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      spacing: Style.space(8)

      Text {
        textFormat: Text.PlainText
        Layout.fillWidth: true
        text: rateRow.label
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        elide: Text.ElideRight
      }

      TextField {
        id: rateField
        width: Style.space(90)
        foreground: root.foreground
        font.family: root.fontFamily
        horizontalAlignment: TextInput.AlignRight
        text: String(rateRow.currentLimit)
        validator: IntValidator { bottom: 1; top: 100000000 }
        inputMethodHints: Qt.ImhDigitsOnly
        Layout.alignment: Qt.AlignVCenter
        onActiveFocusChanged: if (activeFocus && root.editingRate === "") root.startEditingRate(rateRow.which)
        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_Escape) {
            root.cancelEditingRate()
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.commitRate()
            event.accepted = true
          }
        }
      }

      Text {
        textFormat: Text.PlainText
        text: "KB/s"
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        Layout.alignment: Qt.AlignVCenter
      }
    }
  }

  component LoginButton: CursorSurface {
    id: loginButton

    hasCursor: root.cursorActive && root.focusSection === "login"
    foreground: root.foreground

    implicitHeight: loginRow.implicitHeight + Style.spacing.rowPaddingX

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: dropbox.installed && !dropbox.busy ? Qt.PointingHandCursor : Qt.ArrowCursor
      enabled: dropbox.installed && !dropbox.busy
      onEntered: {
        root.cursorActive = true
        root.focusSection = "login"
      }
      onClicked: dropbox.login()
    }

    RowLayout {
      id: loginRow
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      spacing: Style.space(8)

      Text {
        text: ""
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.heading
        Layout.alignment: Qt.AlignVCenter
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.space(1)

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: dropbox.installed ? "Login to Dropbox" : "Dropbox CLI is not installed"
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: dropbox.installed ? "Start the authentication flow" : "Install Dropbox from the service menu"
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }

      PanelActionButton {
        iconText: "󰌋"
        foreground: root.foreground
        fontFamily: root.fontFamily
        enabled: dropbox.installed && !dropbox.busy
        Layout.alignment: Qt.AlignVCenter
        onClicked: dropbox.login()
      }
    }
  }

  component FileRow: CursorSurface {
    id: fileRow
    property var file: null
    property int rowIndex: 0
    readonly property string fileName: file ? String(file.name || "Untitled") : "Untitled"

    hasCursor: root.cursorActive && root.focusSection === "files" && root.fileIndex === rowIndex
    foreground: root.foreground

    implicitHeight: fileContent.implicitHeight + Style.spacing.rowPaddingX

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: root.setFileCursor(fileRow.rowIndex)
      onClicked: dropbox.openFile(fileRow.file)
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
        text: Model.fileGlyph(fileRow.fileName)
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.icon
        Layout.alignment: Qt.AlignVCenter
      }

      ColumnLayout {
        id: fileContent
        Layout.fillWidth: true
        spacing: Style.space(1)

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: fileRow.fileName
          color: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
        }

        Text {
          textFormat: Text.PlainText
          Layout.fillWidth: true
          text: Model.fileMeta(fileRow.file)
          color: root.dim
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
        }
      }
    }
  }

  component InfoPair: Row {
    property string label: ""
    property string value: ""

    width: parent.width
    spacing: Style.space(8)

    InfoLabel { text: label }
    Item { width: Math.max(0, parent.width - parent.children[0].implicitWidth - parent.children[2].implicitWidth - parent.spacing * 2); height: 1 }
    InfoValue { text: value }
  }

  component InfoLabel: Text {
    textFormat: Text.PlainText
    color: root.foreground
    opacity: 0.6
    font.family: root.fontFamily
    font.pixelSize: Style.font.bodySmall
  }

  component InfoValue: Text {
    textFormat: Text.PlainText
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: Style.font.bodySmall
    elide: Text.ElideRight
  }
}
