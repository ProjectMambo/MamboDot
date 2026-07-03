-- =============================================================================
-- GENERAL
-- =============================================================================

local vars = require("variables")
local theme = vars.theme

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 5,
        border_size = 2,
        col = {
            active_border = theme.color.drk.overgrown_fern,
            inactive_border = theme.color.drk.wild_plum,
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
            border_active = theme.color.drk.deep_teal,
            border_inactive = theme.color.drk.baked_brick,
        },
        groupbar = {
            font_size = 10,
            height = 12,
            text_color = theme.color.drk.river_silt,
            render_titles = true,
            gradients = true,
            col = {
                active = theme.color.drk.deep_teal,
                inactive = theme.color.drk.baked_brick,
            },
        },
    },
    input = {
        kb_layout = "us",
        kb_variant = ",qwerty",
        follow_mouse = 1,
        mouse_refocus = true,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})