#!/usr/bin/env zsh

update_space() {
  SPACE_ID=$(echo "$INFO" | jq -r '."display-1"')

  sketchybar --set $NAME \
    icon=$SPACE_ID \
    icon.padding_left=9 \
    icon.padding_right=10
}

case "$SENDER" in
"mouse.clicked")
  # Reload sketchybar
  sketchybar --remove /.*/
  source $HOME/.config/sketchybar/sketchybarrc
  ;;
*)
  update_space
  ;;
esac
