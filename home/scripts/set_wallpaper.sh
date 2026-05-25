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
hyprctl hyprpaper wallpaper ",$WALLPAPER"
hyprctl hyprpaper unload all

cat <<EOF >~/code/dotfiles/config/hypr/hyprpaper.conf
splash = false
ipc = on

preload = $WALLPAPER

wallpaper {
    monitor = 
    path = $WALLPAPER
    fit_mode = cover
}
EOF

# Sync wallpaper to Hyprlock config background path
sed -i -E 's|^(    path = ).*$|\1'"$WALLPAPER"'|' ~/code/dotfiles/config/hypr/hyprlock.conf

killall waybar
waybar &
disown # remove jobs from shell table so terminal can be closed

echo "Wallpaper and theme have been updated."
