local f = require("script.helper")
local M = {}

function M.refresh()
    return f.new()
        :notify("Refreshing...")
        :exec({
            "makoctl reload",
            "pkill -USR2 -x waybar",
            "hyprctl reload",
        })
        :done()
end

return M
