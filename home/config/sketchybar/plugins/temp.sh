#!/usr/bin/env zsh

# get temperature
TEMPERATURE=$($HOME/.local/bin/smctemp -c) # you can use (which smctemp) to replace this path if your install path is different

# check smctemp whether running well
if [ $? -ne 0 ]; then
  echo "Error: Unable to get temperature."
  exit 1
fi

sketchybar --set $NAME icon.padding_right=5 label="${TEMPERATURE}󰔄"
