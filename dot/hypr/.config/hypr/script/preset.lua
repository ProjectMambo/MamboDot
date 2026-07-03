-- Module for managing workspace application presets
local M = {}

-- Define the default configuration for workspace-application mappings
-- Each entry contains the target workspace number (or special name) and the application class name
M.default = {
    { ws = 1,           app = "zen" },
    { ws = 2,           app = "code-oss" },
    { ws = 3,           app = "dolphin", check = "org.kde.dolphin" },
    { ws = 10,          app = "obsidian" },
    { ws = "minimized", app = "spotify" },
}

-- Launches applications from the provided preset that are not currently running
-- @param preset table: A list of application entries to verify and launch
function M.launch(preset)
    -- Retrieve currently open windows to prevent duplicate launches
    local open = hl.get_windows()
    local to_open = {}

    -- Iterate through the preset to identify which apps are missing
    for _, entry in ipairs(preset) do
        local is_open = false
        local target_ws = tostring(entry.ws)
        local search_ws

        -- Normalize workspace target for the execution engine
        if type(entry.ws) == "string" then
            search_ws = "special:" .. target_ws
        else
            search_ws = entry.ws
        end

        -- Check if the application is already running
        for _, window in pairs(open) do
            if window.class == entry.app or window.class == entry.check then
                is_open = true
                break;
            end
        end

        -- Add to launch queue if not found
        if not is_open then
            table.insert(to_open, { ws = search_ws, app = entry.app })
        end
    end

    local active = hl.get_active_workspace()

    -- Process the launch queue
    for _, entry in ipairs(to_open) do
        os.execute("notify-send 'Launching " .. entry.app .. "'")
        hl.dispatch(hl.dsp.exec_cmd(entry.app, { workspace = entry.ws }))
    end

    -- Return focus to the original workspace
    hl.dispatch(hl.dsp.focus({ workspace = active }))

    local notify = tostring(#to_open) .. ((#to_open < 2) and " app" or " apps") .. " to launch"
    os.execute("notify-send '" .. notify .. "'")
end

return M
