-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")

-- Use GTK's dark theme for traditional GTK applications. Modern GNOME and
-- libadwaita applications use the persistent color-scheme preference instead.
hl.env("GTK_THEME", "Adwaita-dark")

-- Let Hyprland's Qt 6 theme engine provide colors and styling to Qt/KDE apps.
hl.env("QT_QPA_PLATFORMTHEME", "hyprqt6engine")


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
