local f = require("script.helper")

local function initialize_workspace(monitor)
    local target = f.mon_offset(monitor) + 1
    if monitor.active_workspace and monitor.active_workspace.id == target then return end

    local previous = hl.get_active_monitor()
    local cursor = hl.get_cursor_pos()

    hl.dispatch(hl.dsp.focus({ monitor = monitor }))
    hl.dispatch(hl.dsp.focus({ workspace = target, on_current_monitor = true }))

    if previous and previous.id ~= monitor.id then
        hl.dispatch(hl.dsp.focus({ monitor = previous }))
        if cursor then hl.dispatch(hl.dsp.cursor.move(cursor)) end
    end
end

hl.on("monitor.added", initialize_workspace)

return { initialize_workspace = initialize_workspace }
