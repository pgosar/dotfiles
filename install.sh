#!/bin/bash

rm -f ~/.zshrc
rm -f ~/.zprofile
rm -f ~/.gitconfig
rm -f ~/.tmux.conf
rm -rf ~/.config/ranger
rm -rf ~/.config/kitty
rm -rf ~/.config/nvim
rm -f ~/.config/starship.toml
rm -f ~/.config/topgrade.toml

source ./dotfiles_env.sh

ln -s "$DOTFILES_DIR/config/nvim" ~/.config/nvim
ln -s "$DOTFILES_DIR/config/ranger" ~/.config/ranger
ln -s "$DOTFILES_DIR/config/kitty" ~/.config/kitty
ln -s "$DOTFILES_DIR/config/zshrc" ~/.zshrc
ln -s "$DOTFILES_DIR/config/zprofile" ~/.zprofile
ln -s "$DOTFILES_DIR/config/gitconfig" ~/.gitconfig
ln -s "$DOTFILES_DIR/config/starship.toml" ~/.config/starship.toml
ln -s "$DOTFILES_DIR/config/topgrade.toml" ~/.config/topgrade.toml
ln -s "$DOTFILES_DIR/config/tmux.conf" ~/.tmux.conf
