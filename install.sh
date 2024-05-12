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

ln -s ~/code/dotfiles/config/rc.conf ~/.config/ranger/rc.conf
ln -s ~/code/dotfiles/config/hypr ~/.config/hypr
ln -s ~/code/dotfiles/config/kitty ~/.config/kitty/
ln -s ~/code/dotfiles/config/zshrc ~/.zshrc
ln -s ~/code/dotfiles/config/rofi ~/.config/rofi
ln -s ~/code/dotfiles/config/gitconfig ~/.gitconfig
ln -s ~/code/dotfiles/config/dunst ~/.config/dunst
ln -s ~/code/dotfiles/config/starship.toml ~/.config/starship.toml
ln -s ~/code/dotfiles/config/topgrade.toml ~/.config/topgrade.toml
ln -s ~/code/dotfiles/config/tmux.conf ~/.tmux.conf
