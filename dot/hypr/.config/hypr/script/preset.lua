-- Module for managing workspace application presets
local f = require("script.helper")
local M = {}

-- Define the default configuration for workspace-application mappings.
-- Each entry contains the target workspace number (or special name)
-- and the application class name to verify.
M.default = {
    { ws = "minimized", app = "spotify",     check = "Spotify" },
    { ws = "minimized", app = "steam" },
    { ws = 1,           app = "zen-browser", check = "zen" },
    { ws = 10,          app = "obsidian" },
    { ws = 2,           app = "code-oss" },
}

-- Returns a function that launches applications from the provided
-- preset that are not currently running.
-- @param preset table: A list of application entries to verify and launch.
-- @return function: The function to be called by the window manager.
function M.launch(preset)
    return function()
        -- Retrieve currently open windows to prevent duplicate launches
        local windows = hl.get_windows()
        local active = hl.get_active_workspace()
        local to_open = 0

        -- Iterate through the preset to identify which apps are missing
        for _, entry in ipairs(preset) do
            local target_ws = f.safe(entry.ws)
            local is_running = false

            for _, window in pairs(windows) do
                if window.class == entry.check or window.class == entry.app then
                    is_running = true
                    break
                end
            end

            if not is_running then
                f.new()
                    :notify("Launching " .. entry.app)
                    :exec(entry.app, { workspace = target_ws })
                    :run()
                to_open = to_open + 1
            end
        end

        f.new()
            :focus({ workspace = active })
            :notify(string.format("%s app%s to launch", tostring(to_open), ((to_open < 2) and "" or "s")))
            :run()
    end
end

return M
