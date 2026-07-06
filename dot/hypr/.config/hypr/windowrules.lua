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
