#!/bin/sh

items=$(busctl --user get-property \
  org.kde.StatusNotifierWatcher \
  /StatusNotifierWatcher \
  org.kde.StatusNotifierWatcher \
  RegisteredStatusNotifierItems 2>/dev/null) || items=

item=$(printf '%s\n' "$items" | sed -n 's/.*"\(:[^/]\+\/org\/chromium\/StatusNotifierItem\/[0-9]\+\)".*/\1/p')

if [ -z "$item" ]; then
  jq -cn '{text:""}'
  exit
fi

service=${item%%/*}
path=/${item#*/}
property=$(busctl --user get-property \
  "$service" \
  "$path" \
  org.kde.StatusNotifierItem \
  ToolTip 2>/dev/null) || property=
tooltip=$(printf '%s\n' "$property" | sed -n 's/.* 0 "\([^"]*\)" ""$/\1/p')

tooltip_lower=$(printf '%s' "$tooltip" | tr '[:upper:]' '[:lower:]')

case $tooltip_lower in
  *mention*)
    class=private
    text='<span letter_spacing="-10000"><span foreground="#fb4934" size="6000" rise="-500">●</span></span><span size="6000"> </span>'
    ;;
  *"unread channel"*)
    class=channel
    text='<span letter_spacing="-10000"><span foreground="#83a598" size="6000" rise="-500">●</span></span><span size="6000"> </span>'
    ;;
  *)
    class=idle
    text=''
    ;;
esac

[ -n "$tooltip" ] || tooltip=Mattermost
jq -cn --arg text "$text" --arg class "$class" --arg tooltip "$tooltip" \
  '{text:$text, class:$class, tooltip:$tooltip}'
