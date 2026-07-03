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
