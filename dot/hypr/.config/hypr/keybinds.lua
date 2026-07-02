-- =============================================================================
-- KEYBINDS
-- =============================================================================
local vars = require("variables")
local mod = "SUPER"
local s = " + SHIFT"
local c = " + CTRL"
local a = " + ALT"

local function ws(action, target)
    return vars.wsScript .. " " .. action .. " " .. target
end

-- --- SHELL ---
hl.bind(mod .. " + super_l", hl.dsp.exec_cmd("pkill rofi || rofi -show drun -show-icons -terminal kitty"))
hl.bind(mod .. " + space", hl.dsp.exec_cmd("fcitx5-remote -t"))
hl.bind(mod .. " + delete", hl.dsp.exec_cmd("rofi -show power-menu -modi power-menu:rofi-power-menu"))
hl.bind(mod .. s .. c .. " + R", function() hl.exec_cmd("hyprctl reload") end)
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
hl.bind(mod .. " + Q", hl.dsp.exec_cmd(vars.terminal))
hl.bind(mod .. " + W", hl.dsp.exec_cmd(vars.browser))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(vars.fileManager))
hl.bind(mod .. " + R", hl.dsp.exec_cmd(vars.notesEditor))
hl.bind(mod .. " + T", hl.dsp.exec_cmd(vars.codeEditor))

-- --- WINDOWS ---
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mod .. " + C", hl.dsp.window.close())
hl.bind(mod .. s .. " + C", hl.dsp.window.kill())
hl.bind(mod .. " + O", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + D", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pin())
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. s .. " + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. s .. " + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mod .. s .. " + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. s .. " + J", hl.dsp.window.move({ direction = "d" }))

-- --- WORKSPACE KEYBINDS ---
for i = 1, 10 do
    local key = tostring(i % 10)
    local n = tostring(i)
    hl.bind(mod .. s .. " + " .. key, hl.dsp.exec_cmd(ws("movetoworkspace", n)))
    hl.bind(mod .. s .. a .. " + " .. key, hl.dsp.exec_cmd(ws("movetoworkspacesilent", n)))
    hl.bind(mod .. " + " .. key, hl.dsp.exec_cmd(ws("workspace", n)))
    hl.bind(mod .. a .. " + " .. key, hl.dsp.exec_cmd(ws("interchange", n)))
end

-- Special keys
hl.bind(mod .. " + semicolon", hl.dsp.exec_cmd(ws("workspace", "l")))
hl.bind(mod .. " + apostrophe", hl.dsp.exec_cmd(ws("workspace", "r")))
hl.bind(mod .. s .. " + semicolon", hl.dsp.exec_cmd(ws("movetoworkspace", "l")))
hl.bind(mod .. s .. " + apostrophe", hl.dsp.exec_cmd(ws("movetoworkspace", "r")))
hl.bind(mod .. s .. a .. " + semicolon", hl.dsp.exec_cmd(ws("movetoworkspacesilent", "l")))
hl.bind(mod .. s .. a .. " + apostrophe", hl.dsp.exec_cmd(ws("movetoworkspacesilent", "r")))
hl.bind(mod .. s .. " + grave", hl.dsp.exec_cmd(ws("movetoworkspace", "special:" .. vars.scratchpadName)))
hl.bind(mod .. " + grave", hl.dsp.exec_cmd(ws("togglespecialworkspace", vars.scratchpadName)))
