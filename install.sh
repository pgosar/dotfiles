#!/bin/bash

OS="$(uname)"

# ---- Shared Cleanup --------------------------------------------------------

rm -f ~/.zshrc
rm -f ~/.zprofile
rm -f ~/.gitconfig
rm -f ~/.tmux.conf
rm -rf ~/.config/kitty
rm -rf ~/.config/nvim
rm -f ~/.config/spicetify/config-xpui.ini
rm -f ~/.config/spicetify/Themes/Comfy/color.ini
rm -f ~/.config/starship.toml
rm -f ~/.config/topgrade.toml

# ---- OS-Specific Cleanup ---------------------------------------------------

if [ "$OS" = "Linux" ]; then
  rm -rf ~/.config/dunst
  rm -rf ~/.config/hypr
  rm -rf ~/.config/wofi
  rm -rf ~/.config/wireplumber
  rm -rf ~/.config/fontconfig
  rm -rf ~/.config/quickshell
  rm -f ~/.config/electron28-flags.conf
  rm -rf ~/.config/systemd
elif [ "$OS" = "Darwin" ]; then
  rm -rf ~/.config/sketchybar
  rm -rf ~/.config/skhd
  rm -rf ~/.config/svim
  rm -rf ~/.config/yabai
  rm -rf ~/.config/borders
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- Shared Symlinks -------------------------------------------------------

ln -s "$DOTFILES_DIR/home/config/nvim" ~/.config/nvim
ln -s "$DOTFILES_DIR/home/config/kitty" ~/.config/kitty
ln -s "$DOTFILES_DIR/home/zshrc" ~/.zshrc
ln -s "$DOTFILES_DIR/home/zprofile" ~/.zprofile
ln -s "$DOTFILES_DIR/home/gitconfig" ~/.gitconfig
ln -s "$DOTFILES_DIR/home/config/starship.toml" ~/.config/starship.toml
ln -s "$DOTFILES_DIR/home/config/topgrade.toml" ~/.config/topgrade.toml
ln -s "$DOTFILES_DIR/home/tmux.conf" ~/.tmux.conf
mkdir -p ~/.config/spicetify/Themes/Comfy
ln -s "$DOTFILES_DIR/home/config/spicetify/config-xpui.ini" ~/.config/spicetify/config-xpui.ini
ln -s "$DOTFILES_DIR/home/config/spicetify/Themes/Comfy/color.ini" ~/.config/spicetify/Themes/Comfy/color.ini

# ---- Firefox Shared Setup --------------------------------------------------

if [ "$OS" = "Linux" ]; then
  if [ -d ~/.config/mozilla/firefox ]; then
    FIREFOX_BASE=~/.config/mozilla/firefox
  else
    FIREFOX_BASE=~/.mozilla/firefox
  fi
elif [ "$OS" = "Darwin" ]; then
  FIREFOX_BASE=~/Library/Application\ Support/Firefox
fi

if [ -n "$FIREFOX_BASE" ]; then
  # Read active profile from profiles.ini (otherwise grab first default-release)
  FIREFOX_PROFILE_PATH=$(grep "Path=" "$FIREFOX_BASE/profiles.ini" 2> /dev/null | grep "default-release" | cut -d "=" -f 2 | head -n 1)
  if [ -n "$FIREFOX_PROFILE_PATH" ]; then
    FIREFOX_PROFILE="$FIREFOX_BASE/$FIREFOX_PROFILE_PATH"
  else
    FIREFOX_PROFILE=$(ls -d "$FIREFOX_BASE"/*.default-release 2> /dev/null | head -n 1)
  fi

  if [ -n "$FIREFOX_PROFILE" ]; then
    # Check if the textfox theme is already installed by looking for its user.js and chrome/userChrome.css
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
  ln -s "$DOTFILES_DIR/home/config/dunst" ~/.config/dunst
  ln -s "$DOTFILES_DIR/home/config/hypr" ~/.config/hypr
  ln -s "$DOTFILES_DIR/home/config/wofi" ~/.config/wofi
  ln -s "$DOTFILES_DIR/home/config/wireplumber" ~/.config/wireplumber
  ln -s "$DOTFILES_DIR/home/config/electron28-flags.conf" ~/.config/electron28-flags.conf
  ln -s "$DOTFILES_DIR/home/config/quickshell" ~/.config/quickshell
  ln -s "$DOTFILES_DIR/home/config/fontconfig" ~/.config/fontconfig
  ln -s "$DOTFILES_DIR/home/config/systemd" ~/.config/systemd

  # Initialize Firefox and Spicetify Dynamic Themes
  python3 "$DOTFILES_DIR/home/scripts/apply_theme.py"
elif [ "$OS" = "Darwin" ]; then
  ln -s "$DOTFILES_DIR/home/config/sketchybar" ~/.config/sketchybar
  ln -s "$DOTFILES_DIR/home/config/skhd" ~/.config/skhd
  ln -s "$DOTFILES_DIR/home/config/svim" ~/.config/svim
  ln -s "$DOTFILES_DIR/home/config/yabai" ~/.config/yabai
  ln -s "$DOTFILES_DIR/home/config/borders" ~/.config/borders
fi
