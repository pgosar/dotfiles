#!/usr/bin/env zsh
source "$HOME/.config/sketchybar/colors.sh"

# get temperature
TEMPERATURE=$($HOME/.local/bin/smctemp -c)

# check smctemp whether running well
if [ $? -ne 0 ]; then
  echo "Error: Unable to get temperature."
  exit 1
fi

sketchybar --set $NAME icon.padding_right=5 label="${TEMPERATURE}󰔄" icon.color=$BLUE
