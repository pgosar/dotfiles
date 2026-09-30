#!/usr/bin/env zsh
# Rotating wallpaper carousel popup for sketchybar (MacBook).
# Hover the notch to reveal a carousel of same-size wallpaper cards;
# click any card to apply it via apply_theme.py (theme + picture),
# or use the arrows to rotate the carousel.
# Set WALLPAPER_DIR to use a folder other than ~/Pictures/Wallpapers.
# Clicks are serialized with a lock dir: rapid clicks run as separate
# processes, and without it the position file and rendered cards race.

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
  for f in "$WALLS_DIR"/*.png "$WALLS_DIR"/*.jpg \
           "$WALLS_DIR"/*.jpeg "$WALLS_DIR"/*.webp; do
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

# mkdir is atomic: only one click process holds the lock at a time.
# A lock whose owner died is dropped instead of deadlocking.
acquire_lock() {
  local lock="$STATE_DIR/lock" i holder
  for i in {1..100}; do
    if mkdir "$lock" 2>/dev/null; then
      printf '%s' "$$" > "$lock/pid"
      return 0
    fi
    holder=$(cat "$lock/pid" 2>/dev/null || echo 0)
    kill -0 "$holder" 2>/dev/null || rm -rf "$lock"
    sleep 0.02
  done
  return 1
}

release_lock() { rm -rf "$STATE_DIR/lock"; }

close_popup_items() {
  sketchybar --set "$PARENT" popup.drawing=off 2>/dev/null
  sketchybar --remove '/^wallpaper\.slot_/' 2>/dev/null
  sketchybar --remove '/^wallpaper\.arrow_/' 2>/dev/null
  rm -f "$STATE_DIR/open"
}

# Render the 5 slots around the centered index (modulo wraps, so any
# number of wallpapers fits). Slots bind their offset from center, so a
# click always resolves against the live position, never a stale one.
render() {
  local -a files
  files=("${(@f)$(wallpapers)}")
  local n=${#files[@]}
  [ "$n" -eq 0 ] && return 1
  local center=$(cat "$STATE_DIR/idx" 2>/dev/null || echo 1)
  center=$(( (center - 1) % n + 1 ))
  (( center < 1 )) && center=$((center + n))
  printf '%s' "$center" > "$STATE_DIR/idx"

  local args=(--animate tanh 12) o s wi f t
  for o in -2 -1 0 1 2; do
    s=$((o + 3))
    wi=$(( (center - 1 + o) % n + 1 ))
    (( wi < 1 )) && wi=$((wi + n))
    f="${files[$wi]}"
    t="$(thumb_for "$f")"
    args+=(--set "wallpaper.slot_$s"
      background.image="${t:-}"
      click_script="$SCRIPT slotclick $o")
    if (( o == 0 )); then
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

  # Arrows bracket the cards so the framed center card is truly centered.
  # Opaque pills: a bare glyph would wash out against a bright wallpaper.
  add_arrow() { # $1 = l|r, $2 = -1|1
    sketchybar --add item "wallpaper.arrow_$1" "popup.$PARENT" \
      --set "wallpaper.arrow_$1" \
      icon.drawing=off \
      background.drawing=on background.color=0xe62c2c2e \
      background.corner_radius=16 \
      label="$([ "$1" = l ] && printf '‹' || printf '›')" \
      label.font="SF Pro:Bold:24.0" label.color=0xffffffff \
      label.padding_left=12 label.padding_right=12 \
      click_script="$SCRIPT rotate $2" \
      script="$SCRIPT" \
      --subscribe "wallpaper.arrow_$1" mouse.entered mouse.exited
  }
  add_arrow l -1

  local s
  for s in 1 2 3 4 5; do
    sketchybar --add item "wallpaper.slot_$s" "popup.$PARENT" \
      --set "wallpaper.slot_$s" \
      icon.drawing=off label.drawing=off \
      width=$CARD_W background.height=$CARD_H \
      background.drawing=on background.corner_radius=10 \
      background.image.drawing=on \
      script="$SCRIPT" \
      --subscribe "wallpaper.slot_$s" mouse.entered mouse.exited
  done

  add_arrow r 1

  [ -f "$STATE_DIR/idx" ] || printf '1' > "$STATE_DIR/idx"
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

rotate() { # $1 = -1 or 1
  acquire_lock || return 0
  trap 'release_lock' EXIT
  local -a files
  files=("${(@f)$(wallpapers)}")
  local n=${#files[@]}
  if (( n > 0 )); then
    local center=$(cat "$STATE_DIR/idx" 2>/dev/null || echo 1)
    center=$(( (center - 1 + $1) % n + 1 ))
    (( center < 1 )) && center=$((center + n))
    printf '%s' "$center" > "$STATE_DIR/idx"
    bump_gen
    render
  fi
  release_lock
}

slotclick() { # $1 = slot offset from center (-2..2); applies that wallpaper
  acquire_lock || return 0
  trap 'release_lock' EXIT
  local -a files
  files=("${(@f)$(wallpapers)}")
  local n=${#files[@]}
  if (( n > 0 )); then
    local center=$(cat "$STATE_DIR/idx" 2>/dev/null || echo 1)
    center=$(( (center - 1) % n + 1 ))
    (( center < 1 )) && center=$((center + n))
    local t=$(( (center - 1 + $1) % n + 1 ))
    (( t < 1 )) && t=$((t + n))
    printf '%s' "$t" > "$STATE_DIR/idx"
    bump_gen
    "$APPLY_THEME" "${files[$t]}" >/tmp/sketchybar-wallpaper.log 2>&1 &
    close_popup_items
  fi
  release_lock
}

# Sketchybar fires event scripts with $SENDER set and no positional args;
# click_script lines invoke "$SCRIPT <cmd> ..." with positional args instead.
case "${1:-}" in
  rotate) rotate "$2" ;;
  slotclick) slotclick "$2" ;;
  *)
    case "${SENDER:-}" in
      mouse.entered)
        case "${NAME:-}" in
          wallpaper.slot_*|wallpaper.arrow_*) bump_gen ;;
          *) show_popup ;;
        esac
        ;;
      mouse.exited) hide_popup ;;
    esac
    ;;
esac
