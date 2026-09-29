# dotfiles

Dotfiles for macOS and Linux. Managed via a symlink installer.

## Install

./install.sh

The installer symlinks everything under home/ into $HOME, installs
OS-specific packages (Homebrew on macOS, pacman on Arch Linux), and sets up
shell plugins.

## Layout

- home/ - files symlinked into $HOME
- home/zshrc - shared zsh config (macOS + Linux)
- home/config/ - app configs (kitty, nvim, yabai, skhd, sketchybar, hypr, ...)
- home/scripts/ - helper scripts (wake-pc, theme switching, backups, ...)
- install.sh - the installer
