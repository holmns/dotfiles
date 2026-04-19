#!/bin/sh

sketchybar --add item input_source right
sketchybar --add event input_change "AppleSelectedInputSourcesChangedNotification"
sketchybar --set input_source \
    padding_right=10 \
    label.font="$FONT:Bold:12.0" \
    label.color=$BLACK \
    background.color=$ICON_COLOR \
    background.height=18 \
    background.y_offset=-1 \
    background.corner_radius=6 \
    label.shadow.drawing=off \
    script="$PLUGIN_DIR/get_input_source.sh" \
    --subscribe input_source input_change
