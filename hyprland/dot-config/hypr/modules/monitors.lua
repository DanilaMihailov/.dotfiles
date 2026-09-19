------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- The Waybar display toggle maintains this marker so config reloads preserve
-- its runtime choice instead of always enabling the laptop panel again.
local state_home = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
local internal_disabled_marker = state_home .. "/hyprland/internal-display-disabled"
local internal_disabled_file = io.open(internal_disabled_marker, "r")
local internal_disabled = internal_disabled_file ~= nil
if internal_disabled_file then
    internal_disabled_file:close()
end

local internal_monitor = {
    -- disabled = internal_disabled,
    disabled = false,
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "5120x0",
    scale    = 1.25,
}

local middle_external_monitor = {
    output   = "DP-1",
    mode     = "3840x2160@60",
    position = "2560x0",
    scale    = 1.5,
}

local left_external_monitor = {
    output   = "DP-2",
    mode     = "3840x2160@60",
    position = "0x0",
    scale    = 1.5,
}

local top_external_monitor = {
    output   = "HDMI-A-1",
    mode     = "2560x1440@60",
    position = "4864x-1152",
    scale    = 1.25,
}

hl.monitor(internal_monitor)
hl.monitor(middle_external_monitor)
hl.monitor(left_external_monitor)
hl.monitor(top_external_monitor)

-- Keep display lifecycle behavior alongside the monitor definitions.
-- Disable the internal display when the lid closes so its workspace moves to
-- an active external monitor, then restore the configured layout when opened.
hl.bind(
    "switch:on:Lid Switch",
    function()
        hl.monitor({ output = "eDP-1", disabled = true })
    end,
    { locked = true }
)
hl.bind(
    "switch:off:Lid Switch",
    function()
        hl.monitor({ output = "eDP-1", disabled = false })
    end,
    { locked = true }
)
