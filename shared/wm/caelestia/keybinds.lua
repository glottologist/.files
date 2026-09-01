local fn = require("utils.functions")
local classic = require("classic-binds")
local loader = dofile(os.getenv("HOME") .. "/.config/hypr/binding-loader.lua")

-- Shell-native replacements for daemons that do not run in this session.
local exec_overrides = {
    ["swaync-client -rs"] = function() return hl.dsp.global("caelestia:clearNotifs") end,
    ["hyprlock"] = function() return hl.dsp.global("caelestia:lock") end,
    ["pypr toggle term"] = function() return fn.toggle("specialws") end,
    ["wallsetter"] = function() return hl.dsp.exec_cmd("caelestia wallpaper -r") end,
}

loader.register(classic, { exec_overrides = exec_overrides })

local locked = { locked = true }
local release = { release = true }
local repeating = { repeating = true }

loader.bind("SUPER + SUPER_L", "Shell", "Launcher", hl.dsp.global("caelestia:launcher"), release)
loader.bind("CTRL + ALT + Delete", "Session", "Session menu", hl.dsp.global("caelestia:session"))
loader.bind("SUPER + N", "Shell", "Sidebar", hl.dsp.global("caelestia:sidebar"))
loader.bind(
    "CTRL + ALT + C",
    "Notifications",
    "Clear notifications",
    hl.dsp.global("caelestia:clearNotifs"),
    locked
)

-- These chords avoid inherited swap-window and reminder bindings.
loader.bind("CTRL + SUPER + L", "Session", "Restart shell and lock", function()
    hl.dispatch(hl.dsp.exec_cmd("caelestia shell -d"))
    hl.dispatch(hl.dsp.global("caelestia:lock"))
end)
loader.bind(
    "CTRL + SUPER + ALT + SHIFT + R",
    "Session",
    "Restart shell",
    hl.dsp.exec_cmd("qs -c caelestia kill; sleep .1; caelestia shell -d"),
    release
)

loader.bind("Print", "Capture", "Screenshot", hl.dsp.exec_cmd("caelestia screenshot"), locked)
loader.bind(
    "SUPER + SHIFT + S",
    "Capture",
    "Frozen screenshot",
    hl.dsp.global("caelestia:screenshotFreeze")
)
loader.bind(
    "SUPER + SHIFT + ALT + S",
    "Capture",
    "Screenshot menu",
    hl.dsp.global("caelestia:screenshot")
)
loader.bind(
    "SUPER + Period",
    "Utilities",
    "Emoji picker",
    hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p")
)

loader.bind("SUPER + Comma", "Windows", "Toggle window group", hl.dsp.group.toggle())
loader.bind("SUPER + SHIFT + Comma", "Windows", "Lock window group", hl.dsp.group.lock_active())
loader.bind(
    "SUPER + U",
    "Windows",
    "Move window out of group",
    hl.dsp.window.move({ out_of_group = true })
)
loader.bind("CTRL + SHIFT + Escape", "Utilities", "System monitor", fn.toggle("sysmon"))

loader.bind(
    "CTRL + SUPER + Space",
    "Media",
    "Play or pause",
    hl.dsp.global("caelestia:mediaToggle"),
    locked
)
loader.bind(
    "CTRL + SUPER + Equal",
    "Media",
    "Next track",
    hl.dsp.global("caelestia:mediaNext"),
    locked
)
loader.bind(
    "CTRL + SUPER + Minus",
    "Media",
    "Previous track",
    hl.dsp.global("caelestia:mediaPrev"),
    locked
)
loader.bind(
    "CTRL + SUPER + Backspace",
    "Media",
    "Stop playback",
    hl.dsp.global("caelestia:mediaStop"),
    locked
)
loader.bind(
    "SUPER + SHIFT + M",
    "Media",
    "Mute audio",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    locked
)

loader.bind(
    "SUPER + Minus",
    "Windows",
    "Shrink window width",
    fn.resize_active_window(-10, 0),
    repeating
)
loader.bind(
    "SUPER + Equal",
    "Windows",
    "Grow window width",
    fn.resize_active_window(10, 0),
    repeating
)
loader.bind(
    "SUPER + SHIFT + Minus",
    "Windows",
    "Shrink window height",
    fn.resize_active_window(0, -10),
    repeating
)
loader.bind(
    "SUPER + SHIFT + Equal",
    "Windows",
    "Grow window height",
    fn.resize_active_window(0, 10),
    repeating
)

loader.bind("CTRL + SUPER + Backslash", "Windows", "Center window", hl.dsp.window.center())
loader.bind("CTRL + SUPER + ALT + Backslash", "Windows", "Resize and center window", function()
    hl.dispatch(hl.dsp.window.resize(fn.resize_by_screen(55, 70)))
    hl.dispatch(hl.dsp.window.center())
end)
loader.bind("SUPER + ALT + Backslash", "Windows", "Toggle picture-in-picture", function()
    local active = hl.get_active_window()
    if not active then return end

    local actions = fn.move_actions(active) or {}
    if not active.floating then table.insert(actions, 1, hl.dsp.window.float()) end
    table.insert(actions, hl.dsp.window.pin({ action = "on", window = "address:" .. active.address }))

    for _, action in ipairs(actions) do
        hl.dispatch(action)
    end
end)
