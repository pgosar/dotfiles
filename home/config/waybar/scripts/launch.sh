#!/usr/bin/env bash

# Kill any existing waybar processes
pkill waybar
while pgrep -x waybar >/dev/null; do sleep 0.1; done

CONFIG_FILE="$HOME/.config/waybar/config"
STYLE_FILE="$HOME/.config/waybar/style.css"

# Launch waybar
exec waybar -c "$CONFIG_FILE" -s "$STYLE_FILE"
