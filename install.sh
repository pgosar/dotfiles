#!/usr/bin/env bash

OS="$(uname)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=home/scripts/paths.sh
source "$SCRIPT_DIR/home/scripts/paths.sh"

if [ -z "${LANG:-}" ] || [ "${LANG:-}" = "POSIX" ]; then
  export LANG=C.utf8
fi

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

  if ! infocmp xterm-kitty >/dev/null 2>&1; then
    packages+=(kitty-terminfo)
  fi

  if ! command_exists fnm; then
    packages+=(fnm)
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
  if [ -L "$dest" ]; then
    # Symlink: replace it, no user data at risk.
    rm -f "$dest"
  elif [ -e "$dest" ]; then
    # Real file/dir: back it up instead of deleting.
    local bak
    if [ -d "$dest" ]; then
      bak="${dest}_bak"
    else
      bak="${dest}.bak"
    fi
    if [ -e "$bak" ]; then
      warn "Skipping $dest: backup $bak already exists"
      return 0
    fi
    mv "$dest" "$bak"
    echo "Backed up $dest to $bak"
  fi
  ln -s "$src" "$dest"
}

# For Spicetify: use a regular file (not symlink) so theme generator
# writes to the live config without touching the tracked template.
# Preserves existing symlink contents and regular files on reruns.
copy_file() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    # Symlink: preserve its current contents before replacing.
    local tmp
    tmp="$(mktemp)"
    cat "$dest" > "$tmp"
    rm -f "$dest"
    cp "$tmp" "$dest"
    rm -f "$tmp"
    echo "Replaced symlink $dest with regular file (contents preserved)"
  elif [ -e "$dest" ]; then
    # Regular file exists: preserve it on reruns.
    echo "Preserving existing $dest"
    return 0
  else
    cp "$src" "$dest"
    echo "Copied $src to $dest"
  fi
}

# Generate runtime theme files from seeds if they don't exist yet.
# The theme generator (apply_theme.py) will overwrite these on next run.
ensure_generated_theme_files() {
  local kitty_gen="$CONFIG_HOME/kitty/colors-generated.conf"
  local kitty_seed="$DOTFILES_CONFIG_DIR/kitty/colors.conf"
  if [ ! -f "$kitty_gen" ] && [ -f "$kitty_seed" ]; then
    cp "$kitty_seed" "$kitty_gen"
    echo "Generated $kitty_gen from seed"
  fi

  local dunst_out="$CONFIG_HOME/dunst/dunstrc"
  local dunst_template="$DOTFILES_CONFIG_DIR/dunst/dunstrc.template"
  if [ ! -f "$dunst_out" ] && [ -f "$dunst_template" ]; then
    cp "$dunst_template" "$dunst_out"
    echo "Generated $dunst_out from template"
  fi
  # Neovim: seed theme_colors.lua handles fallback via pcall(require).
}

link_entries() {
  local entry src dest

  for entry in "$@"; do
    IFS="|" read -r src dest <<<"$entry"
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
    "difftastic|difft"
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
    IFS="|" read -r crate command <<<"$entry"
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

install_npm_tools() {
  if ! command_exists npm; then
    warn "npm is not installed; skipping the Immich CLI"
    return 0
  fi

  if ! command_exists immich; then
    echo "Installing npm application: @immich/cli"
    npm install --global --prefix "$HOME/.local" @immich/cli
  fi
}

configure_kde() {
  if [ "$OS" != "Linux" ] || ! command_exists kpackagetool6 || ! command_exists kwriteconfig6; then
    return 0
  fi

  # shellcheck source=home/config/kde/settings.sh
  source "$DOTFILES_CONFIG_DIR/kde/settings.sh"

  local metadata_path installed_version temp_dir package_path actual_commit
  metadata_path="${XDG_DATA_HOME:-$HOME/.local/share}/kwin/scripts/$KDE_KWIN_SCRIPT_ID/metadata.json"
  installed_version=""
  if [ -f "$metadata_path" ]; then
    installed_version=$(sed -n 's/.*"Version": "\([^"]*\)".*/\1/p' "$metadata_path")
  fi

  if [ "$installed_version" != "$KDE_KWIN_SCRIPT_VERSION" ]; then
    if ! command_exists git || ! command_exists zip; then
      warn "git and zip are required to install the KDE window-position script"
      return 0
    fi

    echo "Installing KDE window-position script v$KDE_KWIN_SCRIPT_VERSION..."
    temp_dir=$(mktemp -d)
    if ! git clone --depth 1 --branch "v$KDE_KWIN_SCRIPT_VERSION" \
      "$KDE_KWIN_SCRIPT_REPOSITORY" "$temp_dir/repo"; then
      warn "failed to download the KDE window-position script"
      /bin/rm -rf "$temp_dir"
      return 0
    fi

    actual_commit=$(git -C "$temp_dir/repo" rev-parse HEAD)
    if [ "$actual_commit" != "$KDE_KWIN_SCRIPT_COMMIT" ]; then
      warn "KDE window-position script revision did not match the pinned commit"
      /bin/rm -rf "$temp_dir"
      return 0
    fi

    package_path="$temp_dir/$KDE_KWIN_SCRIPT_ID.kwinscript"
    (cd "$temp_dir/repo" && zip -rq "$package_path" src)
    if [ -f "$metadata_path" ]; then
      kpackagetool6 --type=KWin/Script --upgrade "$package_path"
    else
      kpackagetool6 --type=KWin/Script --install "$package_path"
    fi
    /bin/rm -rf "$temp_dir"
  fi

  local setting file group key value
  for setting in "${KDE_CONFIG_SETTINGS[@]}"; do
    IFS="|" read -r file group key value <<<"$setting"
    kwriteconfig6 --file "$file" --group "$group" --key "$key" "$value"
  done

  if command_exists qdbus6; then
    qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure >/dev/null 2>&1 || true
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
  "$DOTFILES_CONFIG_DIR/spicetify/Themes/Comfy/color.ini|$CONFIG_HOME/spicetify/Themes/Comfy/color.ini"
  "$DOTFILES_CONFIG_DIR/spicetify/Themes/Comfy/user.css|$CONFIG_HOME/spicetify/Themes/Comfy/user.css"
  "$DOTFILES_CONFIG_DIR/shell/eza-colors.sh|$CONFIG_HOME/shell/eza-colors.sh"
  "$DOTFILES_SCRIPTS_DIR|$CONFIG_HOME/dotfiles-scripts"
)

LINUX_LINKS=(
  "$DOTFILES_CONFIG_DIR/dunst|$CONFIG_HOME/dunst"
  "$DOTFILES_CONFIG_DIR/hypr|$CONFIG_HOME/hypr"
  "$DOTFILES_CONFIG_DIR/wofi|$CONFIG_HOME/wofi"
  "$DOTFILES_CONFIG_DIR/wireplumber|$CONFIG_HOME/wireplumber"
  "$DOTFILES_CONFIG_DIR/quickshell|$CONFIG_HOME/quickshell"
  "$DOTFILES_CONFIG_DIR/fontconfig|$CONFIG_HOME/fontconfig"
  "$DOTFILES_CONFIG_DIR/systemd|$CONFIG_HOME/systemd"
)

DARWIN_LINKS=(
  "$DOTFILES_CONFIG_DIR/sketchybar|$CONFIG_HOME/sketchybar"
  "$DOTFILES_CONFIG_DIR/skhd|$CONFIG_HOME/skhd"
  "$DOTFILES_CONFIG_DIR/yabai|$CONFIG_HOME/yabai"
)

# ---- Dotfiles-Dependent User Tools ----------------------------------------

ensure_linux_packages
install_oh_my_zsh
install_cargo_tools
install_pipx_tools
install_npm_tools

# ---- Shared Symlinks -------------------------------------------------------

link_entries "${SHARED_LINKS[@]}"

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
  FIREFOX_PROFILE_PATH=$(grep "Path=" "$FIREFOX_BASE/profiles.ini" 2>/dev/null | grep "default-release" | cut -d "=" -f 2 | head -n 1)
  if [ -n "$FIREFOX_PROFILE_PATH" ]; then
    FIREFOX_PROFILE="$FIREFOX_BASE/$FIREFOX_PROFILE_PATH"
  else
    FIREFOX_PROFILE=$(find "$FIREFOX_BASE" -maxdepth 1 -type d -name "*.default-release" -print -quit 2>/dev/null)
  fi

  if [ -n "$FIREFOX_PROFILE" ]; then
    if [ ! -f "$FIREFOX_PROFILE/user.js" ] || [ ! -d "$FIREFOX_PROFILE/chrome" ]; then
      echo "Installing Textfox theme to Firefox profile..."
      TEXTFOX_CLONE="$(mktemp -d)"
      if git clone https://github.com/adriankarlen/textfox "$TEXTFOX_CLONE"; then
        mkdir -p "$FIREFOX_PROFILE/chrome"
        cp -r "$TEXTFOX_CLONE/chrome/"* "$FIREFOX_PROFILE/chrome/"
        cp -r "$TEXTFOX_CLONE/user.js" "$FIREFOX_PROFILE/user.js"
      else
        echo "Warning: Textfox clone failed; skipping theme install" >&2
      fi
      /bin/rm -rf "$TEXTFOX_CLONE"
    fi
  fi
fi

# ---- OS-Specific Symlinks --------------------------------------------------

if [ "$OS" = "Linux" ]; then
  link_entries "${LINUX_LINKS[@]}"
  # Spicetify: regular file, not symlink (theme generator writes live config)
  copy_file "$DOTFILES_CONFIG_DIR/spicetify/config-xpui-linux.ini" "$CONFIG_HOME/spicetify/config-xpui.ini"

  configure_kde

  # Initialize Firefox and Spicetify dynamic themes.
  python3 "$APPLY_THEME_SCRIPT"
elif [ "$OS" = "Darwin" ]; then
  link_entries "${DARWIN_LINKS[@]}"
  # Spicetify: regular file, not symlink (theme generator writes live config)
  copy_file "$DOTFILES_CONFIG_DIR/spicetify/config-xpui-macos.ini" "$CONFIG_HOME/spicetify/config-xpui.ini"

  # Generate macOS theme colors (sketchybar/yabai) from the seed theme-macos.json
  python3 "$APPLY_THEME_SCRIPT"
fi

# Ensure generated runtime files exist (seed fallback for fresh installs)
ensure_generated_theme_files
