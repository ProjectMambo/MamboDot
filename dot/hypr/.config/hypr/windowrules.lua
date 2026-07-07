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

-- --- FLOATING ---
local default = { 1100, 700 }
hl.window_rule({
    match = {
        class = "kitty"
    },
    float = true,
    size = default
})
hl.window_rule({
    match = {
        class = "org.kde.dolphin"
    },
    float = true,
    size = default
})
hl.window_rule({
    match = {
        class = "zen",
        title = "Library"
    },
    float = true,
    size = default
})
hl.window_rule({
    match = {
        class = "feh"
    },
    float = true,
    size = default,
    move = { "monitor_w * 0.5 - 550", "monitor_h * 0.5 - 326", relative = false }
})
hl.window_rule({
    match = {
        class = "qimgv",
    },
    float = true,
    size = default
})

local square = { 700, 700 }
hl.window_rule({
    match = {
        class = "featherpad"
    },
    float = true,
    size = square
})
hl.window_rule({
    match = {
        class = "io.github.Qalculate.qalculate-qt"
    },
    float = true,
    size = square
})

local narrow = { 500, 700 }
hl.window_rule({
    match = {
        class = "org.pulseaudio.pavucontrol"
    },
    float = true,
    size = narrow
})
hl.window_rule({
    match = {
        class = "blueman-manager"
    },
    float = true,
    size = narrow
})
hl.window_rule({
    match = {
        class = "nm-connection-editor"
    },
    float = true,
    size = narrow
})
