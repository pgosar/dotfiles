#!/usr/bin/env zsh

# Focus is on when the DoNotDisturb store holds an active assertion.
FOCUS_ON=$(jq -r 'if (.data // [] | map(select(has("storeAssertionRecords"))) | length) > 0 then "on" else "off" end' \
  ~/Library/DoNotDisturb/DB/Assertions.json 2>/dev/null || echo "off")

if [[ $FOCUS_ON == "on" ]]; then
  sketchybar --set $NAME drawing=on
else
  sketchybar --set $NAME drawing=off
fi
