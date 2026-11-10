-- General, decoration and input settings.
-- See https://wiki.hypr.land/configuring/core/config-options/

local vars = require("variables")

hl.config({
    general = {
        gaps_in     = vars.gaps_in,
        gaps_out    = vars.gaps_out,
        border_size = vars.border_size,
        col = {
            active_border   = vars.colors.blue,
            inactive_border = vars.colors.bright_black,
        },
        layout = "dwindle",
    },

    decoration = {
        rounding = vars.border_radius,

        blur = {
            enabled = true,
            size    = 3,
            passes  = 1,
        },

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1b26ee)",
        },
    },

    input = {
        kb_layout  = "us,ir",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        touchpad = {
            natural_scroll = false,
        },

        sensitivity = 0,
    },

    misc = {
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },
})

-- Three finger horizontal swipe moves between workspaces.
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
