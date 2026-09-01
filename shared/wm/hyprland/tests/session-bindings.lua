local source = debug.getinfo(1, "S").source:sub(2)
local root = source:match("(.*/)hyprland/tests/")
local real_dofile = dofile

local function proxy()
    local value = {}
    return setmetatable(value, {
        __index = function() return value end,
        __call = function() return value end,
    })
end

local function read_file(path)
    local file = assert(io.open(path, "r"))
    local content = file:read("*a")
    file:close()
    return content
end

local function run(profile, module_name)
    local registrations = {}
    local additions = {}
    local windows = {}
    local loader = {
        register = function(catalog, options)
            registrations[#registrations + 1] = { catalog = catalog, options = options or {} }
        end,
        bind = function(keys, group, description, action, options)
            additions[#additions + 1] = {
                keys = keys,
                group = group,
                description = description,
                action = action,
                options = options or {},
            }
        end,
    }
    local catalog = { bind = {}, bindm = {} }
    local dynamic = proxy()

    hl = dynamic
    hl.dsp = dynamic
    hl.bind = dynamic
    hl.dispatch = dynamic
    hl.get_active_window = function() return nil end
    o = {
        window = function(name, options)
            windows[#windows + 1] = { name = name, options = options }
        end,
    }

    package.loaded[module_name] = catalog
    package.loaded["classic-binds"] = catalog
    package.loaded["utils.functions"] = dynamic
    dofile = function(path)
        if path:match("binding%-loader%.lua$") then return loader end
        return real_dofile(path)
    end

    local filename = profile == "caelestia" and "keybinds.lua" or "bindings.lua"
    local ok, message = pcall(real_dofile, root .. profile .. "/" .. filename)
    dofile = real_dofile
    assert(ok, message)

    return {
        additions = additions,
        registrations = registrations,
        windows = windows,
    }
end

local function assert_override(result, command)
    local overrides = result.registrations[1].options.exec_overrides
    assert(type(overrides[command]) == "function", "missing override for " .. command)
end

local function assert_addition(result, keys, group, description)
    for _, addition in ipairs(result.additions) do
        if addition.keys == keys then
            assert(addition.group == group, keys .. " has wrong group")
            assert(addition.description == description, keys .. " has wrong description")
            return
        end
    end
    error("missing addition " .. keys)
end

local omarchy = run("omarchy", "omarchy-cfg.classic-binds")
assert(#omarchy.registrations == 1)
assert(omarchy.registrations[1].options.exec_overrides["list-keybinds"] == nil)
assert_override(omarchy, "omarchy-menu")
assert_override(omarchy, "hyprlock")
assert_override(omarchy, "screenshootin")
assert_override(omarchy, "pypr toggle term")

local omnixy = run("omnixy", "omnixy-cfg.classic-binds")
assert(#omnixy.registrations == 1)
assert(omnixy.registrations[1].options.exec_overrides["list-keybinds"] == nil)
assert_override(omnixy, "desktop-reminder set")
assert_override(omnixy, "desktop-reminder list")
assert_override(omnixy, "desktop-reminder clear")
assert(#omnixy.windows == 1)
assert(omnixy.windows[1].name == "kitty-dropterm")

local caelestia = run("caelestia", "classic-binds")
assert(#caelestia.registrations == 1)
assert(#caelestia.additions == 26, "expected all Caelestia additions")
assert_addition(caelestia, "SUPER + SUPER_L", "Shell", "Launcher")
assert_addition(caelestia, "CTRL + ALT + Delete", "Session", "Session menu")
assert_addition(caelestia, "SUPER + N", "Shell", "Sidebar")
assert_addition(caelestia, "CTRL + ALT + C", "Notifications", "Clear notifications")
assert_addition(caelestia, "Print", "Capture", "Screenshot")
assert_addition(caelestia, "SUPER + Period", "Utilities", "Emoji picker")
assert_addition(caelestia, "SUPER + Comma", "Windows", "Toggle window group")
assert_addition(caelestia, "CTRL + SHIFT + Escape", "Utilities", "System monitor")
assert_addition(caelestia, "CTRL + SUPER + Space", "Media", "Play or pause")
assert_addition(caelestia, "SUPER + Minus", "Windows", "Shrink window width")
assert_addition(caelestia, "CTRL + SUPER + Backslash", "Windows", "Center window")

for _, profile in ipairs({ "caelestia", "omarchy", "omnixy" }) do
    local filename = profile == "caelestia" and "keybinds.lua" or "bindings.lua"
    local content = read_file(root .. profile .. "/" .. filename)
    assert(not content:match("local function split_bind"), profile .. " retains copied parser")
    if profile == "caelestia" then
        assert(not content:match("hl%.bind%("), "Caelestia retains a direct permanent bind")
    end
end

print("session-bindings: ok")
