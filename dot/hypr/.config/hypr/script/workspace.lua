local M = {}

-- Configuration for workspace behavior
local NUM_WORKSPACE = 10
local TEMP_WORKSPACE = "special:temp"

-- Helper to retrieve the current active workspace ID
local function get_active_workspace()
    local ws = hl.get_active_workspace()
    return ws and ws.id or nil
end

-- Helper to handle workspace navigation wrapping
local function wrap(current, target)
    if target == "l" then
        return (current == 1) and NUM_WORKSPACE or (current - 1)
    elseif target == "r" then
        return (current == NUM_WORKSPACE) and 1 or (current + 1)
    else
        return target
    end
end

-- Logic to determine if a dynamic (relative) or static (absolute) target is requested
local function resolve_dispatch(target, make_dispatch)
    if target == "l" or target == "r" then
        return function()
            local current = get_active_workspace()
            if not current then
                hl.dispatch(hl.dsp.exec_cmd("notify-send '[workspace] could not determine active workspace\n'"))
                return
            end
            local ws = wrap(current, target)
            hl.dispatch(make_dispatch(ws))
        end
    else
        return make_dispatch(target)
    end
end

-- Focus a target workspace
function M.workspace(target)
    return resolve_dispatch(target, function(ws)
        return hl.dsp.focus({ workspace = ws })
    end)
end

-- Move focused window to target workspace and follow it
function M.movetoworkspace(target)
    return resolve_dispatch(target, function(ws)
        return hl.dsp.window.move({ workspace = ws })
    end)
end

-- Move focused window to target workspace without following
function M.movetoworkspacesilent(target)
    return resolve_dispatch(target, function(ws)
        return hl.dsp.window.move({ workspace = ws, follow = false })
    end)
end

-- Toggle visibility of a special workspace
function M.togglespecialworkspace(target)
    return hl.dsp.workspace.toggle_special(target)
end

-- Swap all windows between current workspace and target workspace
function M.interchange(target)
    return function()
        local current = get_active_workspace()
        if not current then
            hl.dispatch(hl.dsp.exec_cmd("notify-send '[workspace] could not determine active workspace\n'"))
            return
        end
        local dest = wrap(current, target)

        -- Helper to move all windows from one workspace to another
        local function move_all(from, to)
            for _, window in ipairs(hl.get_workspace_windows(from) or {}) do
                hl.dispatch(hl.dsp.window.move({ workspace = to, window = "address:" .. window.address }))
            end
        end

        -- Perform a 3-step swap using a temporary workspace
        move_all(current, TEMP_WORKSPACE)
        move_all(dest, current)
        move_all(TEMP_WORKSPACE, dest)

        -- Return focus to the original workspace
        hl.dispatch(hl.dsp.focus({ workspace = current }))
    end
end

return M
