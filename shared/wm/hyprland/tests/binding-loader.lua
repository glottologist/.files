local source = debug.getinfo(1, "S").source:sub(2)
local directory = source:match("(.*/)")
local loader_path = directory .. "../binding-loader.lua"

local registered = {}
local dispatched = {}
local real_print = print

local function action(name)
    return function(value)
        if value == nil then return name end
        return name .. ":" .. tostring(value)
    end
end

hl = {
    bind = function(keys, dispatcher, options)
        registered[#registered + 1] = {
            keys = keys,
            dispatcher = dispatcher,
            options = options or {},
        }
    end,
    dispatch = function(dispatcher)
        dispatched[#dispatched + 1] = dispatcher
    end,
    dsp = {
        exec_cmd = action("exec"),
        layout = action("layout"),
        exit = action("exit"),
        focus = action("focus"),
        window = {
            close = action("close"),
            pseudo = action("pseudo"),
            fullscreen = action("fullscreen"),
            float = action("float"),
            move = action("move"),
            swap = action("swap"),
            cycle_next = action("cycle_next"),
            bring_to_top = action("bring_to_top"),
            drag = action("drag"),
            resize = action("resize"),
        },
        workspace = {
            toggle_special = action("toggle_special"),
        },
    },
}

local loader = dofile(loader_path)
local catalog = {
    bind = {
        {
            binding = "ALT,Tab,cyclenext";
            group = "Windows";
            description = "Focus next window";
        },
        {
            binding = "ALT,Tab,bringactivetotop";
            group = "Windows";
            description = "Bring active window to top";
        },
        {
            binding = "SUPER,K,exec,list-keybinds";
            group = "Utilities";
            description = "Keybindings";
        },
        {
            binding = "SUPER,1,workspace,1";
            group = "Workspaces";
            description = "Switch to workspace 1";
        },
    },
    bindm = {
        {
            binding = "SUPER,mouse:272,movewindow";
            group = "Windows";
            description = "Move window";
        },
    },
}

loader.register(catalog, {
    exec_overrides = {
        ["list-keybinds"] = function() return "read-only-viewer" end,
    },
})

assert(#registered == 4, "expected one registration per chord")

local function find(keys)
    for _, value in ipairs(registered) do
        if value.keys == keys then return value end
    end
    error("missing registration for " .. keys)
end

local alt_tab = find("ALT + Tab")
assert(alt_tab.options.description == "[Windows] Focus next window / Bring active window to top")
alt_tab.dispatcher()
assert(dispatched[1] == "cycle_next")
assert(dispatched[2] == "bring_to_top")

local viewer = find("SUPER + K")
assert(viewer.dispatcher == "read-only-viewer")
assert(viewer.options.description == "[Utilities] Keybindings")

local mouse = find("SUPER + mouse:272")
assert(mouse.options.mouse == true)
assert(mouse.options.description == "[Windows] Move window")

local direct_options = { locked = true }
loader.bind("Print", "Capture", "Screenshot", "screenshot", direct_options)
local direct = find("Print")
assert(direct.options.locked == true)
assert(direct.options.description == "[Capture] Screenshot")
assert(direct_options.description == nil, "bind must not mutate caller options")

local before_unknown = #registered
local messages = {}
print = function(message) messages[#messages + 1] = message end
loader.register({
    bind = {
        {
            binding = "SUPER,Z,unknown,argument";
            group = "Utilities";
            description = "Unknown";
        },
    },
    bindm = {},
})
print = real_print
assert(#registered == before_unknown, "unknown dispatcher must be omitted")
assert(messages[1]:match("unknown"))

local ok, message = pcall(loader.register, {
    bind = {
        {
            binding = "SUPER,X,exec,first";
            group = "Applications";
            description = "First";
        },
        {
            binding = "SUPER,X,exec,second";
            group = "Utilities";
            description = "Second";
        },
    },
    bindm = {},
})
assert(not ok)
assert(message:match("SUPER %+ X"))
assert(message:match("Applications"))
assert(message:match("Utilities"))

if arg[1] then
    registered = {}
    loader.register(dofile(arg[1]))
    assert(#registered == 132, "full catalog must register every unique chord")
    for _, value in ipairs(registered) do
        assert(value.options.description:match("^%[[^]]+%] .+"))
    end
end

print("binding-loader: ok")
