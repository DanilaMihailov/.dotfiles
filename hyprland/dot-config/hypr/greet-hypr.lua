require("modules.monitors")
require("modules.environment")
require("modules.appearance")
require("modules.misc")
require("modules.input")


hl.monitor({
    output = "DP-1",
    mirror = "eDP-1",
})

hl.monitor({
    output = "DP-2",
    mirror = "eDP-1",
})

hl.monitor({
    output = "HDMI-A-1",
    mirror = "eDP-1",
})

-- Override desktop settings that aren't desirable in the greeter.
hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 0,
    },

    decoration = {
        shadow = {
            enabled = true,
        },

        blur = {
            enabled = true,
        },
    },

    animations = {
        enabled = true,
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
    },
})

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper --config /home/zen/.config/hypr/hyprpaper.conf")
    hl.exec_cmd("regreet; hyprctl dispatch exit")
end)
