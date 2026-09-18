#!/usr/bin/env bash

if [ "$SENDER" = "front_app_switched" ]; then
  # Update the front-app item itself.
  sketchybar --set "$NAME" icon=$($CONFIG_DIR/plugins/icon_map.sh "$INFO") \
              label="$INFO"

  # An app switch is also our signal that an app may have opened or quit, which
  # changes a workspace's window set. Rebuild every workspace so a background
  # workspace that just gained/lost a window (or window) isn't left stale.
  source "$CONFIG_DIR/helpers/workspace_icons.sh"
  ws_refresh
fi
