-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
-- Gruvbox Dark (medium). Keeping the palette named here makes it easy to
-- reuse when more compositor styling is added later.
local gruvbox = {
    bg0    = "282828",
    bg2    = "504945",
    green  = "b8bb26",
    aqua   = "8ec07c",
}

hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 4,

        border_size = 2,

        col = {
            active_border   = {
                colors = {
                    "rgba(" .. gruvbox.green .. "ee)",
                    "rgba(" .. gruvbox.aqua .. "ee)",
                },
                angle = 45,
            },
            inactive_border = "rgba(" .. gruvbox.bg2 .. "aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        -- Keep focus at the edge so Super+j/k can fall through to another workspace.
        no_focus_fallback = true,

        layout = "scrolling",
    },

    decoration = {
        rounding       = 5,
        rounding_power = 2,
        dim_special    = 0.25,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = false,
            range        = 4,
            render_power = 3,
            color        = "rgba(" .. gruvbox.bg0 .. "ee)",
        },

        blur = {
            enabled   = true,
            special   = true,
            size      = 4,
            passes    = 1,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})
