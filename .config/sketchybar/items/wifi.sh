#!/bin/bash

sketchybar --add item wifi right \
           --set wifi \
           icon=􁅃 \
           update_freq=5 \
           padding_left=5 \
           padding_right=5 \
           script="$PLUGIN_DIR/wifi.sh"
