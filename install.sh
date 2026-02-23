#!/bin/bash

rm -f ~/.zshrc
rm -f ~/.zprofile
rm -f ~/.gitconfig
rm -f ~/.tmux.conf
rm -rf ~/.config/ranger
rm -rf ~/.config/kitty
rm -rf ~/.config/nvim
rm -rf ~/.config/sketchybar
rm -rf ~/.config/skhd
rm -rf ~/.config/svim
rm -rf ~/.config/yabai
rm -rf ~/.config/borders
rm -rf ~/.config/dunst
rm -rf ~/.config/hypr
rm -rf ~/.config/rofi
rm -rf ~/.config/waybar
rm -f ~/.config/electron28-flags.conf
rm -f ~/.config/starship.toml
rm -f ~/.config/topgrade.toml

source ./dotfiles_env.sh

ln -s "$DOTFILES_DIR/config/nvim" ~/.config/nvim
ln -s "$DOTFILES_DIR/config/ranger" ~/.config/ranger
ln -s "$DOTFILES_DIR/config/kitty" ~/.config/kitty
ln -s "$DOTFILES_DIR/config/sketchybar" ~/.config/sketchybar
ln -s "$DOTFILES_DIR/config/skhd" ~/.config/skhd
ln -s "$DOTFILES_DIR/config/svim" ~/.config/svim
ln -s "$DOTFILES_DIR/config/yabai" ~/.config/yabai
ln -s "$DOTFILES_DIR/config/borders" ~/.config/borders
ln -s "$DOTFILES_DIR/config/dunst" ~/.config/dunst
ln -s "$DOTFILES_DIR/config/hypr" ~/.config/hypr
ln -s "$DOTFILES_DIR/config/rofi" ~/.config/rofi
ln -s "$DOTFILES_DIR/config/waybar" ~/.config/waybar
ln -s "$DOTFILES_DIR/config/electron28-flags.conf" ~/.config/electron28-flags.conf
ln -s "$DOTFILES_DIR/config/zshrc" ~/.zshrc
ln -s "$DOTFILES_DIR/config/zprofile" ~/.zprofile
ln -s "$DOTFILES_DIR/config/gitconfig" ~/.gitconfig
ln -s "$DOTFILES_DIR/config/starship.toml" ~/.config/starship.toml
ln -s "$DOTFILES_DIR/config/topgrade.toml" ~/.config/topgrade.toml
ln -s "$DOTFILES_DIR/config/tmux.conf" ~/.tmux.conf
