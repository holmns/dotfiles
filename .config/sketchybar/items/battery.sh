#!/bin/sh

battery=(
  script="$PLUGIN_DIR/battery.sh"
  padding_right=5
  padding_left=0
  update_freq=120
  updates=on
)

sketchybar --add item battery right \
           --set battery "${battery[@]}"\
              padding_left=0 \
              icon.font="$FONT:Semibold:12.0" \
              label.font="$FONT:Regular:16.0" \
              label.padding_left=1 \
              label.color=$WHITE \
              update_freq=120 \
           --subscribe battery power_source_change system_woke

