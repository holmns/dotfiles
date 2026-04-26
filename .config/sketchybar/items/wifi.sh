#!/bin/bash

sketchybar --add item wifi right \
           --set wifi \
           icon=􁅃 \
           padding_left=5 \
           padding_right=5 \
           script="$PLUGIN_DIR/wifi.sh" \
           --subscribe wifi wifi_change system_woke
