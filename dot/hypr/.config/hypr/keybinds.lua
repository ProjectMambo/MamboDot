-- =============================================================================
-- KEYBINDS
-- =============================================================================
local vars = require("variables")
local ws = require("script.workspace")
local mod = "SUPER"
local s = " + SHIFT"
local c = " + CTRL"
local a = " + ALT"

-- --- SHELL ---
hl.bind(mod .. " + super_l", hl.dsp.exec_cmd("pkill rofi || rofi -show drun -show-icons -terminal kitty"))
hl.bind(mod .. " + space", hl.dsp.exec_cmd("fcitx5-remote -t"))
hl.bind(mod .. " + delete", hl.dsp.exec_cmd("rofi -show power-menu -modi power-menu:rofi-power-menu"))
hl.bind(mod .. s .. c .. " + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd("pgrep waybar && pkill waybar || waybar &"))
hl.bind(mod .. s .. c .. " + B", hl.dsp.exec_cmd("pkill waybar && waybar &"))

-- --- UTILITIES ---
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("volumectl -u up"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("volumectl -u down"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("volumectl toggle-mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("lightctl up"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("lightctl down"), { repeating = true })
hl.bind(mod .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))
hl.bind(mod .. s .. " + S", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))

-- --- APPS ---
hl.bind(mod .. " + Q", hl.dsp.exec_cmd(vars.apps.terminal))
hl.bind(mod .. " + W", hl.dsp.exec_cmd(vars.apps.browser))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(vars.apps.fileManager))
hl.bind(mod .. " + R", hl.dsp.exec_cmd(vars.apps.notes))
hl.bind(mod .. " + T", hl.dsp.exec_cmd(vars.apps.code))

-- --- WINDOWS ---
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mod .. " + C", hl.dsp.window.close())
hl.bind(mod .. s .. " + C", hl.dsp.window.kill())
hl.bind(mod .. " + O", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + D", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pin())

hl.bind(mod .. s .. " + equal", hl.dsp.layout("splitratio 0.1"))
hl.bind(mod .. s .. " + minus", hl.dsp.layout("splitratio -0.1"))

hl.bind(mod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(mod .. s .. " + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. s .. " + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mod .. s .. " + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. s .. " + J", hl.dsp.window.move({ direction = "d" }))

hl.bind(mod .. a .. " + backslash", hl.dsp.group.toggle())
hl.bind(mod .. a .. " + bracketleft", hl.dsp.group.prev())
hl.bind(mod .. a .. " + bracketright", hl.dsp.group.next())
hl.bind(mod .. a .. " + H", hl.dsp.window.move({ direction = "l", group_aware = true }))
hl.bind(mod .. a .. " + L", hl.dsp.window.move({ direction = "r", group_aware = true }))
hl.bind(mod .. a .. " + K", hl.dsp.window.move({ direction = "u", group_aware = true }))
hl.bind(mod .. a .. " + J", hl.dsp.window.move({ direction = "d", group_aware = true }))
hl.bind(mod .. a .. " + backspace", hl.dsp.group.lock("toggle"))

-- --- WORKSPACE KEYBINDS ---
for i = 1, 10 do
    local key = tostring(i % 10)
    local n = tostring(i)
    hl.bind(mod .. " + " .. key, ws.workspace(n))
    hl.bind(mod .. s .. " + " .. key, ws.movetoworkspace(n))
    hl.bind(mod .. s .. a .. " + " .. key, ws.movetoworkspacesilent(n))
    hl.bind(mod .. a .. " + " .. key, ws.interchange(n))
end

-- Special keys
hl.bind(mod .. " + semicolon", ws.workspace("l"))
hl.bind(mod .. " + apostrophe", ws.workspace("r"))
hl.bind(mod .. s .. " + semicolon", ws.movetoworkspace("l"))
hl.bind(mod .. s .. " + apostrophe", ws.movetoworkspace("r"))
hl.bind(mod .. s .. a .. " + semicolon", ws.movetoworkspacesilent("l"))
hl.bind(mod .. s .. a .. " + apostrophe", ws.movetoworkspacesilent("r"))
hl.bind(mod .. a .. " + semicolon", ws.interchange("l"))
hl.bind(mod .. a .. " + apostrophe", ws.interchange("r"))

local specialws = "special:" .. vars.scratchpadName;
hl.bind(mod .. " + grave", ws.togglespecialworkspace(vars.scratchpadName))
hl.bind(mod .. s .. " + grave", ws.movetoworkspace(specialws))
hl.bind(mod .. s .. a .. " + grave", ws.movetoworkspacesilent(specialws))
