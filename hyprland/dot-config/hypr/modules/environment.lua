-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")


------------------
---- XWAYLAND ----
------------------

-- Render XWayland clients at native resolution instead of compositor-upscaling
-- them. Steam applies its own UI scale via settings / accessiblity / scaling
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

