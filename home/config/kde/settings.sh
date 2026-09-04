#!/usr/bin/env bash
# KDE settings managed by the dotfiles installer.
# shellcheck disable=SC2034 # Values are consumed after this file is sourced.

KDE_KWIN_SCRIPT_ID="rememberwindowpositions"
KDE_KWIN_SCRIPT_REPOSITORY="https://github.com/rxappdev/RememberWindowPositions.git"
KDE_KWIN_SCRIPT_VERSION="6.1.0"
KDE_KWIN_SCRIPT_COMMIT="bf9f8dbc5c2b08f0cf1aed1424c7c4049039ee09"

# file | group | key | value
KDE_CONFIG_SETTINGS=(
  "ksmserverrc|General|loginMode|restorePreviousLogout"
  "kwinrc|Plugins|rememberwindowpositionsEnabled|true"
  "kwinrc|Script-rememberwindowpositions|sessionRestore|true"
)
