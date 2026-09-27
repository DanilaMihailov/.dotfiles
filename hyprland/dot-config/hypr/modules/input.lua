---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us,ru",
        kb_variant = "",
        kb_model   = "",
        kb_options = "ctrl:nocaps,altwin:swap_lalt_lwin",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
            scroll_factor = 0.5,
            clickfinger_behavior = true,
            tap_to_click = false
        },
    },
})


hl.device({
    name = "tpps/2-elan-trackpoint",
    sensitivity = -0.2,
})

-- do not switch lalt_lwin on external keyboard (it is already at the right place)
hl.device({
    name = "by-tech-air60-2",
    kb_options = "ctrl:nocaps",
})

hl.device({
    name = "by-tech-air60",
    kb_options = "ctrl:nocaps",
})

hl.device({
    name = "by-tech-air60-1",
    kb_options = "ctrl:nocaps",
})

-- Touchscreen: swipe inward from the left/right edge to change workspace.
hl.config({
    gestures = {
        workspace_swipe_touch = true,
        workspace_swipe_touch_invert = false,
    },
})

hl.gesture({
    fingers = 3,
    direction = "vertical",
    action = "workspace"
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "scroll_move"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

