local f = require("script.helper")
local M = {}

-- Focus a target workspace
function M.workspace(target)
    return function() f.new():focus({ workspace = f.safe(target) }):run() end
end

-- Move focused window to target workspace and follow it
function M.movetoworkspace(target)
    return function() f.new():move({ workspace = f.safe(target) }):run() end
end

-- Move focused window to target workspace without following
function M.movetoworkspacesilent(target)
    return function() f.new():move({ workspace = f.safe(target), follow = false }):run() end
end

-- Toggle visibility of a special workspace
function M.togglespecialworkspace(target)
    return f.new():special(target):done()
end

-- Swap all windows between current workspace and target workspace
function M.interchange(target)
    return function()
        local current = f.safe(f.active().id)
        local dest = f.safe(target)
        local temp = f.safe(f.TEMP_WORKSPACE)
        f.new()
            :move_all(current, temp)
            :move_all(dest, current)
            :move_all(temp, dest)
            :run()
    end
end

return M
