#!/usr/bin/env bash

set -u

action="${1:-status}"
output="DP-1"

get_monitors() {
  hyprctl -j monitors all 2>/dev/null
}

json_status() {
  python3 -c '
import json, sys
print(json.dumps({"text": sys.argv[1], "tooltip": sys.argv[2], "class": sys.argv[3]}, ensure_ascii=False))
' "$1" "$2" "$3"
}

monitor_state() {
  python3 -c '
import json, sys

monitors = json.load(sys.stdin)
output = sys.argv[1]
display = next((item for item in monitors if item.get("name") == output), None)
if display is None:
    print("missing 0 0")
elif display.get("disabled", False):
    print("disabled 0 0")
else:
    print("active", display.get("width", 0), display.get("height", 0))
' "$output"
}

print_status() {
  local monitors state width height

  monitors=$(get_monitors) || {
    json_status "󰊴" "Hyprland display status is unavailable" "error"
    return
  }

  read -r state width height < <(monitor_state <<<"$monitors")

  case "$state" in
    missing|disabled)
      json_status "󰊴" "Game mode unavailable: $output is not active" "disconnected"
      ;;
    active)
      if (( width == 1920 && height == 1080 )); then
        json_status "󰊴 1080p" $'Game mode: on\n'"$output"$': 1920x1080 at scale 1\nClick to restore native 4K' "enabled"
      else
        json_status "󰊴" $'Game mode: off\n'"$output: ${width}x${height}"$'\nClick for 1920x1080' "native"
      fi
      ;;
  esac
}

if [[ "$action" == "toggle" ]]; then
  monitors=$(get_monitors) || {
    json_status "󰊴" "Hyprland display status is unavailable" "error"
    exit 0
  }

  read -r state width height < <(monitor_state <<<"$monitors")

  if [[ "$state" != "active" ]]; then
    json_status "󰊴" "Cannot change resolution: $output is not active" "error"
    exit 0
  fi

  if (( width == 1920 && height == 1080 )); then
    command='hl.monitor({ output = "DP-1", mode = "3840x2160@60", position = "1920x0", scale = 2 })'
  else
    command='hl.monitor({ output = "DP-1", mode = "1920x1080@60", position = "1920x0", scale = 1 })'
  fi

  if ! hyprctl eval "$command" >/dev/null 2>&1; then
    json_status "󰊴" "Failed to change $output resolution" "error"
    exit 0
  fi
fi

print_status
