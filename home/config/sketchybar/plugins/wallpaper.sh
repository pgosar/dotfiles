#!/usr/bin/env zsh
# Wallpaper picker popup shell for sketchybar (MacBook).
# Hover the notch to reveal the popup window; wallpaper cards and
# carousel motion are added in later commits.

set -u
setopt NULL_GLOB
export PATH="/opt/homebrew/bin:/usr/bin:/bin:$PATH"
SCRIPT="$0"
PARENT="wallpaper.notch"
STATE_DIR="/tmp/sketchybar-wallpaper"
mkdir -p "$STATE_DIR"

# All cards render at the same size.
CARD_W=168
CARD_H=96

bump_gen() {
  local gen=0
  [ -f "$STATE_DIR/gen" ] && gen=$(cat "$STATE_DIR/gen" 2>/dev/null || echo 0)
  printf '%s' $((gen + 1)) > "$STATE_DIR/gen"
}

close_popup_items() {
  sketchybar --set "$PARENT" popup.drawing=off 2>/dev/null
  sketchybar --remove '/^wallpaper\.slot_/' 2>/dev/null
  rm -f "$STATE_DIR/open"
}

# A `sketchybar --reload` (apply_theme.py runs one after applying a
# wallpaper) wipes these runtime-created items while the open marker
# survives it, so verify the items are really there instead of trusting
# the marker alone.
popup_alive() {
  sketchybar --query "wallpaper.slot_3" >/dev/null 2>&1
}

show_popup() {
  bump_gen
  if [ -f "$STATE_DIR/open" ] && popup_alive; then
    return 0
  fi
  rm -f "$STATE_DIR/open"
  # Clear leftovers from a partial wipe or a raced earlier show so the
  # adds below start from a clean slate.
  sketchybar --remove '/^wallpaper\.slot_/' 2>/dev/null
  sketchybar --remove '/^wallpaper\.arrow_/' 2>/dev/null

  local s
  for s in 1 2 3 4 5; do
    sketchybar --add item "wallpaper.slot_$s" "popup.$PARENT" \
      --set "wallpaper.slot_$s" \
      icon.drawing=off label.drawing=off \
      width=$CARD_W background.height=$CARD_H \
      background.drawing=on background.corner_radius=10 \
      script="$SCRIPT" \
      --subscribe "wallpaper.slot_$s" mouse.entered mouse.exited
  done

  touch "$STATE_DIR/open"
  sketchybar --set "$PARENT" popup.drawing=on
}

# Grace period after the pointer leaves before the popup closes: without
# it a slow move from the notch down to the cards kills the popup mid-transit.
# Any mouse.entered bumps the generation and cancels a pending close.
HIDE_DELAY=0.6

hide_popup() {
  local mygen=$(cat "$STATE_DIR/gen" 2>/dev/null || echo 0)
  ( sleep "$HIDE_DELAY"
    [ "$(cat "$STATE_DIR/gen" 2>/dev/null || echo 0)" = "$mygen" ] \
      && close_popup_items
  ) &!
}

# Sketchybar fires event scripts with $SENDER set and no positional args.
case "${SENDER:-}" in
  mouse.entered)
    case "${NAME:-}" in
      wallpaper.slot_*) bump_gen ;;
      *) show_popup ;;
    esac
    ;;
  mouse.exited) hide_popup ;;
esac
