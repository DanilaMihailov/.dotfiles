#!/usr/bin/env bash

set -u

action="${1:-status}"
power_supply_root="${POWER_SUPPLY_ROOT:-/sys/class/power_supply}"

if [[ "$action" == "cycle" ]]; then
  current=$(powerprofilesctl get 2>/dev/null) || exit 1

  case "$current" in
    power-saver) next=balanced ;;
    balanced) next=performance ;;
    *) next=power-saver ;;
  esac

  powerprofilesctl set "$next" >/dev/null 2>&1 || exit 1
  pkill -RTMIN+12 -x waybar 2>/dev/null || true
  exit 0
fi

profile=$(powerprofilesctl get 2>/dev/null || printf 'unknown')

battery=
for candidate in "$power_supply_root"/BAT*; do
  if [[ -r "$candidate/capacity" && -r "$candidate/status" ]]; then
    battery=$candidate
    break
  fi
done

if [[ -z "$battery" ]]; then
  jq -cn --arg profile "$profile" \
    '{text:"", tooltip:("Battery unavailable\nProfile: " + $profile), class:["unavailable", $profile]}'
  exit 0
fi

capacity=$(<"$battery/capacity")
status=$(<"$battery/status")

if [[ ! "$capacity" =~ ^[0-9]+$ ]]; then
  jq -cn --arg profile "$profile" \
    '{text:"", tooltip:("Battery capacity unavailable\nProfile: " + $profile), class:["unavailable", $profile]}'
  exit 0
fi

if (( capacity <= 15 )); then
  level=critical
elif (( capacity <= 30 )); then
  level=warning
else
  level=normal
fi

if (( capacity <= 10 )); then
  icon=""
elif (( capacity <= 30 )); then
  icon=""
elif (( capacity <= 60 )); then
  icon=""
elif (( capacity <= 90 )); then
  icon=""
else
  icon=""
fi

if [[ "$status" == "Charging" ]]; then
  icon+=" "
fi

text=$icon
if [[ "$level" == "critical" ]]; then
  text+=" $capacity%"
fi

profile_label=${profile//-/ }
profile_label=${profile_label^}
status_class=${status,,}
status_class=${status_class// /-}
printf -v tooltip 'Battery: %s%%\nProfile: %s' "$capacity" "$profile_label"

jq -cn \
  --arg text "$text" \
  --arg tooltip "$tooltip" \
  --arg profile "$profile" \
  --arg level "$level" \
  --arg status "$status_class" \
  '{text:$text, tooltip:$tooltip, class:[$profile, $level, $status]}'
