-- Module for managing workspace application presets
local f = require("script.helper")
local M = {}

-- Define the default configuration for workspace-application mappings.
-- Each entry contains the target workspace number (or special name)
-- and the application class name to verify.
M.default = {
    -- { ws = "minimized", app = "prime-run steam", check = "steam" },
    { ws = 1,           app = "zen-browser", check = "zen" },
    { ws = 10,          app = "obsidian" },
    { ws = 2,           app = "code-oss" },
    { ws = 3,           app = "chatgpt",     check = "Chatgpt" },
    { ws = 4,           app = "Telegram",    check = "org.telegram.desktop" },
    { ws = "minimized", app = "spotify",     check = "Spotify" }
}

local function is_running(entry)
    for _, window in pairs(hl.get_windows()) do
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
        local active = hl.get_active_workspace()
        local to_open = 0
        local index = 1

        local function launch_next()
            while preset[index] and is_running(preset[index]) do
                index = index + 1
            end

            local entry = preset[index]
            if not entry then
                f.new()
                    :focus({ workspace = active })
                    :notify(string.format("%s app%s to launch", tostring(to_open), ((to_open < 2) and "" or "s")))
                    :run()
                return
            end

            local target_ws = f.safe(entry.ws)
            local subscription
            subscription = hl.on("window.open", function(window)
                if window.class ~= entry.check and window.class ~= entry.app then return end
                subscription:remove()
                index = index + 1
                launch_next()
            end)

            f.new()
                :notify("Launching " .. entry.app)
                :exec(entry.app, { workspace = target_ws })
                :run()
            to_open = to_open + 1
        end

        launch_next()
    end
end

return M
