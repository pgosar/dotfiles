#!/usr/bin/env bash

# Kill any existing waybar processes
pkill waybar
while pgrep -x waybar >/dev/null; do sleep 0.1; done

CONFIG_FILE="$HOME/.config/waybar/config"
STYLE_FILE="$HOME/.config/waybar/style.css"
TEMP_CONFIG="/tmp/waybar_temp_config.json"

# Niri sets XDG_CURRENT_DESKTOP=niri in most setups, or we can check NIRI_SOCKET
if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
    jq '."group/island-left".modules |= map(select(test("hyprland")))' "$CONFIG_FILE" > "$TEMP_CONFIG"
elif [ "$XDG_CURRENT_DESKTOP" = "niri" ] || [ -n "$NIRI_SOCKET" ]; then
    jq '."group/island-left".modules |= map(select(test("niri")))' "$CONFIG_FILE" > "$TEMP_CONFIG"
else
    # Fallback if compositor is not detected properly
    cp "$CONFIG_FILE" "$TEMP_CONFIG"
fi

# Launch waybar with the temporary config and explicitly define the base style
exec waybar -c "$TEMP_CONFIG" -s "$STYLE_FILE"
