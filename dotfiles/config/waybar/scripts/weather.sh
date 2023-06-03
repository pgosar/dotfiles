#!/usr/bin/env bash
WAYBAR_WEATHER_JSON_TEXT=$(curl 'wttr.in/?format=%c+%f')
WAYBAR_WEATHER_JSON_TOOLTIP=$(curl 'wttr.in/?format=%l:+%c+%f')

WAYBAR_WEATHER_JSON="{
		\"text\":\"${WAYBAR_WEATHER_JSON_TEXT}\",
		\"tooltip\":\"${WAYBAR_WEATHER_JSON_TOOLTIP}\",
}\n"

echo $WAYBAR_WEATHER_JSON
