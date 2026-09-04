-- Restore workspace layouts saved by omnixy-hyprland-workspace-layout-toggle.

local paths = require("default.hypr.paths")
local require_all = require("default.hypr.require_all")

local layouts_dir = paths.state_home .. "/omnixy/workspace-layouts"

require_all.files(layouts_dir, "omnixy.workspace-layouts", { reload = true })
