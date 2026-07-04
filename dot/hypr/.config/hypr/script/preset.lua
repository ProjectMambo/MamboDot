-- Module for managing workspace application presets
local M = {}

-- Define the default configuration for workspace-application mappings.
-- Each entry contains the target workspace number (or special name)
-- and the application class name to verify.
M.default = {
    { ws = 1,           app = "zen-browser", check = "zen" },
    { ws = 2,           app = "code-oss" },
    { ws = 3,           app = "dolphin",     check = "org.kde.dolphin" },
    { ws = 10,          app = "obsidian" },
    { ws = "minimized", app = "spotify" },
    { ws = "minimized", app = "steam" },
}

-- Returns a function that launches applications from the provided
-- preset that are not currently running.
-- @param preset table: A list of application entries to verify and launch.
-- @return function: The function to be called by the window manager.
function M.launch(preset)
    return function()
        -- Retrieve currently open windows to prevent duplicate launches
        local open = hl.get_windows()
        local to_open = 0
        local active = hl.get_active_workspace()

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
                    break
                end
            end

            -- Add to launch queue if not found
            if not is_open then
                hl.dispatch(hl.dsp.exec_cmd("notify-send 'Launching " .. entry.app .. "'"))
                hl.dispatch(hl.dsp.exec_cmd(entry.app, { workspace = search_ws }))
                to_open = to_open + 1
            end
        end

        -- Return focus to the original workspace
        hl.dispatch(hl.dsp.focus({ workspace = active }))

        -- Notify the user how many apps were launched
        local notify = tostring(to_open) .. ((to_open < 2) and " app" or " apps") .. " to launch"
        hl.dispatch(hl.dsp.exec_cmd("notify-send '" .. notify .. "'"))
    end
end

return M
