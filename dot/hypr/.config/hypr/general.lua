-- =============================================================================
-- GENERAL
-- =============================================================================

local vars = require("variables")
local theme = vars.theme
local ui = theme.ui
local rgb = theme.hypr

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 5,
        border_size = 2,
        col = {
            active_border = rgb(ui:interactive_hover()),
            inactive_border = rgb(ui:border()),
        },
        layout = "dwindle",
        no_focus_fallback = false,
        allow_tearing = false,
    },
    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
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
            border_active = rgb(ui:interactive()),
            border_inactive = rgb(ui:border()),
        },
        groupbar = {
            font_size = 10,
            height = 12,
            text_color = rgb(ui:fg()),
            render_titles = true,
            gradients = true,
            col = {
                active = rgb(ui:interactive()),
                inactive = rgb(ui:border()),
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

hl.layer_rule({
    name = "mambodot-sidebar-left",
    match = { namespace = "^mambodot-sidebar-left$" },
    animation = "slide left",
})

hl.layer_rule({
    name = "mambodot-sidebar-right",
    match = { namespace = "^mambodot-sidebar-right$" },
    animation = "slide right",
})
