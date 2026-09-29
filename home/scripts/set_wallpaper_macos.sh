#!/usr/bin/env bash
# macOS counterpart to set_wallpaper.sh: set wallpaper, regenerate the macOS
# pywal theme, and apply it to sketchybar + window borders.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$1" ]; then
  echo "Usage: ./set_wallpaper_macos.sh <path-to-wallpaper>"
  exit 1
fi

WALLPAPER="$(realpath "$1")"

if [ ! -f "$WALLPAPER" ]; then
  echo "Error: File $WALLPAPER not found."
  exit 1
fi

echo "Setting wallpaper to $WALLPAPER..."
osascript -e "tell application \"System Events\" to set picture of every desktop to \"$WALLPAPER\""

# auto_theme.py defaults to theme-macos.json on darwin and applies it
if ! python3 "$SCRIPT_DIR/auto_theme.py" "$WALLPAPER"; then
  echo "Error: theme generation failed; aborting."
  exit 1
fi

echo "Wallpaper and theme have been updated."
