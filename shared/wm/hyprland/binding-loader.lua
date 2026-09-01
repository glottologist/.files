local loader = {}

local direction = { l = "left", r = "right", u = "up", d = "down" }
local keycode = { ["43"] = "h", ["44"] = "j", ["45"] = "k", ["46"] = "l" }

local function trim(value)
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function split_binding(line)
    local parts = {}
    local rest = line
    for _ = 1, 3 do
        local head, tail = rest:match("^([^,]*),(.*)$")
        if not head then break end
        parts[#parts + 1] = trim(head)
        rest = tail
    end
    parts[#parts + 1] = trim(rest)
    return parts
end

local function binding_key(modifiers, key)
    local parts = {}
    key = keycode[key] or key
    for modifier in modifiers:gmatch("%S+") do
        parts[#parts + 1] = modifier
    end
    parts[#parts + 1] = key
    return table.concat(parts, " + ")
end

local function action_for(dispatcher, argument, exec_overrides)
    if dispatcher == "exec" then
        local override = exec_overrides[argument]
        if override then return override() end
        return hl.dsp.exec_cmd(argument)
    elseif dispatcher == "killactive" then
        return hl.dsp.window.close()
    elseif dispatcher == "pseudo" then
        return hl.dsp.window.pseudo()
    elseif dispatcher == "layoutmsg" then
        return hl.dsp.layout(argument)
    elseif dispatcher == "fullscreen" then
        return hl.dsp.window.fullscreen({ mode = "fullscreen" })
    elseif dispatcher == "togglefloating" then
        return hl.dsp.window.float()
    elseif dispatcher == "workspaceopt" then
        return hl.dsp.exec_cmd("hyprctl dispatch workspaceopt " .. argument)
    elseif dispatcher == "exit" then
        return hl.dsp.exit()
    elseif dispatcher == "movewindow" then
        return hl.dsp.window.move({ direction = direction[argument] })
    elseif dispatcher == "swapwindow" then
        return hl.dsp.window.swap({ direction = direction[argument] })
    elseif dispatcher == "movefocus" then
        return hl.dsp.focus({ direction = direction[argument] })
    elseif dispatcher == "workspace" then
        return hl.dsp.focus({ workspace = tonumber(argument) or argument })
    elseif dispatcher == "movetoworkspace" then
        return hl.dsp.window.move({ workspace = tonumber(argument) or argument })
    elseif dispatcher == "togglespecialworkspace" then
        return hl.dsp.workspace.toggle_special()
    elseif dispatcher == "cyclenext" then
        return hl.dsp.window.cycle_next()
    elseif dispatcher == "bringactivetotop" then
        return hl.dsp.window.bring_to_top()
    end
    print("keybind-catalog: unhandled dispatcher '" .. dispatcher .. "'")
end

local function mouse_action_for(dispatcher)
    if dispatcher == "movewindow" then
        return hl.dsp.window.drag()
    elseif dispatcher == "resizewindow" then
        return hl.dsp.window.resize()
    end
    print("keybind-catalog: unhandled mouse dispatcher '" .. dispatcher .. "'")
end

local function append_description(entry, description)
    if entry.seen_descriptions[description] then return end
    entry.seen_descriptions[description] = true
    entry.descriptions[#entry.descriptions + 1] = description
end

local function add_entry(entries, order, key, record, action, mouse)
    if not action then return end
    local entry = entries[key]
    if not entry then
        entry = {
            actions = {},
            descriptions = {},
            group = record.group,
            mouse = mouse,
            seen_descriptions = {},
        }
        entries[key] = entry
        order[#order + 1] = key
    elseif entry.group ~= record.group then
        error(string.format(
            "keybind-catalog: chord %s belongs to both %s and %s",
            key,
            entry.group,
            record.group
        ))
    elseif entry.mouse ~= mouse then
        error("keybind-catalog: chord " .. key .. " mixes keyboard and mouse bindings")
    end
    entry.actions[#entry.actions + 1] = action
    append_description(entry, record.description)
end

local function register_entries(entries, order)
    for _, key in ipairs(order) do
        local entry = entries[key]
        local options = {
            description = "[" .. entry.group .. "] " .. table.concat(entry.descriptions, " / "),
        }
        if entry.mouse then options.mouse = true end

        if #entry.actions == 1 then
            hl.bind(key, entry.actions[1], options)
        else
            hl.bind(key, function()
                for _, action in ipairs(entry.actions) do
                    if type(action) == "function" then action()
                    else hl.dispatch(action) end
                end
            end, options)
        end
    end
end

function loader.register(catalog, options)
    options = options or {}
    local exec_overrides = options.exec_overrides or {}
    local entries, order = {}, {}

    for _, record in ipairs(catalog.bind or {}) do
        local parts = split_binding(record.binding)
        add_entry(
            entries,
            order,
            binding_key(parts[1], parts[2]),
            record,
            action_for(parts[3], parts[4] or "", exec_overrides),
            false
        )
    end

    for _, record in ipairs(catalog.bindm or {}) do
        local parts = split_binding(record.binding)
        add_entry(
            entries,
            order,
            binding_key(parts[1], parts[2]),
            record,
            mouse_action_for(parts[3]),
            true
        )
    end

    register_entries(entries, order)
end

function loader.bind(keys, group, description, action, options)
    local annotated = {}
    for key, value in pairs(options or {}) do
        annotated[key] = value
    end
    annotated.description = "[" .. group .. "] " .. description
    hl.bind(keys, action, annotated)
end

return loader
