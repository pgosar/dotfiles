#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo "Usage: ./set_wallpaper.sh <path-to-wallpaper>"
	exit 1
fi

WALLPAPER=$(realpath "$1")

if [ ! -f "$WALLPAPER" ]; then
	echo "Error: File $WALLPAPER not found."
	exit 1
fi

echo "Setting wallpaper to $WALLPAPER..."

# Generate and apply colors via Pywal
python3 ~/code/dotfiles/config/auto_theme.py "$WALLPAPER"

# Update Hyprland
hyprctl reload
hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper "desc:Microstep MPG321UX OLED 0x01010101,$WALLPAPER"
hyprctl hyprpaper wallpaper "desc:Samsung Electric Company Odyssey G5 HNBY700285,$WALLPAPER"
hyprctl hyprpaper unload all

cat <<EOF >~/code/dotfiles/config/hypr/hyprpaper.conf
source = ~/.config/hypr/monitors.conf
splash = false
ipc = on

wallpaper {
    monitor = \$monitor1
    path = $WALLPAPER
    fit_mode = cover
}

wallpaper {
    monitor = \$monitor2
    path = $WALLPAPER
    fit_mode = cover
}
EOF

killall waybar
waybar &
disown # remove jobs from shell table so terminal can be closed

echo "Wallpaper and theme have been updated."
