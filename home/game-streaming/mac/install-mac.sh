#!/usr/bin/env bash
# Install the game-streaming launchers on the MacBook.
# Idempotent: safe to re-run. Builds the two applet apps in a temp dir
# and only swaps them in after a successful build.
set -euo pipefail

if [ "$(uname)" != "Darwin" ]; then
  echo "install-mac.sh is for the MacBook only" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy $1 to $2. If $2 already exists with different content, keep the
# first replaced version as $2.bak-phantom before overwriting.
install_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && ! cmp -s "$src" "$dest"; then
    if [ ! -e "$dest.bak-phantom" ]; then
      cp "$dest" "$dest.bak-phantom"
      echo "backed up $dest to $dest.bak-phantom"
    fi
  fi
  cp "$src" "$dest"
}

echo "== user scripts -> ~/.local/bin =="
for script in moonlight-wake.sh pc-desk-mode.sh; do
  install_file "$SCRIPT_DIR/$script" "$HOME/.local/bin/$script"
  chmod +x "$HOME/.local/bin/$script"
done

# Rebuild one applet app from its shell script, exactly like the
# original manual build, and reuse Moonlight's icon when available.
build_app() {
  local name="$1" script="$2"
  local tmpdir built
  tmpdir="$(mktemp -d)"
  built="$tmpdir/$name.app"
  osacompile -e "do shell script \"/bin/bash $HOME/.local/bin/$script >/dev/null 2>&1 &\"" -o "$built"

  local icns=""
  if [ -d /Applications/Moonlight.app ]; then
    icns="$(ls /Applications/Moonlight.app/Contents/Resources/*.icns 2>/dev/null | head -n 1 || true)"
  fi
  if [ -n "$icns" ]; then
    cp "$icns" "$built/Contents/Resources/applet.icns"
  fi

  mkdir -p "$HOME/Applications"
  rm -rf "$HOME/Applications/$name.app"
  mv "$built" "$HOME/Applications/$name.app"
  rm -rf "$tmpdir"
  echo "built $HOME/Applications/$name.app"
}

echo "== launcher apps -> ~/Applications =="
build_app "Moonlight Wake" moonlight-wake.sh
build_app "PC Desk Mode" pc-desk-mode.sh

echo ""
echo "Done. Notes:"
echo "- The launchers ssh to the NAS with ~/.ssh/id_ed25519_nas; that key must exist."
echo "- Moonlight itself comes from: brew install --cask moonlight"
