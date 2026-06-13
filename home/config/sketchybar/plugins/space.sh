#!/usr/bin/env zsh
args=()
active_space=$(yabai -m query --spaces --space | jq '.index')
while read -r index window; do
  if [ "$index" = "$active_space" ]; then
    color="0xff8aadf4" # Active space color (blue)
  else
    color="0xff000000" # Inactive space color (translucent white)
  fi

  if [ "$window" = "null" ]; then
    args+=(--set "space${index}" "icon=${index}" "background.color=${color}")
  else
    args+=(--set "space${index}" "icon=${index}°" "background.color=${color}")
  fi
done <<< "$(yabai -m query --spaces | jq -r '.[] | [.index, .windows[0]] | @sh')"
sketchybar -m "${args[@]}"
