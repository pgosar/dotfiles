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
# Thumbnails live in a persistent cache, not /tmp: macOS wipes /tmp on
# reboot, which made every first hover after a reboot pay for generation.
THUMB_DIR="$HOME/.cache/sketchybar-wallpaper/thumbs"
mkdir -p "$STATE_DIR" "$THUMB_DIR"

# All cards render at the same size.
CARD_W=168
CARD_H=96

# Popup open/close animation: the popup slides down from the notch when it
# opens and back up into it when it closes. y_offset is the property that
# gives a slide without knowing the popup's content height. POPUP_Y_OPEN
# must match popup.y_offset in sketchybarrc-laptop.
POPUP_Y_OPEN=10
# Further up than the popup is tall (~116px: 96px cards + popup padding),
# so the popup starts fully retracted behind the bar and sweeps out of
# the top instead of appearing mostly visible and nudging down.
POPUP_Y_HIDDEN=-120
POPUP_ANIM_SECS=0.15

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
    # sips scales to cover the card then center-crops to exactly the card
    # size (verified 168x96 on all current wallpapers); ~2-3x faster than
    # python3 + PIL and needs no extra dependency. -s format png is
    # required: without it sips keeps the source format, so JPG
    # wallpapers came out as JPEG bytes in a .png file, which sketchybar
    # refuses to open.
    sips -s format png -Z "$CARD_W" --cropToHeightWidth "$CARD_H" "$CARD_W" "$f" --out "$t" >/dev/null 2>&1
  fi
  [ -f "$t" ] && printf '%s' "$t"
}

# Generate thumbnails for every wallpaper that lacks one. Runs in the
# background at bar load and after the popup opens, so the first hover
# never waits on generation.
warmup() {
  local -a files
  files=("${(@f)$(wallpapers)}")
  local f
  for f in "${files[@]}"; do
    thumb_for "$f" >/dev/null
  done
}

bump_gen() {
  local gen=0
  [ -f "$STATE_DIR/gen" ] && gen=$(cat "$STATE_DIR/gen" 2>/dev/null || echo 0)
  printf '%s' $((gen + 1)) >"$STATE_DIR/gen"
}

# mkdir is atomic: only one click process holds the lock at a time.
# A lock whose owner died is dropped instead of deadlocking.
acquire_lock() {
  local lock="$STATE_DIR/lock" i holder
  for i in {1..100}; do
    if mkdir "$lock" 2>/dev/null; then
      printf '%s' "$$" >"$lock/pid"
      return 0
    fi
    holder=$(cat "$lock/pid" 2>/dev/null || echo 0)
    kill -0 "$holder" 2>/dev/null || rm -rf "$lock"
    sleep 0.02
  done
  return 1
}

release_lock() { rm -rf "$STATE_DIR/lock"; }

# Slide the popup back up into the notch. Callers wait out the
# animation (the sleep below) and re-check their generation before
# removing the items.
slide_popup_up() {
  # Curve/duration written literally: zsh does not word-split a
  # variable, so --animate $VAR would pass "tanh 15" as one argument.
  sketchybar --animate tanh 6 --set "$PARENT" popup.y_offset=$POPUP_Y_HIDDEN 2>/dev/null
  sleep $POPUP_ANIM_SECS
}

close_popup_items() {
  sketchybar --set "$PARENT" popup.drawing=off 2>/dev/null
  sketchybar --remove '/^wallpaper\.slot_/' 2>/dev/null
  sketchybar --remove '/^wallpaper\.arrow_/' 2>/dev/null
  rm -f "$STATE_DIR/open"
  # Leave the offset at its resting value so the next open starts clean.
  sketchybar --set "$PARENT" popup.y_offset=$POPUP_Y_OPEN 2>/dev/null
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
  center=$(((center - 1) % n + 1))
  ((center < 1)) && center=$((center + n))
  printf '%s' "$center" >"$STATE_DIR/idx"

  local args=(--animate tanh 12) o s wi f t
  for o in -2 -1 0 1 2; do
    s=$((o + 3))
    wi=$(((center - 1 + o) % n + 1))
    ((wi < 1)) && wi=$((wi + n))
    f="${files[$wi]}"
    t="$(thumb_for "$f")"
    args+=(--set "wallpaper.slot_$s"
      background.image="${t:-}"
      click_script="$SCRIPT slotclick $o")
    if ((o == 0)); then
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
    # A close cancelled mid-slide leaves the popup raised; drop it back.
    sketchybar --animate tanh 6 --set "$PARENT" popup.y_offset=$POPUP_Y_OPEN 2>/dev/null
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

  # Add all popup items in one sketchybar call: one process spawn
  # instead of seven keeps the open fast.
  # Arrows bracket the cards so the framed center card is truly centered.
  # Opaque pills: a bare glyph would wash out against a bright wallpaper.
  local -a add_args
  add_args+=(--add item "wallpaper.arrow_l" "popup.$PARENT"
    --set "wallpaper.arrow_l"
    icon.drawing=off
    background.drawing=on background.color=0xe62c2c2e
    background.corner_radius=16
    label="‹"
    label.font="SF Pro:Bold:24.0" label.color=0xffffffff
    label.padding_left=12 label.padding_right=12
    click_script="$SCRIPT rotate -1"
    script="$SCRIPT"
    --subscribe "wallpaper.arrow_l" mouse.entered mouse.exited)
  local s
  for s in 1 2 3 4 5; do
    add_args+=(--add item "wallpaper.slot_$s" "popup.$PARENT"
      --set "wallpaper.slot_$s"
      icon.drawing=off label.drawing=off
      width=$CARD_W background.height=$CARD_H
      background.drawing=on background.corner_radius=10
      background.image.drawing=on
      script="$SCRIPT"
      --subscribe "wallpaper.slot_$s" mouse.entered mouse.exited)
  done
  add_args+=(--add item "wallpaper.arrow_r" "popup.$PARENT"
    --set "wallpaper.arrow_r"
    icon.drawing=off
    background.drawing=on background.color=0xe62c2c2e
    background.corner_radius=16
    label="›"
    label.font="SF Pro:Bold:24.0" label.color=0xffffffff
    label.padding_left=12 label.padding_right=12
    click_script="$SCRIPT rotate 1"
    script="$SCRIPT"
    --subscribe "wallpaper.arrow_r" mouse.entered mouse.exited)
  sketchybar "${add_args[@]}"

  [ -f "$STATE_DIR/idx" ] || printf '1' >"$STATE_DIR/idx"
  render || return 1
  touch "$STATE_DIR/open"
  # Slide down from the notch: park the popup fully retracted behind
  # the bar, then animate it down into place as it appears.
  sketchybar --set "$PARENT" popup.y_offset=$POPUP_Y_HIDDEN 2>/dev/null
  sketchybar --animate tanh 6 --set "$PARENT" popup.drawing=on popup.y_offset=$POPUP_Y_OPEN
  # Warm the remaining thumbnails in the background so rotating to a
  # not-yet-seen card never stalls on generation.
  ( warmup ) &|
}

# Grace period after the pointer leaves before the popup closes: without
# it a slow move from the notch down to the cards kills the popup mid-transit.
# Any mouse.entered bumps the generation and cancels a pending close.
HIDE_DELAY=0.6

hide_popup() {
  local mygen=$(cat "$STATE_DIR/gen" 2>/dev/null || echo 0)
  (
    sleep "$HIDE_DELAY"
    [ "$(cat "$STATE_DIR/gen" 2>/dev/null || echo 0)" = "$mygen" ] || exit 0
    slide_popup_up
    # A re-hover during the slide-up must cancel the close.
    [ "$(cat "$STATE_DIR/gen" 2>/dev/null || echo 0)" = "$mygen" ] &&
      close_popup_items
  ) &|
}

rotate() { # $1 = -1 or 1
  acquire_lock || return 0
  trap 'release_lock' EXIT
  local -a files
  files=("${(@f)$(wallpapers)}")
  local n=${#files[@]}
  if ((n > 0)); then
    local center=$(cat "$STATE_DIR/idx" 2>/dev/null || echo 1)
    center=$(((center - 1 + $1) % n + 1))
    ((center < 1)) && center=$((center + n))
    printf '%s' "$center" >"$STATE_DIR/idx"
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
  if ((n > 0)); then
    local center=$(cat "$STATE_DIR/idx" 2>/dev/null || echo 1)
    center=$(((center - 1) % n + 1))
    ((center < 1)) && center=$((center + n))
    local t=$(((center - 1 + $1) % n + 1))
    ((t < 1)) && t=$((t + n))
    printf '%s' "$t" >"$STATE_DIR/idx"
    bump_gen
    "$APPLY_THEME" "${files[$t]}" >/tmp/sketchybar-wallpaper.log 2>&1 &
    slide_popup_up
    close_popup_items
  fi
  release_lock
}

# Sketchybar fires event scripts with $SENDER set and no positional args;
# click_script lines invoke "$SCRIPT <cmd> ..." with positional args instead.
case "${1:-}" in
warmup) warmup ;;
rotate) rotate "$2" ;;
slotclick) slotclick "$2" ;;
*)
  case "${SENDER:-}" in
  mouse.entered)
    case "${NAME:-}" in
    wallpaper.slot_* | wallpaper.arrow_*) bump_gen ;;
    *) show_popup ;;
    esac
    ;;
  mouse.exited) hide_popup ;;
  esac
  ;;
esac
