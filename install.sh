#!/usr/bin/env bash

OS="$(uname)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=home/scripts/paths.sh
source "$SCRIPT_DIR/home/scripts/paths.sh"

CONFIG_HOME="$HOME/.config"

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

SHARED_LINKS=(
  "$DOTFILES_CONFIG_DIR/nvim|$CONFIG_HOME/nvim"
  "$DOTFILES_CONFIG_DIR/kitty|$CONFIG_HOME/kitty"
  "$DOTFILES_HOME_DIR/zshrc|$HOME/.zshrc"
  "$DOTFILES_HOME_DIR/zprofile|$HOME/.zprofile"
  "$DOTFILES_HOME_DIR/gitconfig|$HOME/.gitconfig"
  "$DOTFILES_CONFIG_DIR/starship.toml|$CONFIG_HOME/starship.toml"
  "$DOTFILES_CONFIG_DIR/topgrade.toml|$CONFIG_HOME/topgrade.toml"
  "$DOTFILES_HOME_DIR/tmux.conf|$HOME/.tmux.conf"
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
  FIREFOX_PROFILE_PATH=$(grep "Path=" "$FIREFOX_BASE/profiles.ini" 2> /dev/null | grep "default-release" | cut -d "=" -f 2 | head -n 1)
  if [ -n "$FIREFOX_PROFILE_PATH" ]; then
    FIREFOX_PROFILE="$FIREFOX_BASE/$FIREFOX_PROFILE_PATH"
  else
    FIREFOX_PROFILE=$(ls -d "$FIREFOX_BASE"/*.default-release 2> /dev/null | head -n 1)
  fi

  if [ -n "$FIREFOX_PROFILE" ]; then
    if [ ! -f "$FIREFOX_PROFILE/user.js" ] || [ ! -d "$FIREFOX_PROFILE/chrome" ]; then
      echo "Installing Textfox theme to Firefox profile..."
      /bin/rm -rf /tmp/textfox_clone
      git clone https://github.com/adriankarlen/textfox /tmp/textfox_clone || true
      mkdir -p "$FIREFOX_PROFILE/chrome"
      cp -r /tmp/textfox_clone/chrome/* "$FIREFOX_PROFILE/chrome/"
      cp -r /tmp/textfox_clone/user.js "$FIREFOX_PROFILE/user.js"
      /bin/rm -rf /tmp/textfox_clone
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
