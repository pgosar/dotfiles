#!/bin/bash

rm -f ~/.config/ranger/rc.conf
rm -rf ~/.config/kitty
rm -f ~/.zshrc
rm -f ~/.gitconfig
rm -rf ~/.config/rofi
rm -f ~/.config/dunst/dunstrc
rm -rf ~/.config/hypr
rm -f ~/.config/starship.toml
rm -f ~/.config/topgrade.toml
rm -f ~/.tmux.conf

mkdir -p ~/.config/kitty
mkdir -p ~/.config/rofi
mkdir -p ~/.config/dunst
mkdir -p ~/.config/hypr

ln -s ~/code/dotfiles/dotfiles/config/rc.conf ~/.config/ranger/rc.conf
ln -s ~/code/dotfiles/dotfiles/config/hypr ~/.config/hypr
ln -s ~/code/dotfiles/dotfiles/config/kitty ~/.config/kitty/
ln -s ~/code/dotfiles/dotfiles/config/zshrc ~/.zshrc
ln -s ~/code/dotfiles/dotfiles/config/rofi ~/.config/rofi
ln -s ~/code/dotfiles/dotfiles/config/gitconfig ~/.gitconfig
ln -s ~/code/dotfiles/dotfiles/config/dunst ~/.config/dunst
ln -s ~/code/dotfiles/dotfiles/config/starship.toml ~/.config/starship.toml
ln -s ~/code/dotfiles/dotfiles/config/topgrade.toml ~/.config/topgrade.toml
ln -s ~/code/dotfiles/dotfiles/config/tmux.conf ~/.tmux.conf
