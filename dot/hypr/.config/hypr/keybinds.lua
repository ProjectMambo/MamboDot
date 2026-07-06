-- =============================================================================
-- KEYBINDS
-- =============================================================================
local vars = require("variables")
local ws = require("script.workspace")
local preset = require("script.preset")
local ref = require("script.refresh")
local mod = " + SUPER"
local s = " + SHIFT"
local c = " + CTRL"
local a = " + ALT"

-- --- SHELL ---
hl.bind(mod .. " + super_l", hl.dsp.exec_cmd("pkill rofi || rofi -show drun -show-icons -terminal kitty")) -- App Launcher
hl.bind(c .. mod .. " + super_l",                                                                          -- Prime-run App Launcher
    function()
        hl.dispatch(hl.dsp.exec_cmd("notify-send 'Prime-Run'"))
        hl.dispatch(hl.dsp.exec_cmd("pkill rofi || prime-run rofi -show drun -show-icons -terminal kitty"))
    end)
hl.bind(mod .. " + space", hl.dsp.exec_cmd("fcitx5-remote -t"))                                        -- Language
hl.bind(mod .. " + delete", hl.dsp.exec_cmd("rofi -show power-menu -modi power-menu:rofi-power-menu")) -- Power Menu
hl.bind(mod .. s .. " + delete", hl.dsp.exec_cmd("hyprlock"))                                          -- Lock
hl.bind(mod .. s .. c .. " + R", ref.refresh)                                                          -- Refresh Configs
hl.bind(mod .. " + B", hl.dsp.exec_cmd("pgrep waybar && pkill waybar || waybar &"))                    -- Toggle Waybar

-- --- UTILITIES ---
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("volumectl -u up"), { repeating = true })          -- Volumne Up
hl.bind(mod .. " + equal", hl.dsp.exec_cmd("volumectl -u up"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("volumectl -u down"), { repeating = true })        -- Volumne Down
hl.bind(mod .. " + minus", hl.dsp.exec_cmd("volumectl -u down"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("volumectl toggle-mute"))                                 -- Volumne Mute
hl.bind(mod .. " + m", hl.dsp.exec_cmd("volumectl toggle-mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("lightctl up"), { repeating = true })               -- Brightness Up
hl.bind(mod .. a .. " + equal", hl.dsp.exec_cmd("lightctl up"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("lightctl down"), { repeating = true })           -- Brightness Down
hl.bind(mod .. a .. " + minus", hl.dsp.exec_cmd("lightctl down"), { repeating = true })
hl.bind(mod .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy")) -- Clipboard History

-- Screen Snap
hl.bind(mod .. " + S", hl.dsp.exec_cmd("env HQF_ACTION=temp quickshell -c HyprQuickFrame -n"))                           -- Clipboard (Region)
hl.bind(mod .. a .. " + S", hl.dsp.exec_cmd("env HQF_MODE=window HQF_ACTION=temp quickshell -c HyprQuickFrame -n"))      -- Clipboard (Window)
hl.bind(mod .. s .. " + S", hl.dsp.exec_cmd("env HQF_ACTION=edit quickshell -c HyprQuickFrame -n"))                      -- Edit (Region)
hl.bind(mod .. a .. s .. " + S", hl.dsp.exec_cmd("env HQF_MODE=window HQF_ACTION=edit quickshell -c HyprQuickFrame -n")) -- Edit (Window)
hl.bind(mod .. c .. " + S", hl.dsp.exec_cmd("quickshell -c HyprQuickFrame -n"))                                          -- File (Region)
hl.bind(mod .. a .. c .. " + S", hl.dsp.exec_cmd("env HQF_MODE=window quickshell -c HyprQuickFrame -n"))                 -- File (Window)

-- Cursor
hl.bind(mod .. " + comma", hl.dsp.exec_cmd("wl-kbptr -o modes=floating,click -o mode_floating.source=detect")) -- Clickable
hl.bind(mod .. " + period", hl.dsp.exec_cmd("wl-kbptr"))                                                       -- Grid

-- --- APP ---
hl.bind(mod .. " + Q", hl.dsp.exec_cmd(vars.apps.terminal))    -- Kitty
hl.bind(mod .. " + W", hl.dsp.exec_cmd(vars.apps.browser))     -- Zen
hl.bind(mod .. " + E", hl.dsp.exec_cmd(vars.apps.fileManager)) -- Dolphin
hl.bind(mod .. " + R", hl.dsp.exec_cmd(vars.apps.notes))       -- Obsidian
hl.bind(mod .. " + T", hl.dsp.exec_cmd(vars.apps.code))        -- Code-Oss

-- Presets
hl.bind(mod .. a .. " + KP_Insert", preset.launch(preset.default)) -- Preset 1

-- --- WINDOW ---
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })                       -- Drag
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })                     -- Resize
hl.bind(mod .. " + C", hl.dsp.window.close())                                                -- Close
hl.bind(mod .. s .. " + C", hl.dsp.window.kill())                                            -- Force Close
hl.bind(mod .. " + O", hl.dsp.window.float({ action = "toggle" }))                           -- Toggle Float
hl.bind(mod .. " + D", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))  -- Maximized
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })) -- Fullscreen
hl.bind(mod .. " + P", hl.dsp.window.pin())                                                  -- Pin

hl.bind(mod .. s .. " + equal", hl.dsp.layout("splitratio -0.1"))                            -- Split Ratio Up
hl.bind(mod .. s .. " + minus", hl.dsp.layout("splitratio 0.1"))                             -- Split Ratio Down

-- Focus in Direction
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "d" }))

-- Move in Direction
hl.bind(mod .. s .. " + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. s .. " + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(mod .. s .. " + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. s .. " + J", hl.dsp.window.move({ direction = "d" }))

-- --- GROUP ---
hl.bind(mod .. a .. " + backslash", hl.dsp.group.toggle())
hl.bind(mod .. a .. " + bracketleft", hl.dsp.group.prev())
hl.bind(mod .. a .. " + bracketright", hl.dsp.group.next())
hl.bind(mod .. a .. " + H", hl.dsp.window.move({ direction = "l", group_aware = true }))
hl.bind(mod .. a .. " + L", hl.dsp.window.move({ direction = "r", group_aware = true }))
hl.bind(mod .. a .. " + K", hl.dsp.window.move({ direction = "u", group_aware = true }))
hl.bind(mod .. a .. " + J", hl.dsp.window.move({ direction = "d", group_aware = true }))
hl.bind(mod .. a .. " + backspace", hl.dsp.group.lock("toggle"))

-- --- WORKSPACE ---
for i = 1, 10 do
    local key = tostring(i % 10)
    local n = tostring(i)
    hl.bind(mod .. " + " .. key, ws.workspace(n))                       -- Switch to Workspace #
    hl.bind(mod .. s .. " + " .. key, ws.movetoworkspace(n))            -- Move to Workspace #
    hl.bind(mod .. s .. a .. " + " .. key, ws.movetoworkspacesilent(n)) -- Move to Workspace Silent #
    hl.bind(mod .. a .. " + " .. key, ws.interchange(n))                -- Interchange with Workspace #
end

-- Left/Right
hl.bind(mod .. " + semicolon", ws.workspace("l"), { repeating = true })            -- Switch to Workspace l/r
hl.bind(mod .. " + apostrophe", ws.workspace("r"), { repeating = true })
hl.bind(mod .. s .. " + semicolon", ws.movetoworkspace("l"), { repeating = true }) -- Move to Workspace l/r
hl.bind(mod .. s .. " + apostrophe", ws.movetoworkspace("r"), { repeating = true })
hl.bind(mod .. s .. a .. " + semicolon", ws.movetoworkspacesilent("l"))            -- Move to Workspace Silent l/r
hl.bind(mod .. s .. a .. " + apostrophe", ws.movetoworkspacesilent("r"))
hl.bind(mod .. a .. " + semicolon", ws.interchange("l"))                           -- Interchange with Workspace l/r
hl.bind(mod .. a .. " + apostrophe", ws.interchange("r"))

-- Special
local specialws = "special:" .. vars.scratchpadName;
hl.bind(mod .. " + grave", ws.togglespecialworkspace(vars.scratchpadName)) -- Toggle Special
hl.bind(mod .. s .. " + grave", ws.movetoworkspace(specialws))             -- Move to Special
hl.bind(mod .. s .. a .. " + grave", ws.movetoworkspacesilent(specialws))  -- Move to Special Silent
