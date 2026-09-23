local f = require("script.helper")
local M = {}

function M.refresh()
    return f.new()
        :notify("Refreshing...")
        :exec({
            "systemctl --user restart mambodot-ags.service",
            "hyprctl reload",
        })
        :done()
end

return M
