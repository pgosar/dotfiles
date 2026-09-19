#!/usr/bin/env bash
set -euo pipefail

PROGRAM="${0##*/}"
ALBUM_NAME="${FUJI_IMPORT_ALBUM:-Camera Import}"
STATE_ROOT="${FUJI_IMPORT_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/fuji-import}"
BATCH_SIZE="${FUJI_IMPORT_BATCH_SIZE:-100}"
SOURCE="${FUJI_IMPORT_SOURCE:-}"
DRY_RUN=0
IMPORT_ALL=0
ASSUME_YES=0
RUN_MARKER=""

usage() {
  cat <<EOF
Usage: $PROGRAM [options] [SD_CARD_OR_DCIM_PATH]

Upload new Fujifilm SD-card media to the Immich album "$ALBUM_NAME".

Options:
  -n, --dry-run  Ask Immich what would be uploaded without changing anything
  -a, --all      Scan the whole card instead of using the last successful run
  -y, --yes      Start without the confirmation prompt
  -h, --help     Show this help

The source is auto-detected under /Volumes, /run/media, /media, or /mnt when
exactly one DCIM folder is present. Run this once per computer before importing:

  immich login http://192.168.1.196:2283/api YOUR_API_KEY

The API key is stored by the Immich CLI, not in this script or repository.
EOF
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

cleanup() {
  if [[ -n "$RUN_MARKER" && -f "$RUN_MARKER" ]]; then
    rm -f -- "$RUN_MARKER"
  fi
}
trap cleanup EXIT

is_media_file() {
  case "$1" in
    *.[Jj][Pp][Gg]|*.[Jj][Pp][Ee][Gg]|*.[Rr][Aa][Ff]|*.[Hh][Ee][Ii][Cc]|*.[Hh][Ee][Ii][Ff]|*.[Hh][Ii][Ff]|*.[Mm][Oo][Vv]|*.[Mm][Pp]4|*.[Aa][Vv][Ii]|*.[Mm][Tt][Ss]|*.[Mm]2[Tt][Ss]|*.[Tt][Ii][Ff]|*.[Tt][Ii][Ff][Ff]|*.[Pp][Nn][Gg])
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

normalize_source() {
  local requested="$1"

  [[ -d "$requested" ]] || die "source directory does not exist: $requested"
  if [[ -d "$requested/DCIM" ]]; then
    requested="$requested/DCIM"
  fi
  [[ "${requested##*/}" == "DCIM" ]] || die "source must be an SD-card root or DCIM directory: $requested"

  (cd "$requested" && pwd -P)
}

detect_source() {
  local path
  local -a found=()

  for path in /Volumes/*/DCIM /run/media/"${USER:-}"/*/DCIM /media/"${USER:-}"/*/DCIM /mnt/*/DCIM; do
    [[ -d "$path" ]] || continue
    found+=("$path")
  done

  if (( ${#found[@]} == 0 )); then
    die "no SD-card DCIM folder found; pass its path explicitly"
  fi
  if (( ${#found[@]} > 1 )); then
    printf 'Multiple DCIM folders found:\n' >&2
    printf '  %s\n' "${found[@]}" >&2
    die "pass the Fujifilm card path explicitly"
  fi

  normalize_source "${found[0]}"
}

card_name_for_source() {
  local parent name
  parent="$(dirname "$1")"
  name="${parent##*/}"
  printf '%s' "$name" | tr -c 'A-Za-z0-9._-' '_'
}

verify_raf_file_magic() {
  local path="$1"
  local mime

  command -v file >/dev/null 2>&1 || return 0
  case "$path" in
    *.[Rr][Aa][Ff]) ;;
    *) return 0 ;;
  esac

  mime="$(file -b --mime-type -- "$path" 2>/dev/null || true)"
  if [[ "$mime" == "image/jpeg" ]]; then
    printf 'error: JPEG data has a RAF extension: %s\n' "$path" >&2
    return 1
  fi
}

upload_batch() {
  local -a args=(upload --album-name "$ALBUM_NAME")
  local path

  if (( DRY_RUN )); then
    args+=(--dry-run)
  fi
  for path in "$@"; do
    args+=("$path")
  done
  immich "${args[@]}"
}

while (( $# > 0 )); do
  case "$1" in
    -n|--dry-run) DRY_RUN=1 ;;
    -a|--all) IMPORT_ALL=1 ;;
    -y|--yes) ASSUME_YES=1 ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      if (( $# > 1 )); then
        die "only one source path may be provided"
      fi
      SOURCE="${1:-}"
      break
      ;;
    -*) die "unknown option: $1" ;;
    *)
      [[ -z "$SOURCE" ]] || die "only one source path may be provided"
      SOURCE="$1"
      ;;
  esac
  shift
done

command -v immich >/dev/null 2>&1 || die "Immich CLI is missing; rerun the dotfiles installer"
[[ "$BATCH_SIZE" =~ ^[1-9][0-9]*$ ]] || die "FUJI_IMPORT_BATCH_SIZE must be a positive integer"

if [[ -n "$SOURCE" ]]; then
  SOURCE="$(normalize_source "$SOURCE")"
else
  SOURCE="$(detect_source)"
fi

if ! immich server-info >/dev/null 2>&1; then
  die "Immich login is missing or the server is unreachable; see '$PROGRAM --help'"
fi

mkdir -p "$STATE_ROOT"
CARD_NAME="$(card_name_for_source "$SOURCE")"
STATE_FILE="$STATE_ROOT/$CARD_NAME.last-success"
RUN_MARKER="$(mktemp "${TMPDIR:-/tmp}/fuji-import.XXXXXX")"
touch "$RUN_MARKER"

declare -a FILES=()
BAD_RAF=0
while IFS= read -r -d '' path; do
  is_media_file "$path" || continue
  if ! verify_raf_file_magic "$path"; then
    BAD_RAF=1
    continue
  fi
  FILES+=("$path")
done < <(
  if (( IMPORT_ALL )) || [[ ! -f "$STATE_FILE" ]]; then
    find "$SOURCE" -type f ! -newer "$RUN_MARKER" -print0
  else
    find "$SOURCE" -type f -newer "$STATE_FILE" ! -newer "$RUN_MARKER" -print0
  fi
)

(( BAD_RAF == 0 )) || die "fix the mislabeled RAF file(s) on a separate copy, then retry; the checkpoint was not changed"

if (( ${#FILES[@]} == 0 )); then
  printf 'No new supported media found in %s.\n' "$SOURCE"
  if (( ! DRY_RUN )); then
    STATE_TMP="$STATE_FILE.tmp.$$"
    cp -p -- "$RUN_MARKER" "$STATE_TMP"
    mv -f -- "$STATE_TMP" "$STATE_FILE"
  fi
  exit 0
fi

printf 'Source: %s\nAlbum:  %s\nFiles:  %d\n' "$SOURCE" "$ALBUM_NAME" "${#FILES[@]}"
if [[ -f "$STATE_FILE" ]] && (( ! IMPORT_ALL )); then
  printf 'Since:  %s\n' "$(date -r "$STATE_FILE" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || printf 'last successful run')"
else
  printf 'Since:  beginning of card\n'
fi

if (( ! ASSUME_YES && ! DRY_RUN )); then
  printf 'Import now? [Y/n] '
  read -r answer
  case "$answer" in
    ''|[Yy]|[Yy][Ee][Ss]) ;;
    *)
      printf 'Cancelled; the checkpoint was not changed.\n'
      exit 0
      ;;
  esac
fi

offset=0
while (( offset < ${#FILES[@]} )); do
  batch=("${FILES[@]:offset:BATCH_SIZE}")
  upload_batch "${batch[@]}"
  offset=$((offset + ${#batch[@]}))
done

if (( DRY_RUN )); then
  printf 'Dry run complete; the checkpoint was not changed.\n'
else
  STATE_TMP="$STATE_FILE.tmp.$$"
  cp -p -- "$RUN_MARKER" "$STATE_TMP"
  mv -f -- "$STATE_TMP" "$STATE_FILE"
  printf 'Import complete. The checkpoint advanced for card %s.\n' "$CARD_NAME"
fi
