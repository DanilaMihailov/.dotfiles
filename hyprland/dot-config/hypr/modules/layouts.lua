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

-- Scroll vertically on the portrait display.
hl.workspace_rule({
    workspace = "m[DP-2]",
    layout_opts = {
        direction = "down",
    },
})

-- The first row needs center mode to allow scrolling past the tape's start.
-- This option is global, so select it according to the focused monitor.
local function update_scrolling_fit()
    local monitor = hl.get_active_monitor()
    local portrait = monitor and monitor.name == "DP-2"
    hl.config({
        scrolling = {
            focus_fit_method = portrait and 0 or 1,
        },
    })
end

hl.on("monitor.focused", update_scrolling_fit)
hl.on("config.reloaded", update_scrolling_fit)
hl.on("hyprland.start", update_scrolling_fit)

-- Center the scrolling column after focus settles on the portrait display.
hl.on("window.active", function(window)
    update_scrolling_fit()
    if not window or window.floating then
        return
    end

    hl.timer(function()
        local active = hl.get_active_window()
        local monitor = hl.get_active_monitor()
        local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()
        if active and active.address == window.address
            and monitor and monitor.name == "DP-2"
            and workspace and workspace.tiled_layout == "scrolling" then
            hl.dispatch(hl.dsp.layout("center"))
        end
    end, { timeout = 1, type = "oneshot" })
end)

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
