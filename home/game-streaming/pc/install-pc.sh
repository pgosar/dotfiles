#!/usr/bin/env bash
# Install the game-streaming setup on the gaming PC (Arch/CachyOS, KDE).
# Idempotent: safe to re-run. System files are installed with sudo, and
# the first pre-install copy of /etc/default/grub is kept as
# /etc/default/grub.bak-phantom.
set -euo pipefail

if [ "$(uname)" != "Linux" ]; then
  echo "install-pc.sh is for the Linux gaming PC only" >&2
  exit 1
fi
for cmd in mkinitcpio grub-mkconfig python3; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "missing required command: $cmd (this installer targets Arch/CachyOS)" >&2
    exit 1
  fi
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GRUB_FILE="${GRUB_FILE:-/etc/default/grub}"
KERNEL_PARAMS="video=DP-3:e drm.edid_firmware=DP-3:edid/phantom.bin"

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
for script in stream-mode.sh desk-mode.sh phantom-watcher.sh sunshine-pick-primary.sh sunshine-display-keeper.sh; do
  install_file "$SCRIPT_DIR/$script" "$HOME/.local/bin/$script"
  chmod +x "$HOME/.local/bin/$script"
done

echo "== sunshine config =="
install_file "$SCRIPT_DIR/sunshine.conf" "$HOME/.config/sunshine/sunshine.conf"

echo "== phantom EDID firmware + mkinitcpio drop-in (sudo) =="
sudo install -Dm644 "$SCRIPT_DIR/phantom.bin" /usr/lib/firmware/edid/phantom.bin
sudo install -Dm644 "$SCRIPT_DIR/20-phantom-edid.conf" /etc/mkinitcpio.conf.d/20-phantom-edid.conf

echo "== kernel parameters in $GRUB_FILE =="
if grep -q "video=DP-3:e" "$GRUB_FILE"; then
  echo "kernel parameters already present, skipping"
else
  if [ ! -e "$GRUB_FILE.bak-phantom" ]; then
    sudo cp "$GRUB_FILE" "$GRUB_FILE.bak-phantom"
    echo "backed up $GRUB_FILE to $GRUB_FILE.bak-phantom"
  fi
  # Append the params inside the quotes of GRUB_CMDLINE_LINUX_DEFAULT.
  sudo GRUB_FILE="$GRUB_FILE" python3 - <<'PYEOF'
import os

path = os.environ["GRUB_FILE"]
lines = open(path).read().splitlines()
for i, line in enumerate(lines):
    if line.startswith("GRUB_CMDLINE_LINUX_DEFAULT="):
        value = line.split("=", 1)[1]
        if value[:1] in "\"'" and value.endswith(value[:1]):
            lines[i] = line[:-1] + " video=DP-3:e drm.edid_firmware=DP-3:edid/phantom.bin" + value[:1]
        else:
            lines[i] = line + " video=DP-3:e drm.edid_firmware=DP-3:edid/phantom.bin"
        break
open(path, "w").write("\n".join(lines) + "\n")
PYEOF
  echo "added: $KERNEL_PARAMS"
fi

echo "== regenerate initramfs + grub config (sudo) =="
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "== sunshine =="
if ! command -v sunshine >/dev/null 2>&1 && command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm sunshine
fi
# Sunshine needs the input group for keyboard/mouse injection.
if ! id -nG "$USER" | tr ' ' '\n' | grep -qx input; then
  sudo usermod -aG input "$USER"
  echo "added $USER to the input group (takes effect at next login)"
fi

echo ""
echo "Done. Reboot the PC so the phantom display (DP-3) comes up."
echo "Sunshine runs as the user service app-dev.lizardbyte.app.Sunshine.service"
echo "and must be enabled in the desktop session for streaming to work."
