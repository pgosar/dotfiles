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
python3 ~/code/dotfiles/home/scripts/auto_theme.py "$WALLPAPER"

if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
  echo "Running under KDE, applying wallpaper using plasma-apply-wallpaperimage..."
  plasma-apply-wallpaperimage "$WALLPAPER"
else
  # Update Hyprland
  hyprctl reload
  hyprctl hyprpaper preload "$WALLPAPER"
  hyprctl hyprpaper wallpaper ",$WALLPAPER"
  hyprctl hyprpaper unload all

  cat << EOF > ~/code/dotfiles/home/config/hypr/hyprpaper.conf
splash = false
ipc = on

preload = $WALLPAPER

wallpaper {
    monitor = 
    path = $WALLPAPER
    fit_mode = cover
}
EOF
fi

# Sync wallpaper to Hyprlock config background path
sed -i -E 's|^(    path = ).*$|\1'"$WALLPAPER"'|' ~/code/dotfiles/home/config/hypr/hyprlock.conf

# Function to check if quickshell is an ancestor of this script
is_ancestor_quickshell() {
  local pid=$$
  while [ "$pid" -gt 1 ]; do
    local comm
    comm=$(ps -o comm= -p "$pid" 2> /dev/null | tr -d '[:space:]')
    if [ "$comm" = "quickshell" ]; then
      return 0
    fi
    pid=$(ps -o ppid= -p "$pid" 2> /dev/null | tr -d '[:space:]')
  done
  return 1
}

if is_ancestor_quickshell; then
  echo "Wallpaper changed from within quickshell; reloading colors dynamically."
else
  echo "Restarting quickshell to apply theme..."
  killall quickshell 2> /dev/null
  while pgrep -x quickshell > /dev/null; do sleep 0.1; done
  quickshell &
  disown
fi

echo "Wallpaper and theme have been updated."
