#!/usr/bin/env bash

set -u

action="${1:-status}"
output="eDP-1"
state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
runtime_home="${XDG_RUNTIME_DIR:-/tmp}"
disabled_marker="$state_home/hyprland/internal-display-disabled"
fallback_marker="$runtime_home/hyprland-internal-display-fallback"
lid_marker="$runtime_home/hyprland-internal-display-lid-closed"
lock_file="$runtime_home/hyprland-internal-display.lock"

if [[ "$action" == "watch" ]]; then
  instance="${HYPRLAND_INSTANCE_SIGNATURE:-}"
  [[ -n "$instance" ]] || exit 1
  watch_lock="$runtime_home/hyprland-internal-display-watch-$instance.lock"
  # Keep one watcher per Hyprland session. Polling also covers missed hotplug
  # events and dock changes that Hyprland has not processed yet.
  exec 8>"$watch_lock"
  flock -n 8 || exit 0
  while [[ -S "$runtime_home/hypr/$instance/.socket.sock" ]]; do
    "$0" reconcile >/dev/null
    sleep 3
  done
  exit 0
fi

# Serialize hotplug, lid and manual actions. Monitor changes emit more events.
if [[ "$action" != "status" ]]; then
  exec 9>"$lock_file"
  flock -x 9
fi
if [[ "$action" == "toggle" ]]; then
  trap 'pkill -RTMIN+10 -x waybar 2>/dev/null || true' EXIT
fi

monitor_state() {
  local monitors
  monitors=$(hyprctl -j monitors all 2>/dev/null) || return 1
  python3 -c '
import glob, json, sys

monitors = json.load(sys.stdin)
internal = next((m for m in monitors if m.get("name") == sys.argv[1]), None)

def physically_connected(name):
    paths = glob.glob("/sys/class/drm/card*-" + name + "/status")
    if not paths:
        # Hyprland creates a virtual FALLBACK output when all physical
        # displays are disabled. It must not count as an external monitor.
        return False
    try:
        return any(open(path).read().strip() == "connected" for path in paths)
    except OSError:
        return False

internal_connected = physically_connected(sys.argv[1])
external_active = sum(
    m.get("name") != sys.argv[1]
    and not m.get("disabled", False)
    and physically_connected(m.get("name", ""))
    for m in monitors
)
print(int(internal_connected), int(internal is None or internal.get("disabled", False)),
      external_active)
' "$output" <<<"$monitors"
}

state=$(monitor_state) || {
  printf '{"text":"󰍹","tooltip":"Hyprland display status is unavailable","class":"error"}\n'
  exit 0
}
read -r display_exists display_disabled external_active <<<"$state"

apply_monitor() {
  local disabled="$1"
  if (( disabled )); then
    hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })' >/dev/null 2>&1
  else
    hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = false, mode = "1920x1080@60", position = "5120x0", scale = 1.25 })' >/dev/null 2>&1
  fi
}

error_status() {
  printf '{"text":"󰍹","tooltip":"Failed to change the internal display","class":"error"}\n'
  exit 0
}

if [[ "$action" == "toggle" ]]; then
  if [[ -e "$disabled_marker" ]]; then
    # A manual enable cancels the saved preference, even after a fallback.
    rm -f -- "$disabled_marker"
    rm -f -- "$fallback_marker"
  elif (( external_active > 0 && display_exists && ! display_disabled )); then
    mkdir -p -- "${disabled_marker%/*}"
    : >"$disabled_marker"
  fi
elif [[ "$action" == "lid-close" ]]; then
  : >"$lid_marker"
elif [[ "$action" == "lid-open" ]]; then
  rm -f -- "$lid_marker"
fi

if [[ "$action" != "status" ]] && (( display_exists )); then
  # Refresh lid state on startup and after resume, when a switch event might
  # have occurred before Hyprland was ready to receive it.
  if [[ "$action" == "reconcile" ]]; then
    for lid_state_file in /proc/acpi/button/lid/*/state; do
      if [[ -r "$lid_state_file" ]]; then
        read -r _ lid_state <"$lid_state_file"
        if [[ "$lid_state" == "closed" ]]; then
          : >"$lid_marker"
        else
          rm -f -- "$lid_marker"
        fi
        break
      fi
    done
  fi

  # The fallback marker survives reloads, but only while no external output is
  # usable. The manual preference is never cleared by a temporary fallback.
  fallback_started=0
  if (( external_active == 0 )); then
    [[ -e "$fallback_marker" ]] || fallback_started=1
    : >"$fallback_marker"
  else
    rm -f -- "$fallback_marker"
  fi

  target_disabled=0
  if (( external_active > 0 )) && { [[ -e "$disabled_marker" ]] || [[ -e "$lid_marker" ]]; }; then
    target_disabled=1
  fi

  if (( target_disabled != display_disabled )); then
    # When the last output disappears, load the fallback into Hyprland's
    # configured monitor rule as well as the runtime monitor state.
    if (( fallback_started && ! target_disabled )); then
      hyprctl reload >/dev/null 2>&1 || true
    fi
    apply_monitor "$target_disabled" || error_status
    state=$(monitor_state) || error_status
    read -r display_exists display_disabled external_active <<<"$state"
  fi
fi

if (( ! display_exists )); then
  printf '{"text":"󰶐","tooltip":"Internal display %s is not connected","class":"disconnected"}\n' "$output"
elif (( display_disabled )); then
  if [[ -e "$lid_marker" && ! -e "$disabled_marker" ]]; then
    printf '{"text":"󰶐","tooltip":"Internal display: off (lid closed)","class":"disabled"}\n'
  else
    printf '{"text":"󰶐","tooltip":"Internal display: off\\nClick to enable","class":"disabled"}\n'
  fi
elif (( external_active == 0 )) && [[ ! -e "$disabled_marker" ]]; then
  printf '{"text":""}\n'
elif [[ -e "$disabled_marker" ]]; then
  printf '{"text":"󰍹","tooltip":"Internal display: on as the last display\\nClick to keep enabled","class":"enabled"}\n'
else
  printf '{"text":"󰍹","tooltip":"Internal display: on\\nClick to disable","class":"enabled"}\n'
fi
