local f = require("script.helper")
local M = {}

function M.refresh()
    return f.new()
        :notify("Refreshing...")
        :exec({
            "pkill waybar|mako|avizo-service|hyprpaper",
            "mako", "avizo-service", "hyprpaper",
            "update-desktop-database ~/.local/share/applications",
            "kbuildsycoca6 --noincremental",
            "source ~/.zshenv",
            "waybar", "hyprctl reload",
            "systemctl --user daemon-reload"
        })
        :done()
end

return M
