local f = require("script.helper")
local M = {}

function M.refresh()
    return f.new()
        :notify("Refreshing...")
        :exec({
            "ags quit >/dev/null 2>&1; env GDK_BACKEND=wayland ags run",
            "hyprctl reload",
        })
        :done()
end

return M
