#!/usr/bin/env bash

set -u

proxy_host=127.0.0.1
http_port=2080
socks_port=2081
config_file="${WAYBAR_XRAY_CONFIG:-$HOME/.config/xray/waybar.json}"
runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
pid_file="$runtime_dir/waybar-xray.pid"
log_file="$runtime_dir/waybar-xray.log"
action="${1:-status}"

proxy_mode() {
  gsettings get org.gnome.system.proxy mode 2>/dev/null | tr -d "'"
}

core_ready() {
  timeout 1 bash -c "</dev/tcp/$proxy_host/$http_port" 2>/dev/null
}

xray_pid() {
  local pid
  [ -r "$pid_file" ] || return 1
  read -r pid < "$pid_file"
  [[ "$pid" =~ ^[0-9]+$ ]] || return 1
  kill -0 "$pid" 2>/dev/null || return 1
  tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null | grep -Fq "$config_file" || return 1
  printf '%s' "$pid"
}

enable_system_proxy() {
  gsettings set org.gnome.system.proxy.http host "$proxy_host"
  gsettings set org.gnome.system.proxy.http port "$http_port"
  gsettings set org.gnome.system.proxy.https host "$proxy_host"
  gsettings set org.gnome.system.proxy.https port "$http_port"
  gsettings set org.gnome.system.proxy.ftp host "$proxy_host"
  gsettings set org.gnome.system.proxy.ftp port "$http_port"
  gsettings set org.gnome.system.proxy.socks host "$proxy_host"
  gsettings set org.gnome.system.proxy.socks port "$socks_port"
  gsettings set org.gnome.system.proxy mode manual
}

disable_system_proxy() {
  gsettings set org.gnome.system.proxy mode none
}

start_xray() {
  command -v xray >/dev/null 2>&1 || return 1
  [ -r "$config_file" ] || return 1
  core_ready && return 2

  xray run -config "$config_file" >"$log_file" 2>&1 &
  local pid=$!
  printf '%s\n' "$pid" > "$pid_file"

  for _ in {1..40}; do
    if core_ready; then
      enable_system_proxy
      return 0
    fi
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.25
  done

  kill "$pid" 2>/dev/null || true
  rm -f "$pid_file"
  return 1
}

stop_xray() {
  local pid
  pid=$(xray_pid) || return 1
  disable_system_proxy
  kill "$pid" 2>/dev/null || true
  for _ in {1..20}; do
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.1
  done
  rm -f "$pid_file"
}

if [[ "$action" == "toggle" ]]; then
  if xray_pid >/dev/null; then
    stop_xray
  else
    start_xray
    result=$?
    if (( result == 2 )); then
      printf '{"text":"󰒎","tooltip":"Port %s is already used by another proxy (possibly Throne)","class":"error"}\n' "$http_port"
      exit 0
    elif (( result != 0 )); then
      printf '{"text":"󰒎","tooltip":"Xray failed to start; see %s","class":"error"}\n' "$log_file"
      exit 0
    fi
  fi
fi

if xray_pid >/dev/null && core_ready && [[ "$(proxy_mode)" == "manual" ]]; then
  printf '{"text":"󰒍","tooltip":"Xray system proxy: connected\\nClick to disconnect","class":"connected"}\n'
elif xray_pid >/dev/null && core_ready; then
  printf '{"text":"󰒎","tooltip":"Xray is running; system proxy is off","class":"disconnected"}\n'
elif core_ready; then
  printf '{"text":"󰒎","tooltip":"Another proxy is using port %s (possibly Throne)","class":"error"}\n' "$http_port"
else
  printf '{"text":"󰒎","tooltip":"Xray system proxy: disconnected\\nClick to connect","class":"stopped"}\n'
fi
