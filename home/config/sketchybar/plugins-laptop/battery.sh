#!/usr/bin/env zsh
source "$HOME/.config/sketchybar/colors.sh"

# Battery is here because the ICON_COLOR doesn't play well with all background colors

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ $PERCENTAGE = "" ]; then
  exit 0
fi

case ${PERCENTAGE} in
[8-9][0-9] | 100)
  ICON=""
  ICON_COLOR=$GREEN
  ;;
7[0-9])
  ICON=""
  ICON_COLOR=$PEACH
  ;;
[4-6][0-9])
  ICON=""
  ICON_COLOR=$PEACH
  ;;
[1-3][0-9])
  ICON=""
  ICON_COLOR=$BLUE
  ;;
[0-9])
  ICON=""
  ICON_COLOR=$BLUE
  ;;
esac

if [[ $CHARGING != "" ]]; then
  ICON=""
  ICON_COLOR=$PEACH
fi

sketchybar --set $NAME \
  icon=$ICON \
  label="${PERCENTAGE}%" \
  icon.color=$GREEN
