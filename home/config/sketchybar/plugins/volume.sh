#!/usr/bin/env zsh
source "$HOME/.config/sketchybar/colors.sh"

# volume_change passes the new level in $INFO; otherwise read it directly
# so the label is correct on load, not just after the first change.
VOLUME=${INFO:-$(osascript -e "output volume of (get volume settings)")}

case ${VOLUME} in
0)
  ICON=""
  ICON_PADDING_RIGHT=21
  ;;
[1-2][0-9] | 30)
  ICON=""
  ICON_PADDING_RIGHT=12
  ;;
*)
  ICON=""
  ICON_PADDING_RIGHT=6
  ;;
esac

sketchybar --set $NAME icon=$ICON icon.padding_right=$ICON_PADDING_RIGHT label="${VOLUME}%" icon.color=$BLUE
