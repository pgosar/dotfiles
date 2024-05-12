#!/bin/bash

rm -f ~/.config/ranger/rc.conf
rm -rf ~/.config/kitty
rm -f ~/.zshrc
rm -f ~/.gitconfig
rm -rf ~/.config/rofi
rm -rf ~/.config/dunst
rm -rf ~/.config/hypr
rm -f ~/.config/starship.toml
rm -f ~/.config/topgrade.toml
rm -f ~/.tmux.conf

mkdir -p ~/.config/kitty
mkdir -p ~/.config/rofi
mkdir -p ~/.config/ranger
mkdir -p ~/.config/dunst
mkdir -p ~/.config/hypr

export DOTFILES_DIR=~/code/dotfiles/

ln -s "$DOTFILES_DIR/config/rc.conf" ~/.config/ranger/rc.conf
ln -s "$DOTFILES_DIR/config/hypr" ~/.config/hypr
ln -s "$DOTFILES_DIR/config/kitty" ~/.config/kitty/
ln -s "$DOTFILES_DIR/config/zshrc" ~/.zshrc
ln -s "$DOTFILES_DIR/config/rofi" ~/.config/rofi
ln -s "$DOTFILES_DIR/config/gitconfig" ~/.gitconfig
ln -s "$DOTFILES_DIR/config/dunst" ~/.config/dunst
ln -s "$DOTFILES_DIR/config/starship.toml" ~/.config/starship.toml
ln -s "$DOTFILES_DIR/config/topgrade.toml" ~/.config/topgrade.toml
ln -s "$DOTFILES_DIR/config/tmux.conf" ~/.tmux.conf
