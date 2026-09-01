local classic = require("omnixy-cfg.classic-binds")
local loader = dofile(os.getenv("HOME") .. "/.config/hypr/binding-loader.lua")

local exec_overrides = {
    ["omarchy-menu"] = function() return hl.dsp.exec_cmd("omarchy-menu toggle") end,
    ["rofi-launcher"] = function() return hl.dsp.exec_cmd("omarchy-menu toggle apps") end,
    ["wlogout --css ~/.config/wlogout/main.css"] = function()
        return hl.dsp.exec_cmd("omarchy-menu toggle system")
    end,
    ["hyprlock"] = function() return hl.dsp.exec_cmd("omarchy-system-lock") end,
    ["swaync-client -rs"] = function()
        return hl.dsp.exec_cmd("omarchy-shell notifications showHistory")
    end,
    ["wallsetter"] = function() return hl.dsp.exec_cmd("omarchy-menu toggle background") end,
    ["emopicker9000"] = function() return hl.dsp.exec_cmd("omarchy-menu-emoji") end,
    ["screenshootin"] = function() return hl.dsp.exec_cmd("omarchy-capture-screenshot") end,
    ["gpu-screen-recorder-gtk"] = function()
        return hl.dsp.exec_cmd("omarchy-capture-screenrecording")
    end,
    ["cliphist list | rofi -dmenu | cliphist decode | wl-copy"] = function()
        return hl.dsp.exec_cmd("omarchy-menu-clipboard")
    end,
    -- Spawn the dropdown once; [k] prevents pgrep matching this command itself.
    ["pypr toggle term"] = function()
        return hl.dsp.exec_cmd([[bash -c "pgrep -f '[k]itty --class kitty-dropterm' >/dev/null || hyprctl dispatch -- exec 'kitty --class kitty-dropterm'; hyprctl dispatch togglespecialworkspace term"]])
    end,
    ["desktop-reminder set"] = function() return hl.dsp.exec_cmd("omarchy-reminder -i") end,
    ["desktop-reminder list"] = function() return hl.dsp.exec_cmd("omarchy-reminder show") end,
    ["desktop-reminder clear"] = function() return hl.dsp.exec_cmd("omarchy-reminder clear") end,
}

o.window("kitty-dropterm", {
    workspace = "special:term",
    float = true,
    center = true,
    size = { "(monitor_w*7/10)", "(monitor_h*7/10)" },
})

loader.register(classic, { exec_overrides = exec_overrides })
