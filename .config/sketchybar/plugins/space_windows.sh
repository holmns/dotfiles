#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/helpers/workspace_icons.sh"

if [ "$SENDER" = "aerospace_workspace_change" ]; then
  # Move the focus highlight from the previous workspace to the new one.
  sketchybar --set space.$AEROSPACE_FOCUSED_WORKSPACE icon.highlight=true \
                         label.highlight=true \
                         background.border_color=$GREY

  sketchybar --set space.$AEROSPACE_PREV_WORKSPACE icon.highlight=false \
                         label.highlight=false \
                         background.border_color=$BACKGROUND_2

  # Rebuild every workspace's icons + visibility (not just prev/focused), so any
  # workspace that changed while we were elsewhere is corrected here too.
  ws_refresh --animate

else
  # Initial load: highlight the currently focused workspace.
  CURRENT=$(aerospace list-workspaces --focused)
  sketchybar --set space.$CURRENT icon.highlight=true \
                     label.highlight=true \
                     background.border_color=$GREY
fi
