#!/bin/sh

sketchybar --add item input_source right
sketchybar --set input_source \
    label.font="$FONT:Semibold:14.0" \
    script="$PLUGIN_DIR/get_input_source.sh" \
    label.color=$BLACK \
    background.color=$ICON_COLOR \
    background.height=20 \
    background.border_radius=6 \
    label.shadow.drawing=off \
    update_freq=1 


