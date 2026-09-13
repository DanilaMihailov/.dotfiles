#!/usr/bin/env bash

set -u

today=$(date +%F)
clock_text=$(date '+%a %d %b  %H:%M')
month_title=$(date '+%Y %B')
month_grid=$(cal --color=never -m | tail -n +2)

events_json=$(timeout 3s chroncal event list \
  --from "$today" \
  --to "$today" \
  --output json 2>/dev/null) || events_json='[]'

jq -cn \
  --arg text "$clock_text" \
  --arg title "$month_title" \
  --arg calendar "$month_grid" \
  --argjson events "$events_json" '
  def markup_escape:
    gsub("&"; "&amp;")
    | gsub("<"; "&lt;")
    | gsub(">"; "&gt;");

  def event_line:
    (if .all_day then
       "All day"
     else
       (.start_time | fromdateiso8601 | strflocaltime("%H:%M"))
     end) as $time
    | "<span foreground=\"#b8bb26\">\($time)</span>  \(.title | markup_escape)";

  ($events
    | map(select(.status != "CANCELLED"))
    | sort_by(.start_time)
    | if length == 0 then
        "<span foreground=\"#928374\">No events today</span>"
      else
        map(event_line) | join("\n")
      end) as $agenda
  | {
      text: $text,
      tooltip: "<big>\($title)</big>\n<tt>\($calendar)</tt>\n\n<b>Today</b>\n\($agenda)"
    }
  '
