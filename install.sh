#!/usr/bin/env bash

OS="$(uname)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=home/scripts/paths.sh
source "$SCRIPT_DIR/home/scripts/paths.sh"

CONFIG_HOME="$HOME/.config"

warn() {
  printf 'warning: %s\n' "$*" >&2
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ensure_cargo() {
  if command_exists cargo; then
    return 0
  fi

  if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.cargo/env"
  fi

  if command_exists cargo; then
    return 0
  fi

  if ! command_exists curl; then
    warn "curl is not installed; cannot bootstrap rustup"
    return 1
  fi

  echo "Installing rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

  if [ -f "$HOME/.cargo/env" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.cargo/env"
  fi

  if ! command_exists cargo; then
    warn "cargo is still not available after rustup install"
    return 1
  fi
}

ensure_pipx() {
  if command_exists pipx; then
    return 0
  fi

  if [ "$OS" = "Linux" ] && command_exists pacman; then
    echo "Installing python-pipx..."
    sudo pacman -S --needed --noconfirm python-pipx
  else
    warn "pipx is not installed; skipping dotfiles pipx tools"
    return 1
  fi

  if ! command_exists pipx; then
    warn "pipx is still not available after package install"
    return 1
  fi
}

ensure_linux_packages() {
  if [ "$OS" != "Linux" ] || ! command_exists pacman; then
    return 0
  fi

  local packages=()

  if ! command_exists fzf; then
    packages+=(fzf)
  fi

  if ! command_exists node; then
    packages+=(nodejs)
  fi

  if ! command_exists npm; then
    packages+=(npm)
  fi

  if [ "${#packages[@]}" -eq 0 ]; then
    return 0
  fi

  echo "Installing Linux packages: ${packages[*]}"
  sudo pacman -S --needed --noconfirm "${packages[@]}"
}

link_path() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  ln -s "$src" "$dest"
}

link_entries() {
  local entry src dest

  for entry in "$@"; do
    IFS="|" read -r src dest <<< "$entry"
    link_path "$src" "$dest"
  done
}

install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    if command_exists curl; then
      echo "Installing Oh My Zsh..."
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
      warn "curl is not installed; skipping Oh My Zsh install"
      return 0
    fi
  fi

  local zsh_custom
  zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  mkdir -p "$zsh_custom/plugins"

  if [ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"
  fi

  if [ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$zsh_custom/plugins/zsh-syntax-highlighting"
  fi
}

install_cargo_tools() {
  if ! ensure_cargo; then
    return 0
  fi

  local entry crate command
  local cargo_tools=(
    "bat|bat"
    "cargo-cache|cargo-cache"
    "cargo-update|cargo-install-update"
    "eza|eza"
    "kondo|kondo"
    "procs|procs"
    "rm-improved|rip"
    "vivid|vivid"
    "starship|starship"
    "tokei|tokei"
    "topgrade|topgrade"
    "zoxide|zoxide"
  )

  for entry in "${cargo_tools[@]}"; do
    IFS="|" read -r crate command <<< "$entry"
    if command_exists "$command"; then
      continue
    fi
    echo "Installing cargo tool: $crate"
    cargo install --locked "$crate"
  done
}

install_pipx_tools() {
  if ! ensure_pipx; then
    return 0
  fi

  if ! command_exists register-python-argcomplete; then
    echo "Installing pipx application: argcomplete"
    pipx install --include-deps argcomplete
  fi

  if ! command_exists bpython; then
    echo "Installing pipx application: bpython"
    pipx install --include-deps bpython
  fi
}

SHARED_LINKS=(
  "$DOTFILES_CONFIG_DIR/nvim|$CONFIG_HOME/nvim"
  "$DOTFILES_CONFIG_DIR/kitty|$CONFIG_HOME/kitty"
  "$DOTFILES_HOME_DIR/zshrc|$HOME/.zshrc"
  "$DOTFILES_HOME_DIR/zprofile|$HOME/.zprofile"
  "$DOTFILES_HOME_DIR/gitconfig|$HOME/.gitconfig"
  "$DOTFILES_CONFIG_DIR/starship.toml|$CONFIG_HOME/starship.toml"
  "$DOTFILES_CONFIG_DIR/topgrade.toml|$CONFIG_HOME/topgrade.toml"
  "$DOTFILES_HOME_DIR/tmux.conf|$HOME/.tmux.conf"
  "$DOTFILES_HOME_DIR/codex/config.toml|$HOME/.codex/config.toml"
  "$DOTFILES_CONFIG_DIR/spicetify/config-xpui.ini|$CONFIG_HOME/spicetify/config-xpui.ini"
  "$DOTFILES_CONFIG_DIR/spicetify/Themes/Comfy/color.ini|$CONFIG_HOME/spicetify/Themes/Comfy/color.ini"
)

LINUX_LINKS=(
  "$DOTFILES_CONFIG_DIR/dunst|$CONFIG_HOME/dunst"
  "$DOTFILES_CONFIG_DIR/hypr|$CONFIG_HOME/hypr"
  "$DOTFILES_CONFIG_DIR/wofi|$CONFIG_HOME/wofi"
  "$DOTFILES_CONFIG_DIR/wireplumber|$CONFIG_HOME/wireplumber"
  "$DOTFILES_CONFIG_DIR/electron28-flags.conf|$CONFIG_HOME/electron28-flags.conf"
  "$DOTFILES_CONFIG_DIR/quickshell|$CONFIG_HOME/quickshell"
  "$DOTFILES_CONFIG_DIR/fontconfig|$CONFIG_HOME/fontconfig"
  "$DOTFILES_CONFIG_DIR/systemd|$CONFIG_HOME/systemd"
  "$DOTFILES_SCRIPTS_DIR|$CONFIG_HOME/dotfiles-scripts"
)

DARWIN_LINKS=(
  "$DOTFILES_CONFIG_DIR/sketchybar|$CONFIG_HOME/sketchybar"
  "$DOTFILES_CONFIG_DIR/skhd|$CONFIG_HOME/skhd"
  "$DOTFILES_CONFIG_DIR/svim|$CONFIG_HOME/svim"
  "$DOTFILES_CONFIG_DIR/yabai|$CONFIG_HOME/yabai"
  "$DOTFILES_CONFIG_DIR/borders|$CONFIG_HOME/borders"
)

# ---- Dotfiles-Dependent User Tools ----------------------------------------

ensure_linux_packages
install_oh_my_zsh
install_cargo_tools
install_pipx_tools

# ---- Shared Symlinks -------------------------------------------------------

link_entries "${SHARED_LINKS[@]}"
chmod 600 "$DOTFILES_HOME_DIR/codex/config.toml"

# ---- Firefox Shared Setup --------------------------------------------------

if [ "$OS" = "Linux" ]; then
  if [ -d "$CONFIG_HOME/mozilla/firefox" ]; then
    FIREFOX_BASE="$CONFIG_HOME/mozilla/firefox"
  else
    FIREFOX_BASE="$HOME/.mozilla/firefox"
  fi
elif [ "$OS" = "Darwin" ]; then
  FIREFOX_BASE="$HOME/Library/Application Support/Firefox"
fi

if [ -n "$FIREFOX_BASE" ]; then
  # Read active profile from profiles.ini, otherwise grab the first default-release.
  FIREFOX_PROFILE_PATH=$(grep "Path=" "$FIREFOX_BASE/profiles.ini" 2> /dev/null | grep "default-release" | cut -d "=" -f 2 | head -n 1)
  if [ -n "$FIREFOX_PROFILE_PATH" ]; then
    FIREFOX_PROFILE="$FIREFOX_BASE/$FIREFOX_PROFILE_PATH"
  else
    FIREFOX_PROFILE=$(find "$FIREFOX_BASE" -maxdepth 1 -type d -name "*.default-release" -print -quit 2> /dev/null)
  fi

  if [ -n "$FIREFOX_PROFILE" ]; then
    if [ ! -f "$FIREFOX_PROFILE/user.js" ] || [ ! -d "$FIREFOX_PROFILE/chrome" ]; then
      echo "Installing Textfox theme to Firefox profile..."
      TEXTFOX_CLONE="$(mktemp -d)"
      git clone https://github.com/adriankarlen/textfox "$TEXTFOX_CLONE" || true
      mkdir -p "$FIREFOX_PROFILE/chrome"
      cp -r "$TEXTFOX_CLONE/chrome/"* "$FIREFOX_PROFILE/chrome/"
      cp -r "$TEXTFOX_CLONE/user.js" "$FIREFOX_PROFILE/user.js"
      /bin/rm -rf "$TEXTFOX_CLONE"
    fi
  fi
fi

# ---- OS-Specific Symlinks --------------------------------------------------

if [ "$OS" = "Linux" ]; then
  link_entries "${LINUX_LINKS[@]}"

  # Initialize Firefox and Spicetify dynamic themes.
  python3 "$APPLY_THEME_SCRIPT"
elif [ "$OS" = "Darwin" ]; then
  link_entries "${DARWIN_LINKS[@]}"
fi
