------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- The Waybar toggle records the manual preference. The runtime fallback keeps
-- the panel available after the last external display disappears, even on reload.
local state_home = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
local internal_disabled_marker = state_home .. "/hyprland/internal-display-disabled"
local runtime_home = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
local fallback_marker = runtime_home .. "/hyprland-internal-display-fallback"
local lid_marker = runtime_home .. "/hyprland-internal-display-lid-closed"

local function marker_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

local internal_monitor = {
    disabled = (marker_exists(internal_disabled_marker) or marker_exists(lid_marker))
        and not marker_exists(fallback_marker),
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "1952x1440",
    scale    = 1.25,
}

local middle_external_monitor = {
    output   = "DP-1",
    mode     = "3840x2160@60",
    position = "1440x0",
    scale    = 1.5,
}

local left_external_monitor = {
    output   = "DP-2",
    mode     = "3840x2160@60",
    position = "0x-560",
    scale    = 1.5,
    transform = 1,
}

local top_external_monitor = {
    output   = "HDMI-A-1",
    mode     = "2560x1440@60",
    position = "3744x-1152",
    scale    = 1.25,
}

hl.monitor(internal_monitor)
hl.monitor(middle_external_monitor)
hl.monitor(left_external_monitor)
hl.monitor(top_external_monitor)

-- All display changes go through one reconciler, including hotplug and reload.
-- It only disables the panel when another active output is available.
local display_script = os.getenv("HOME") .. "/.config/waybar/internal-display-toggle.sh"
local function reconcile()
    hl.exec_cmd(display_script .. " reconcile")
end

local function start_watcher()
    hl.exec_cmd(display_script .. " watch")
    reconcile()
end

hl.on("hyprland.start", start_watcher)
hl.on("monitor.layout_changed", reconcile)
hl.on("config.reloaded", start_watcher)

hl.bind(
    "switch:on:Lid Switch",
    function()
        hl.exec_cmd(display_script .. " lid-close")
    end,
    { locked = true }
)
hl.bind(
    "switch:off:Lid Switch",
    function()
        hl.exec_cmd(display_script .. " lid-open")
    end,
    { locked = true }
)
