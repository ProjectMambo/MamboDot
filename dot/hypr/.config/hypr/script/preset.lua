-- Module for managing workspace application presets
local f = require("script.helper")
local M = {}

-- Define the default configuration for workspace-application mappings.
-- Each entry contains the target workspace number (or special name)
-- and the application class name to verify.
M.default = {
    { ws = "minimized", app = "spotify",     check = "Spotify" },
    -- { ws = "minimized", app = "prime-run steam", check = "steam" },
    { ws = 1,           app = "zen-browser", check = "zen" },
    { ws = 10,          app = "obsidian" },
    { ws = 3,           app = "chatgpt",     check = "Chatgpt" },
    { ws = 4,           app = "Telegram",    check = "org.telegram.desktop" },
    { ws = 2,           app = "code-oss" },
}

local function is_running(entry, windows)
    for _, window in pairs(windows) do
        if window.class == entry.check or window.class == entry.app then
            return true
        end
    end
    return false
end

-- Returns a function that launches applications from the provided
-- preset that are not currently running.
-- @param preset table: A list of application entries to verify and launch.
-- @return function: The function to be called by the window manager.
function M.launch(preset)
    return function()
        local windows = hl.get_windows()
        local active = hl.get_active_workspace()
        local to_open = 0

        for _, entry in ipairs(preset) do
            if not is_running(entry, windows) then
                f.new():exec(entry.app, { workspace = f.safe(entry.ws) }):run()
                to_open = to_open + 1
            end
        end

        f.new()
            :focus({ workspace = active })
            :notify(string.format("%d app%s queued", to_open, to_open == 1 and "" or "s"))
            :run()
    end
end

return M
