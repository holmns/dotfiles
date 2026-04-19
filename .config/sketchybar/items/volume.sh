#!/bin/sh

volume_icon=(
  script="$PLUGIN_DIR/volume.sh"
  updates=on
  padding_right=5
  icon=$VOLUME_100
  icon.align=left
  icon.color=$WHITE
  icon.font="$FONT:Semibold:14.0"
  label.drawing=off
)

status_bracket=(
  background.color=$BACKGROUND_1
  background.border_color=$BACKGROUND_2
)

sketchybar --add item volume_icon right         \
           --set volume_icon "${volume_icon[@]}" \
           --subscribe volume_icon volume_change
