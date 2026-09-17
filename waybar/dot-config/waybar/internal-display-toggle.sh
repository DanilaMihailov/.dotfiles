#!/usr/bin/env bash

set -u

action="${1:-status}"
output="eDP-1"
state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
disabled_marker="$state_home/hyprland/internal-display-disabled"

# custom/internal-display listens for SIGRTMIN+10.
if [[ "$action" == "toggle" ]]; then
  trap 'pkill -RTMIN+10 -x waybar 2>/dev/null || true' EXIT
fi

monitors=$(hyprctl -j monitors all 2>/dev/null) || {
  printf '{"text":"󰍹","tooltip":"Hyprland display status is unavailable","class":"error"}\n'
  exit 0
}

monitor_state() {
  python3 -c '
import json, sys

monitors = json.load(sys.stdin)
output = sys.argv[1]
display = next((item for item in monitors if item.get("name") == output), None)
exists = display is not None
disabled = bool(display and display.get("disabled", False))
active = sum(not item.get("disabled", False) for item in monitors)
print(str(exists).lower(), str(disabled).lower(), active)
' "$output"
}

read -r display_exists display_disabled active_displays < <(monitor_state <<<"$monitors")

if [[ "$display_exists" != "true" ]]; then
  printf '{"text":"󰶐","tooltip":"Internal display %s is not connected","class":"disconnected"}\n' "$output"
  exit 0
fi

if [[ "$action" == "toggle" ]]; then
  # Enabling is always safe: allow it even when an external monitor is the
  # only active display. The active-display guard applies only to disabling.
  if [[ "$display_disabled" == "true" ]]; then
    if ! hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = false, mode = "1920x1080@60", position = "3840x0", scale = 1.5 })' >/dev/null 2>&1; then
      printf '{"text":"󰍹","tooltip":"Failed to enable the internal display","class":"error"}\n'
      exit 0
    fi
    rm -f -- "$disabled_marker"
  elif (( active_displays > 1 )); then
    if ! hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })' >/dev/null 2>&1; then
      printf '{"text":"󰍹","tooltip":"Failed to disable the internal display","class":"error"}\n'
      exit 0
    fi
    mkdir -p -- "${disabled_marker%/*}"
    : >"$disabled_marker"
  else
    printf '{"text":"󰍹","tooltip":"Cannot disable the only active display","class":"error"}\n'
    exit 0
  fi

  monitors=$(hyprctl -j monitors all 2>/dev/null) || true
  read -r _ display_disabled _ < <(monitor_state <<<"$monitors")
fi

if [[ "$display_disabled" == "true" ]]; then
  printf '{"text":"󰶐","tooltip":"Internal display: off\\nClick to enable","class":"disabled"}\n'
else
  printf '{"text":"󰍹","tooltip":"Internal display: on\\nClick to disable","class":"enabled"}\n'
fi
