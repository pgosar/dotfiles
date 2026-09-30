#!/usr/bin/env zsh
# Wallpaper picker popup for sketchybar (MacBook).
# Hover the notch to reveal same-size wallpaper cards; click a card to
# apply it via apply_theme.py (theme + picture). Carousel motion comes
# in a later commit.

set -u
setopt NULL_GLOB
export PATH="/opt/homebrew/bin:/usr/bin:/bin:$PATH"
SCRIPT="$0"
REPO_HOME="$(cd "$(dirname "$(readlink -f "$SCRIPT")")/../../.." && pwd)"
if [ -n "${WALLPAPER_DIR:-}" ]; then
  WALLS_DIR="$WALLPAPER_DIR"
elif [ -d "$HOME/Pictures/Wallpapers" ]; then
  WALLS_DIR="$HOME/Pictures/Wallpapers"
else
  WALLS_DIR="$REPO_HOME/walls"
fi
APPLY_THEME="$REPO_HOME/scripts/apply_theme.py"
PARENT="wallpaper.notch"
STATE_DIR="/tmp/sketchybar-wallpaper"
THUMB_DIR="$STATE_DIR/thumbs"
mkdir -p "$STATE_DIR" "$THUMB_DIR"

# All cards render at the same size.
CARD_W=168
CARD_H=96

wallpapers() {
  for f in "$WALLS_DIR"/*.png "$WALLS_DIR"/*.jpg "$WALLS_DIR"/*.jpeg \
           "$WALLS_DIR"/*.webp; do
    [ -f "$f" ] && printf '%s\n' "$f"
  done | LC_ALL=C sort -u
}

# Thumbnails are cropped to exactly the card size: anything larger would
# spill over the card and cover the neighboring arrow.
thumb_for() {
  local f="$1" t
  t="$THUMB_DIR/$(printf '%s' "${CARD_W}x${CARD_H}:$f" | md5 -q).png"
  if [ ! -f "$t" ]; then
    python3 - "$f" "$t" "$CARD_W" "$CARD_H" <<'EOF' >/dev/null 2>&1
import sys
from PIL import Image, ImageOps
src, dst, w, h = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
ImageOps.fit(Image.open(src).convert("RGB"), (w, h), Image.LANCZOS).save(dst)
EOF
  fi
  [ -f "$t" ] && printf '%s' "$t"
}

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

# Render one same-size card per wallpaper; the middle card gets the
# selection frame. Clicking any card applies it.
render() {
  local -a files
  files=("${(@f)$(wallpapers)}")
  local n=${#files[@]}
  [ "$n" -eq 0 ] && return 1
  local args=() s f t
  for s in 1 2 3 4 5; do
    (( s > n )) && break
    f="${files[$s]}"
    t="$(thumb_for "$f")"
    args+=(--set "wallpaper.slot_$s"
      background.image="${t:-}" background.image.drawing=on
      click_script="$SCRIPT select $s")
    if (( s == 3 )); then
      args+=(background.border_width=2 background.border_color=0xffffffff)
    else
      args+=(background.border_width=0)
    fi
  done
  sketchybar "${args[@]}" 2>/dev/null
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
  local -a files
  files=("${(@f)$(wallpapers)}")
  [ "${#files[@]}" -eq 0 ] && return 0

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

  render || return 1
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

select_wallpaper() { # $1 = wallpaper index
  local -a files
  files=("${(@f)$(wallpapers)}")
  (( $1 >= 1 && $1 <= ${#files[@]} )) || return 0
  bump_gen
  "$APPLY_THEME" "${files[$1]}" >/tmp/sketchybar-wallpaper.log 2>&1 &
  close_popup_items
}

# Sketchybar fires event scripts with $SENDER set and no positional args;
# click_script lines invoke "$SCRIPT <cmd> ..." with positional args instead.
case "${1:-}" in
  select) select_wallpaper "$2" ;;
  *)
    case "${SENDER:-}" in
      mouse.entered)
        case "${NAME:-}" in
          wallpaper.slot_*) bump_gen ;;
          *) show_popup ;;
        esac
        ;;
      mouse.exited) hide_popup ;;
    esac
    ;;
esac
