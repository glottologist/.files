import QtQuick
import qs.Commons

// Omnixy's bar option: two Omarchy bars instead of one, reproducing the
// classic waybar split (a top bar for tray and system readouts, a bottom bar
// for workspaces, window title and status).
//
// The shell mounts exactly one object as `shell.bar`, and its bar engine
// carries a single scalar `position`, so a split cannot be expressed in the
// stock layout. Rather than patch the vendored engine -- 1800 lines upstream
// calls Omarchy-owned and rewrites freely between releases -- this plugin
// instantiates that engine twice and hands each copy its own slice of
// shell.json: the familiar `bar:` subtree drives the top bar, and a new
// `bar.bottom:` subtree drives the bottom one.
Item {
  id: root

  // Injected by the host shell, exactly as for the built-in bar.
  property string omarchyPath: ""
  property var barWidgetRegistry: null
  property var barConfig: null
  property var shell: null
  property var manifest: null

  readonly property string engineUrl: root.omarchyPath === ""
    ? "" : "file://" + root.omarchyPath + "/shell/plugins/bar/Bar.qml"

  property var topBar: null
  property var bottomBar: null

  // The host and the notification service read these off `shell.bar` to
  // anchor panels below the bar. The top bar is the one they mean.
  readonly property int barSize: topBar ? topBar.barSize : 0
  readonly property bool barHidden: topBar ? topBar.barHidden : false
  readonly property string fontFamily: topBar ? topBar.fontFamily : ""
  readonly property string position: topBar ? topBar.position : "top"
  readonly property bool vertical: topBar ? topBar.vertical : false

  function plainObject(value) {
    return Util.isPlainObject(value) ? value : ({})
  }

  function hasModules(layout) {
    if (!Util.isPlainObject(layout)) return false
    var sections = ["left", "center", "right"]
    for (var i = 0; i < sections.length; i++)
      if (Array.isArray(layout[sections[i]]) && layout[sections[i]].length > 0) return true
    return false
  }

  // The stored subtree with a default edge filled in. A drag-to-move gesture
  // writes a new `position` into whichever subtree that bar owns, so both
  // bars stay movable and the default only decides where they start.
  function configFor(subtree, defaultPosition) {
    var source = plainObject(subtree)
    var config = {}
    for (var key in source) config[key] = source[key]
    if (typeof config.position !== "string" || config.position === "")
      config.position = defaultPosition
    return config
  }

  readonly property var topConfig: configFor(root.barConfig, "top")
  readonly property var bottomSubtree: plainObject(root.barConfig).bottom
  readonly property var bottomConfig: configFor(root.bottomSubtree, "bottom")

  // A shell facade for the bottom bar. The bar engine and its widgets reach
  // the shell through this object -- the engine for mutateShellConfig, the
  // widgets for summon and updateEntryInline via bar.shell -- and both of the
  // config-writing calls have to be redirected, or the bottom bar would
  // rewrite the top bar's half of shell.json.
  //
  // mutateShellConfig hands the engine a view of the config whose `bar` is
  // the `bar.bottom` subtree. The engine only ever mutates that object in
  // place (it replaces `config.bar` solely when the key is missing, which the
  // view rules out), so its position, transparency and widget-order edits
  // land in the right half.
  QtObject {
    id: bottomShell

    property var target: root.shell

    function mutateShellConfig(mutator) {
      if (!target || typeof target.mutateShellConfig !== "function") return
      target.mutateShellConfig(function(config) {
        if (!Util.isPlainObject(config.bar)) config.bar = {}
        if (!Util.isPlainObject(config.bar.bottom)) config.bar.bottom = {}
        var view = {}
        for (var key in config) view[key] = config[key]
        view.bar = config.bar.bottom
        mutator(view)
      })
    }

    // The host's own updateEntryInline searches config.bar.layout, so a
    // bottom-bar widget's inline settings would never be found there and
    // would be misfiled into the top-level plugins array. This does the same
    // job through the redirected mutator instead.
    function updateEntryInline(moduleName, settings) {
      var stripped = Util.canonicalWidgetId(moduleName)
      var next = { id: stripped }
      for (var k in settings) if (k !== "id") next[k] = settings[k]

      // Persisting rewrites shell.json and reloads every bar, so establish
      // there is a real change before asking for one.
      if (!root.entryDiffers(root.bottomConfig.layout, stripped, next)) return false

      mutateShellConfig(function(config) {
        if (!Util.isPlainObject(config.bar.layout))
          config.bar.layout = { left: [], center: [], right: [] }
        var sections = ["left", "center", "right"]
        for (var s = 0; s < sections.length; s++) {
          var entries = config.bar.layout[sections[s]]
          if (!Array.isArray(entries)) continue
          for (var i = 0; i < entries.length; i++)
            if (entries[i] && Util.canonicalWidgetId(entries[i].id) === stripped)
              entries[i] = next
        }
      })
      return true
    }

    function summon(pluginId, payloadJson) {
      return target && typeof target.summon === "function"
        ? target.summon(pluginId, payloadJson) : false
    }

    function hide(pluginId) {
      if (target && typeof target.hide === "function") target.hide(pluginId)
    }

    function toggle(pluginId, payloadJson) {
      if (target && typeof target.toggle === "function") target.toggle(pluginId, payloadJson)
    }
  }

  // True when the named entry is absent from the layout, or present with
  // different settings.
  function entryDiffers(layout, id, candidate) {
    if (!Util.isPlainObject(layout)) return true
    var sections = ["left", "center", "right"]
    for (var s = 0; s < sections.length; s++) {
      var entries = layout[sections[s]]
      if (!Array.isArray(entries)) continue
      for (var i = 0; i < entries.length; i++)
        if (entries[i] && Util.canonicalWidgetId(entries[i].id) === id)
          return JSON.stringify(entries[i]) !== JSON.stringify(candidate)
    }
    return false
  }

  // The engine declares omarchyPath, barWidgetRegistry and barConfig as
  // required properties, so they have to be supplied at construction rather
  // than assigned afterwards; that rules out a Loader.
  function createBar(config, shellTarget) {
    if (root.engineUrl === "") return null

    var component = Qt.createComponent(root.engineUrl)
    if (component.status !== Component.Ready) {
      console.warn("omnixy.bar: cannot load the Omarchy bar engine:", component.errorString())
      return null
    }

    return component.createObject(root, {
      omarchyPath: root.omarchyPath,
      barWidgetRegistry: root.barWidgetRegistry,
      barConfig: config,
      shell: shellTarget,
      manifest: root.manifest
    })
  }

  function rebuild() {
    if (topBar) { topBar.destroy(); topBar = null }
    if (bottomBar) { bottomBar.destroy(); bottomBar = null }
    if (root.omarchyPath === "" || !root.barWidgetRegistry) return

    topBar = createBar(root.topConfig, root.shell)
    // No bottom subtree means no second bar, which keeps the plugin usable
    // on a shell.json that has never been seeded with one.
    if (hasModules(root.bottomConfig.layout))
      bottomBar = createBar(root.bottomConfig, bottomShell)
  }

  onOmarchyPathChanged: rebuild()
  onBarWidgetRegistryChanged: rebuild()
  Component.onCompleted: rebuild()

  // shell.json changed on disk. Push the new slices into the live bars, and
  // rebuild only when the bottom bar has appeared or disappeared, since the
  // engine handles a config swap itself.
  onBarConfigChanged: {
    var wantBottom = hasModules(root.bottomConfig.layout)
    if (!topBar || wantBottom !== (bottomBar !== null)) {
      rebuild()
      return
    }

    topBar.barConfig = root.topConfig
    if (bottomBar) bottomBar.barConfig = root.bottomConfig
  }

  // Widget IPC reaches whichever bar hosts the widget, so summon and hide
  // work the same whether the module sits on the top or the bottom bar.
  function summonBarWidget(id) {
    if (topBar && topBar.summonBarWidget(id)) return true
    return bottomBar ? bottomBar.summonBarWidget(id) : false
  }

  function hideBarWidget(id) {
    if (topBar && topBar.hideBarWidget(id)) return true
    return bottomBar ? bottomBar.hideBarWidget(id) : false
  }

  function isBarWidgetOpen(id) {
    if (topBar && topBar.isBarWidgetOpen(id)) return true
    return bottomBar ? bottomBar.isBarWidgetOpen(id) : false
  }

  function panelWidgetIdAt(section, index) {
    var id = topBar ? topBar.panelWidgetIdAt(section, index) : ""
    if (id) return id
    return bottomBar ? bottomBar.panelWidgetIdAt(section, index) : ""
  }

  // `omarchy bar transparent` and the double-click gesture act on both bars,
  // so the pair keeps a single appearance.
  function toggleTransparency() {
    if (topBar) topBar.toggleTransparency()
    if (bottomBar) bottomBar.toggleTransparency()
  }

  function debugBarGeometry() {
    var geometry = topBar ? topBar.debugBarGeometry() : []
    if (bottomBar) geometry = geometry.concat(bottomBar.debugBarGeometry())
    return geometry
  }
}
