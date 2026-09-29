#!/usr/bin/env zsh
source "$HOME/.config/sketchybar/colors.sh"
args=()
active_space=$(yabai -m query --spaces --space | jq '.index')
while read -r index window; do
  if [ "$index" = "$active_space" ]; then
    color="$PEACH" # Active space accent
  else
    color="$BAR_BG_DIM" # Inactive space, dimmed
  fi

  if [ "$window" = "null" ]; then
    args+=(--set "space${index}" "icon=${index}" "background.color=${color}")
  else
    args+=(--set "space${index}" "icon=${index}°" "background.color=${color}")
  fi
done <<< "$(yabai -m query --spaces | jq -r '.[] | [.index, .windows[0]] | @sh')"
sketchybar -m "${args[@]}"
