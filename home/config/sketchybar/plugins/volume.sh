#!/usr/bin/env zsh

case ${INFO} in
0)
    ICON=""
    ICON_PADDING_RIGHT=21
    ;;
[1-2][0-9]|30)
    ICON=""
    ICON_PADDING_RIGHT=12
    ;;
*)
    ICON=""
    ICON_PADDING_RIGHT=6
    ;;
esac

sketchybar --set $NAME icon=$ICON icon.padding_right=5 label="$INFO%"
