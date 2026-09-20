local root = assert(arg[1], "project path is required")
package.path = root .. "/dot/hypr/.config/hypr/?.lua;" .. package.path

local commands = {}
local notifications = {}
local queried_workspaces = {}
local environment = {}

hl = {
    env = function(key, value)
        environment[key] = value
    end,
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

local variables = require("variables")
local home = assert(os.getenv("HOME"))
local user_paths = {
    home .. "/.local/bin",
    home .. "/.npm-global/bin",
    home .. "/.cargo/bin",
    home .. "/.local/share/JetBrains/Toolbox/scripts",
}
local path_counts = {}
for path in variables.env.PATH:gmatch("[^:]+") do
    path_counts[path] = (path_counts[path] or 0) + 1
end
assert(variables.env.PATH:sub(1, #table.concat(user_paths, ":")) == table.concat(user_paths, ":"))
for _, path in ipairs(user_paths) do
    assert(path_counts[path] == 1)
end
assert(environment.PATH == variables.env.PATH)

local helper = require("script.helper")
assert(helper.safe(2) == "12")

local monitor = hl.get_active_monitor()
local window = { at = { x = 1930, y = 110 }, size = { x = 100, y = 200 } }
assert(helper.get_corner_index(window, monitor) == 1)
local bottom_right = helper.get_corner_pos("br", window, monitor)
assert(bottom_right.x == 3738)
assert(bottom_right.y == 978)
local video_size = helper.size(0.4, { width = 2560, height = 1440 })
assert(video_size.x == 1024)
assert(video_size.y == 576)
local next_size, current_size = helper.get_next_size(1024, 2560, 1)
assert(next_size == 0.6)
assert(current_size == 0.4)

helper.new():notify("Kid's song", "Artist's name"):run()
assert(#notifications == 1)
assert(notifications[1].text == "Kid's song\nArtist's name")
assert(#commands == 0)

require("script.workspace").interchange(3)()
assert(table.concat(queried_workspaces, ",") == "12,13,special:temp")

commands = {}
require("script.refresh").refresh()()
assert(table.concat(commands, "\n") == table.concat({
    "ags quit >/dev/null 2>&1; env GDK_BACKEND=wayland ags run",
    "hyprctl reload",
}, "\n"))

commands = {}
notifications = {}
hl.get_windows = function()
    return { { class = "AlreadyRunning" } }
end
hl.dsp.exec_cmd = function(command, rules)
    return string.format("exec:%s@%s", command, rules.workspace)
end
hl.dsp.focus = function(rules)
    return "focus:" .. rules.workspace.id
end
require("script.preset").launch({
    { ws = "minimized", app = "slow-app", check = "SlowApp" },
    { ws = 2, app = "running-app", check = "AlreadyRunning" },
    { ws = 3, app = "next-app", check = "NextApp" },
})()
assert(table.concat(commands, ",") == "exec:slow-app@special:minimized,exec:next-app@13,focus:12")
assert(#notifications == 1)
assert(notifications[1].text == "2 apps queued")

print("Hyprland helper checks passed")
