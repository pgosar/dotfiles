#!/bin/bash

# $1 is the workspace number passed from the keybind or Waybar (e.g., 1 or 11)
INPUT=$1
WS1=$(( INPUT % 10 ))
if [ "$WS1" -eq 0 ]; then
    WS1=10
fi
WS2=$(( WS1 + 10 )) # Calculates the secondary workspace (e.g., 11)

MONITOR_COUNT=$(hyprctl monitors -j | jq '. | length')

if [ "$MONITOR_COUNT" -eq 1 ]; then
    # If only 1 monitor is active, just switch to the primary workspace
    hyprctl dispatch workspace $WS1
else
    # Save the currently focused monitor so we don't yank focus unintentionally
    FOCUSED_MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')
    
    if [ "$WS1" -eq 10 ]; then
        # Gaming workspace exception: only switch monitor 1 so monitor 2 windows stay visible
        hyprctl --batch "dispatch workspace $WS1 ; dispatch focusmonitor $FOCUSED_MONITOR"
    else
        # If 2 or more monitors are active, switch both and restore focus using batch dispatch
        hyprctl --batch "dispatch workspace $WS1 ; dispatch workspace $WS2 ; dispatch focusmonitor $FOCUSED_MONITOR"
    fi
fi
