-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
        wrap_focus = false,
    },
})


hl.config({
    group = {
        groupbar = {
            enabled     = true,
            font_size   = 12,
            height      = 22,
            -- stacked     = true, -- vertical tab titles
            -- Required to render tab backgrounds; single colors stay solid.
            gradients   = true,
            rounding    = 3,
            indicator_height = 0,
            gaps_in     = 4,
            gaps_out    = 4,
            text_padding = 4,
            keep_upper_gap = true,
            gradient_rounding = 5,
            gradient_round_only_edges = false,

            col = {
                active          = "rgba(b8bb26ff)", -- Gruvbox green
                inactive        = "rgba(504945ff)", -- Gruvbox bg2
                locked_active   = "rgba(fabd2fff)", -- Gruvbox yellow
                locked_inactive = "rgba(d65d0eff)", -- Gruvbox orange
            },

            text_color                 = "rgba(282828ff)", -- Gruvbox bg0
            text_color_inactive        = "rgba(ebdbb2ff)", -- Gruvbox fg1
            text_color_locked_active   = "rgba(282828ff)",
            text_color_locked_inactive = "rgba(ebdbb2ff)",
        },
    },
})
