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

case $tooltip in
  *"unread mentions"*) class=private ;;
  *"unread channels"*) class=channel ;;
  *) class=idle ;;
esac

[ -n "$tooltip" ] || tooltip=Mattermost
jq -cn --arg class "$class" --arg tooltip "$tooltip" \
  '{text:"", class:$class, tooltip:$tooltip}'
