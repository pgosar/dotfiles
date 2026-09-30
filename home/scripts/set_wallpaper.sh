#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=home/scripts/paths.sh
source "$SCRIPT_DIR/paths.sh"

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

# Generate and apply colors via Pywal; abort before touching the
# wallpaper if theme generation fails so they never go out of sync
if ! python3 "$AUTO_THEME_SCRIPT" "$WALLPAPER"; then
  echo "Error: theme generation failed; aborting."
  exit 1
fi

if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
  echo "Running under KDE, applying wallpaper using plasma-apply-wallpaperimage..."
  plasma-apply-wallpaperimage "$WALLPAPER"
else
  # Update Hyprland wallpaper (theme reloads are handled by apply_theme.py)
  hyprctl hyprpaper preload "$WALLPAPER"
  hyprctl hyprpaper wallpaper ",$WALLPAPER"
  hyprctl hyprpaper unload all

  cat << EOF > "$HYPRPAPER_CONFIG"
splash = false
ipc = on

preload = $WALLPAPER

wallpaper {
    monitor = 
    path = $WALLPAPER
    fit_mode = cover
}
EOF

  # Sync wallpaper to Hyprlock config background path (Hyprland-only)
  sed -i -E 's|^(    path = ).*$|\1'"$WALLPAPER"'|' "$HYPRLOCK_CONFIG"

fi

echo "Wallpaper and theme have been updated."
