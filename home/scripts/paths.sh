#!/usr/bin/env bash

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
DOTFILES_HOME_DIR="$DOTFILES_DIR/home"
export DOTFILES_CONFIG_DIR="$DOTFILES_HOME_DIR/config"
DOTFILES_SCRIPTS_DIR="$DOTFILES_HOME_DIR/scripts"

# Used by install.sh, which sources this file.
export APPLY_THEME_SCRIPT="$DOTFILES_SCRIPTS_DIR/apply_theme.py"
