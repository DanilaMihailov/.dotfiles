#!/usr/bin/env bash

set -u

proxy_host=127.0.0.1
proxy_port=2080
action="${1:-status}"

proxy_mode() {
  gsettings get org.gnome.system.proxy mode 2>/dev/null | tr -d "'"
}

core_ready() {
  timeout 1 bash -c "</dev/tcp/$proxy_host/$proxy_port" 2>/dev/null
}

enable_proxy() {
  if ! core_ready; then
    /home/zen/.config/Throne/start-with-system-proxy.sh >/dev/null 2>&1 &
    for _ in {1..40}; do
      core_ready && break
      sleep 0.25
    done
  fi

  core_ready || return 1

  gsettings set org.gnome.system.proxy.http host "$proxy_host"
  gsettings set org.gnome.system.proxy.http port "$proxy_port"
  gsettings set org.gnome.system.proxy.https host "$proxy_host"
  gsettings set org.gnome.system.proxy.https port "$proxy_port"
  gsettings set org.gnome.system.proxy.socks host "$proxy_host"
  gsettings set org.gnome.system.proxy.socks port "$proxy_port"
  gsettings set org.gnome.system.proxy mode manual
}

disable_proxy() {
  gsettings set org.gnome.system.proxy mode none
}

if [[ "$action" == "toggle" ]]; then
  if [[ "$(proxy_mode)" == "manual" ]]; then
    disable_proxy
  else
    enable_proxy || true
  fi
fi

if [[ "$(proxy_mode)" == "manual" ]] && core_ready; then
  printf '{"text":"󰒍","tooltip":"Throne system proxy: on\\nClick to turn off","class":"connected"}\n'
elif core_ready; then
  printf '{"text":"󰒎","tooltip":"Throne is ready; system proxy is off\\nClick to turn on","class":"disconnected"}\n'
else
  printf '{"text":"󰒎","tooltip":"Throne proxy is not running\\nClick to start and enable","class":"stopped"}\n'
fi
