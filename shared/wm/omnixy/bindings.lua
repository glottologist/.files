local classic = require("omnixy-cfg.classic-binds")
local loader = dofile(os.getenv("HOME") .. "/.config/hypr/binding-loader.lua")

local exec_overrides = {
    ["omarchy-menu"] = function() return hl.dsp.exec_cmd("omnixy-menu toggle") end,
    ["rofi-launcher"] = function() return hl.dsp.exec_cmd("omnixy-menu toggle apps") end,
    ["wlogout --css ~/.config/wlogout/main.css"] = function()
        return hl.dsp.exec_cmd("omnixy-menu toggle system")
    end,
    ["hyprlock"] = function() return hl.dsp.exec_cmd("omnixy-system-lock") end,
    ["swaync-client -rs"] = function()
        return hl.dsp.exec_cmd("omnixy-shell notifications showHistory")
    end,
    ["wallsetter"] = function() return hl.dsp.exec_cmd("omnixy-menu toggle background") end,
    ["emopicker9000"] = function() return hl.dsp.exec_cmd("omnixy-menu-emoji") end,
    ["screenshootin"] = function() return hl.dsp.exec_cmd("omnixy-capture-screenshot") end,
    ["gpu-screen-recorder-gtk"] = function()
        return hl.dsp.exec_cmd("omnixy-capture-screenrecording")
    end,
    ["cliphist list | rofi -dmenu | cliphist decode | wl-copy"] = function()
        return hl.dsp.exec_cmd("omnixy-menu-clipboard")
    end,
    -- Spawn the dropdown once; [k] prevents pgrep matching this command itself.
    ["pypr toggle term"] = function()
        return hl.dsp.exec_cmd([[bash -c "pgrep -f '[k]itty --class kitty-dropterm' >/dev/null || hyprctl dispatch -- exec 'kitty --class kitty-dropterm'; hyprctl dispatch togglespecialworkspace term"]])
    end,
    -- upstream freezes the screen with hyprpicker before the region select, so
    -- the capture sees a still frame; classic's grim+slurp OCRs whatever the
    -- screen was doing while you dragged.
    ["ocr-clip"] = function() return hl.dsp.exec_cmd("omnixy-capture-text") end,
    -- Reads the live binds and understands the Lua dispatchers this session
    -- registers, so it renders the replayed classic bindings correctly.
    ["list-keybinds"] = function() return hl.dsp.exec_cmd("omnixy-menu-keybindings") end,
    ["desktop-reminder set"] = function() return hl.dsp.exec_cmd("omnixy-reminder -i") end,
    ["desktop-reminder list"] = function() return hl.dsp.exec_cmd("omnixy-reminder show") end,
    ["desktop-reminder clear"] = function() return hl.dsp.exec_cmd("omnixy-reminder clear") end,
}

o.window("kitty-dropterm", {
    workspace = "special:term",
    float = true,
    center = true,
    size = { "(monitor_w*7/10)", "(monitor_h*7/10)" },
})

loader.register(classic, { exec_overrides = exec_overrides })
