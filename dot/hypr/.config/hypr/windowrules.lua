-- =============================================================================
-- WINDOW RULES
-- =============================================================================
local theme = require("variables").theme

-- --- FLOATING ---
hl.window_rule({
    match = {
        float = true,
    },
    border_color = theme.color.drk.outback_sky,
})

-- --- PINNED ---
hl.window_rule({
    match = {
        pin = true,
    },
    border_color = theme.color.drk.dry_straw,
})

hl.window_rule({
    match = {
        class = "kitty"
    },
    float = true,
    size = { 1100, 700 } -- Width, Height in pixels
})
hl.window_rule({
    match = {
        class = "org.kde.dolphin"
    },
    float = true,
    size = { 1100, 700 } -- Width, Height in pixels
})
hl.window_rule({
    match = {
        class = "org.pulseaudio.pavucontrol"
    },
    float = true,
    size = { 500, 700 } -- Width, Height in pixels
})
hl.window_rule({
    match = {
        class = "blueman-manager"
    },
    float = true,
    size = { 500, 700 } -- Width, Height in pixels
})
hl.window_rule({
    match = {
        class = "nm-connection-editor"
    },
    float = true,
    size = { 500, 700 } -- Width, Height in pixels
})
hl.window_rule({
    match = {
        class = "feh"
    },
    float = true,
    size = { 1100, 700 }, -- Width, Height in pixels
    move = { "monitor_w * 0.5 - 550", "monitor_h * 0.5 - 326", relative = false }
})
