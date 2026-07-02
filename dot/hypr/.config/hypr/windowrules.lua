-- =============================================================================
-- WINDOW RULES
-- =============================================================================
local colors = require("variables").theme

-- --- FLOATING ---
hl.window_rule({
    match = {
        float = true,
    },
    border_color = colors.red,
})

-- --- PINNED ---
hl.window_rule({
    match = {
        pin = true,
    },
    border_color = colors.red,
})
