local root = assert(arg[1], "project path is required")
package.path = root .. "/dot/hypr/.config/hypr/?.lua;" .. package.path

local commands = {}
local notifications = {}
local queried_workspaces = {}

hl = {
    dispatch = function(command)
        table.insert(commands, command)
        return command
    end,
    dsp = {
        exec_cmd = function(command) return command end,
    },
    get_active_monitor = function()
        return { id = 1, x = 1920, y = 100, width = 1920, height = 1080 }
    end,
    get_active_workspace = function()
        return { id = 12, name = "12" }
    end,
    get_workspace_windows = function(workspace)
        table.insert(queried_workspaces, workspace)
        return {}
    end,
    notification = {
        create = function(options)
            table.insert(notifications, options)
            return options
        end,
    },
}

local helper = require("script.helper")
assert(helper.safe(2) == "12")

local monitor = hl.get_active_monitor()
local window = { at = { x = 1930, y = 110 }, size = { x = 100, y = 200 } }
assert(helper.get_corner_index(window, monitor) == 1)
local bottom_right = helper.get_corner_pos("br", window, monitor)
assert(bottom_right.x == 3738)
assert(bottom_right.y == 978)

helper.new():notify("Kid's song", "Artist's name"):run()
assert(#notifications == 1)
assert(notifications[1].text == "Kid's song\nArtist's name")
assert(#commands == 0)

require("script.workspace").interchange(3)()
assert(table.concat(queried_workspaces, ",") == "12,13,special:temp")

commands = {}
require("script.refresh").refresh()()
assert(table.concat(commands, "\n") == table.concat({
    "makoctl reload",
    "pkill -USR2 -x waybar",
    "hyprctl reload",
}, "\n"))

print("Hyprland helper checks passed")
