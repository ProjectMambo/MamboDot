-- =============================================================================
-- GENERAL
-- =============================================================================

local vars = require("variables")
local colors = vars.theme

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 5,
        border_size = 2,
        col = {
            active_border = colors.red,
            inactive_border = colors.red,
        },
        layout = "dwindle",
        no_focus_fallback = false,
        allow_tearing = false,
    },
    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 0.9,
        fullscreen_opacity = 1.0,
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
            new_optimizations = true,
        },
    },
    dwindle = {
        preserve_split = true,
        force_split = 2,
    },
    group = {
        col = {
            border_active = colors.copper_a,
            border_inactive = colors.deep_oak_a,
        },
        groupbar = {
            font_size = 10,
            height = 12,
            text_color = colors.fg_a,
            render_titles = true,
            gradients = true,
            col = {
                active = colors.bg_a,
                inactive = colors.deep_oak_a,
            },
        },
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        mouse_refocus = true,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})