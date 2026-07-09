-- =============================================================================
-- KEYBINDS
-- =============================================================================
local vars = require("variables")
local f = require("script.helper")
local ws = require("script.workspace")
local preset = require("script.preset")
local ref = require("script.refresh")
local player = require("script.player")

local mod = " + SUPER"
local s = " + SHIFT"
local c = " + CTRL"
local a = " + ALT"
local keybind = f.new()

-- --- SHELL ---
keybind:bind({ mod = { mod } })
    :temp({ key = { "space" }, dsp = hl.dsp.exec_cmd("fcitx5-remote -t"), rules = { repeating = true } })                      -- Language
    :temp({ key = { "B" }, dsp = hl.dsp.exec_cmd("pgrep waybar && pkill waybar || waybar &"), rules = { repeating = false } }) -- Toggle Waybar
    :temp({ key = { "super_l" }, dsp = hl.dsp.exec_cmd("pkill rofi || rofi -show drun -show-icons -terminal kitty") })         -- App Launcher
    :append({ mod = { c } })
    :temp({                                                                                                                    -- Prime-run App Launcher
        key = { "super_l" },
        dsp = f.new()
            :notify("Prime-Run")
            :exec("pkill rofi || prime-run rofi -show drun -show-icons -terminal kitty")
            :done()
    })
    :append({ mod = { s }, key = { "R" }, dsp = ref.refresh() })                                     -- Refresh Configs
    :bind({ mod = { mod }, key = { "delete" }, dsp = hl.dsp.exec_cmd("~/.local/bin/powermenu.sh") }) -- Power Menu
    :append({ mod = { s }, dsp = hl.dsp.exec_cmd("hyprlock") })                                      -- Lock

-- --- UTILITIES ---
keybind:bind()
    :temp({ key = { "XF86AudioMute" }, dsp = hl.dsp.exec_cmd("volumectl toggle-mute") })                                -- Volumne Mute
    :temp({ key = { "XF86AudioRaiseVolume" }, dsp = hl.dsp.exec_cmd("volumectl -u up"), rules = { repeating = true } }) -- Volumne Up
    :temp({ key = { "XF86AudioLowerVolume" }, dsp = hl.dsp.exec_cmd("volumectl -u down") })                             -- Volumne Down
    :temp({ key = { "XF86MonBrightnessUp" }, dsp = hl.dsp.exec_cmd("lightctl up") })                                    -- Brightness Up
    :temp({ key = { "XF86MonBrightnessDown" }, dsp = hl.dsp.exec_cmd("lightctl down") })                                -- Brightness Down
    :append({ mod = { mod }, rules = { repeating = false } })
    :temp({ key = { "V" }, dsp = hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy") })          -- Clipboard History
    :temp({ key = { "M" }, dsp = hl.dsp.exec_cmd("volumectl toggle-mute") })                                            -- Volumne Mute
    :temp({ key = { "equal" }, dsp = hl.dsp.exec_cmd("volumectl -u up"), rules = { repeating = true } })                -- Volumne Up
    :temp({ key = { "minus" }, dsp = hl.dsp.exec_cmd("volumectl -u down") })                                            -- Volumne Down
    :append({ mod = { a } })
    :temp({ key = { "equal" }, dsp = hl.dsp.exec_cmd("lightctl up") })                                                  -- Brightness Up
    :temp({ key = { "minus" }, dsp = hl.dsp.exec_cmd("lightctl down") })                                                -- Brightness Down

-- Player
keybind:bind({ mod = { mod } })
    :temp({ key = { "KP_Delete" }, dsp = player.run("") })                                               -- Info
    :temp({ key = { "KP_Insert" }, dsp = player.run("playerctl play-pause") })                           -- Play/Pause
    :temp({ key = { "left" }, dsp = player.run("playerctl position 5-"), rules = { repeating = true } }) -- Skip Backward
    :temp({ key = { "right" }, dsp = player.run("playerctl position 5+") })                              -- Skip Forward
    :temp({ key = { "up" }, dsp = player.run("playerctl volume 0.05+") })                                -- Volume Up
    :temp({ key = { "down" }, dsp = player.run("playerctl volume 0.05-playerctl position 5+") })         -- Volume Down
    :append({ mod = { a } })
    :temp({ key = { "left", dsp = player.run("playerctl prev") } })                                      -- Previous Track
    :temp({ key = { "right", dsp = player.run("playerctl next") } })                                     -- Next Track
    :temp({ key = { "up", dsp = player.run("playerctl shift") } })                                       -- Next Player
    :temp({ key = { "down", dsp = player.run("playerctl unshift") } })                                   -- Previous Player

-- Screen Snap
keybind:bind({ mod = { mod }, key = { "S" }, dsp = hl.dsp.exec_cmd("env HQF_ACTION=temp quickshell -c HyprQuickFrame -n") }) -- Clipboard (Region)
    :temp({ mod = { a }, dsp = hl.dsp.exec_cmd("env HQF_MODE=window HQF_ACTION=temp quickshell -c HyprQuickFrame -n") })     -- Clipboard (Window)
    :temp({ mod = { s }, dsp = hl.dsp.exec_cmd("env HQF_ACTION=edit quickshell -c HyprQuickFrame -n") })                     -- Edit (Region)
    :combine({ dsp = hl.dsp.exec_cmd("env HQF_MODE=window HQF_ACTION=edit quickshell -c HyprQuickFrame -n") })               -- Edit (Window)
    :bind({ mod = { mod, c }, key = { "S" }, dsp = hl.dsp.exec_cmd("quickshell -c HyprQuickFrame -n") })                     -- File (Region)
    :append({ mod = { a }, dsp = hl.dsp.exec_cmd("env HQF_MODE=window quickshell -c HyprQuickFrame -n") })                   -- File (Window)

-- Cursor
keybind:bind({ mod = { mod } })
    :temp({ key = { "comma" }, dsp = hl.dsp.exec_cmd("wl-kbptr -o modes=floating,click -o mode_floating.source=detect") }) -- Clickable
    :temp({ key = { "period" }, dsp = hl.dsp.exec_cmd("wl-kbptr") })                                                       -- Grid

-- --- APP ---
keybind:bind({ mod = { mod } })
    :temp({ key = { "Q" }, dsp = hl.dsp.exec_cmd(vars.apps.terminal) })                  -- Kitty
    :temp({ key = { "W" }, dsp = hl.dsp.exec_cmd(vars.apps.browser) })                   -- Zen
    :temp({ key = { "E" }, dsp = hl.dsp.exec_cmd(vars.apps.fileManager) })               -- Dolphin
    :temp({ key = { "R" }, dsp = hl.dsp.exec_cmd(vars.apps.notepad) })                   -- Featherpad
    :temp({ key = { "T" }, dsp = hl.dsp.exec_cmd(vars.apps.calculator) })                -- Qalculate-QT
    :append({ mod = { a }, key = { "KP_Insert" }, dsp = preset.launch(preset.default) }) -- Preset

-- --- WINDOW ---
local directions = { H = "l", L = "r", K = "u", J = "d" }
keybind:bind({ mod = { mod } })
    :temp({ key = { "mouse:272" }, dsp = hl.dsp.window.drag(), rules = { mouse = true } })                -- Drag
    :temp({ key = { "mouse:273" }, dsp = hl.dsp.window.resize() })                                        -- Resize
    :temp({ key = { "O" }, dsp = hl.dsp.window.float({ action = "toggle" }), rules = { mouse = false } }) -- Toggle Float
    :temp({ key = { "P" }, dsp = hl.dsp.window.pin() })                                                   -- Pin
    :temp({ key = { "D" }, dsp = hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }) })   -- Maximized
    :temp({ key = { "F" }, dsp = hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }) })  -- Fullscreen
    :temp({ key = { "C" }, dsp = hl.dsp.window.close() })                                                 -- Close
    :append({ mod = { s } })
    :temp({ key = { "C" }, dsp = hl.dsp.window.kill() })                                                  -- Force Close
    :temp({ key = { "equal" }, dsp = hl.dsp.layout("splitratio 0.1") })                                   -- Split Ratio Up
    :temp({ key = { "minus" }, dsp = hl.dsp.layout("splitratio -0.1") })                                  -- Split Ratio Down
    :bind({ mod = { mod } })
for key, val in pairs(directions) do
    keybind:temp({ key = { key }, dsp = hl.dsp.focus({ direction = val }) })    -- Focus in Direction
        :temp({ key = { key }, dsp = hl.dsp.window.move({ direction = val }) }) -- Move in Direction
end

-- --- GROUP ---
keybind:bind({ mod = { mod, a } })
    :temp({ key = { "backslash" }, dsp = hl.dsp.group.toggle() })
    :temp({ key = { "bracketleft" }, dsp = hl.dsp.group.prev() })
    :temp({ key = { "bracketright" }, dsp = hl.dsp.group.next() })
    :temp({ key = { "backspace" }, dsp = hl.dsp.group.lock("toggle") })
for key, val in pairs(directions) do
    keybind:temp({ key = { key }, dsp = hl.dsp.window.move({ direction = val, group_aware = true }) })
end

-- --- WORKSPACE ---
---@type table<string, string|number>
local workspaces = { semicolon = "l", apostrophe = "r" }
for i = 1, 10 do
    workspaces[tostring(i % 10)] = i
end
for key, val in pairs(workspaces) do
    keybind:bind({ mod = { mod }, key = { key }, dsp = ws.workspace(val), rules = { repeating = true } }) -- Switch to Workspace #
        :temp({ mod = { s }, dsp = ws.movetoworkspace(val) })                                             -- Move to Workspace #
        :temp({ mod = { a }, dsp = ws.interchange(val), rules = { repeating = false } })                  -- Interchange with Workspace #
        :combine({ dsp = ws.movetoworkspacesilent(val) })                                                 -- Move to Workspace Silent #
end

-- Special
local special = vars.scratchpadName
keybind:bind({ mod = { mod }, key = { "grave" }, dsp = ws.togglespecialworkspace(special) }) -- Toggle Special
    :append({ mod = { s }, dsp = ws.movetoworkspace(special) })                              -- Move to Special
    :append({ mod = { a }, dsp = ws.movetoworkspacesilent(special) })                        -- Move to Special Silent
