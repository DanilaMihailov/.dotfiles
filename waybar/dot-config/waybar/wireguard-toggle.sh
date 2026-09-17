#!/usr/bin/env bash

set -u

action="${1:-status}"
requested_connection="${2:-${WAYBAR_WIREGUARD_CONNECTION:-}}"

# custom/wireguard listens for SIGRTMIN+8.
if [[ "$action" == "toggle" ]]; then
  trap 'pkill -RTMIN+8 -x waybar 2>/dev/null || true' EXIT
fi

json_escape() {
  local value=${1//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  printf '%s' "$value"
}

profiles=$(nmcli --terse --escape no --fields UUID,TYPE,NAME connection show 2>/dev/null) || {
  printf '{"text":"󰖂","tooltip":"NetworkManager is unavailable","class":"error"}\n'
  exit 0
}

if [[ -n "$requested_connection" ]]; then
  profile=$(printf '%s\n' "$profiles" | awk -F: -v wanted="$requested_connection" '
    $2 == "wireguard" && ($1 == wanted || substr($0, length($1) + length($2) + 3) == wanted) { print; exit }
  ')
else
  profile=$(printf '%s\n' "$profiles" | awk -F: '$2 == "wireguard" { print; exit }')
fi

if [[ -z "${profile:-}" ]]; then
  printf '{"text":"󰖂","tooltip":"No NetworkManager WireGuard connection found","class":"error"}\n'
  exit 0
fi

uuid=${profile%%:*}
connection_name=${profile#*:}
connection_name=${connection_name#*:}

is_active() {
  nmcli --terse --fields UUID connection show --active 2>/dev/null | grep -Fxq "$uuid"
}

if [[ "$action" == "toggle" ]]; then
  if is_active; then
    nmcli connection down uuid "$uuid" >/dev/null 2>&1
  else
    nmcli connection up uuid "$uuid" >/dev/null 2>&1
  fi
fi

escaped_name=$(json_escape "$connection_name")
if is_active; then
  printf '{"text":"󰖂","tooltip":"WireGuard: %s (connected)\\nClick to disconnect","class":"connected"}\n' "$escaped_name"
else
  printf '{"text":"󰖂","tooltip":"WireGuard: %s (disconnected)\\nClick to connect","class":"disconnected"}\n' "$escaped_name"
fi
