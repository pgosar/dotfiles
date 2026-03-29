#!/bin/bash
# Move window to a designated workspace

WS=$1
MONITOR_COUNT=$(hyprctl monitors -j | jq '. | length')

if [ "$MONITOR_COUNT" -eq 1 ]; then
    hyprctl dispatch movetoworkspace $WS
    exit 0
fi

FOCUSED_MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')
MONITOR1=$(grep '^\$monitor1' ~/.config/hypr/monitors.conf | cut -d'=' -f2 | xargs)
MONITOR2=$(grep '^\$monitor2' ~/.config/hypr/monitors.conf | cut -d'=' -f2 | xargs)

if [ "$FOCUSED_MONITOR" == "$MONITOR1" ]; then
    TARGET_WS=$WS
elif [ "$FOCUSED_MONITOR" == "$MONITOR2" ]; then
    TARGET_WS=$((WS + 10))
else
    # Fallback if somehow not on monitor 1 or 2
    TARGET_WS=$WS
fi

hyprctl dispatch movetoworkspace $TARGET_WS
