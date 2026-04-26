#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

AEROSPACE_FOCUSED_MONITOR=$(aerospace list-monitors --focused | awk '{print $1}')
AEROSPACE_WORKSPACE_FOCUSED_MONITOR=$(aerospace list-workspaces --monitor focused --empty no)
AEROSPACE_EMPTY_WORKSPACE=$(aerospace list-workspaces --monitor focused --empty)
AEROSPACE_NUM_MONITORS=$(aerospace list-monitors | wc -l | tr -d ' ')

# When only the main monitor is connected, A-I are parked on it temporarily.
# Drop them from the lists so sketchybar doesn't touch items that weren't created.
if [ "$AEROSPACE_NUM_MONITORS" = "1" ]; then
  AEROSPACE_WORKSPACE_FOCUSED_MONITOR=$(printf '%s\n' $AEROSPACE_WORKSPACE_FOCUSED_MONITOR | grep -v '^[A-I]$' | tr '\n' ' ')
  AEROSPACE_EMPTY_WORKSPACE=$(printf '%s\n' $AEROSPACE_EMPTY_WORKSPACE | grep -v '^[A-I]$' | tr '\n' ' ')
fi

reload_workspace_icon() {
  apps=$(aerospace list-windows --workspace "$@" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app
    do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
    done <<< "${apps}"
  else
    icon_strip=" —"
  fi

  sketchybar --animate sin 10 --set space.$@ label="$icon_strip"
}

if [ "$SENDER" = "aerospace_workspace_change" ]; then
  reload_workspace_icon "$AEROSPACE_PREV_WORKSPACE"
  reload_workspace_icon "$AEROSPACE_FOCUSED_WORKSPACE"

  sketchybar --set space.$AEROSPACE_FOCUSED_WORKSPACE icon.highlight=true \
                         label.highlight=true \
                         background.border_color=$GREY

  sketchybar --set space.$AEROSPACE_PREV_WORKSPACE icon.highlight=false \
                         label.highlight=false \
                         background.border_color=$BACKGROUND_2

  for i in $AEROSPACE_WORKSPACE_FOCUSED_MONITOR; do
    sketchybar --set space.$i display=$AEROSPACE_FOCUSED_MONITOR
  done

  for i in $AEROSPACE_EMPTY_WORKSPACE; do
    sketchybar --set space.$i display=0
  done

  # Always show the focused workspace even if it's empty
  sketchybar --set space.$AEROSPACE_FOCUSED_WORKSPACE display=$AEROSPACE_FOCUSED_MONITOR

else
  # Initial load: highlight the currently focused workspace
  CURRENT=$(aerospace list-workspaces --focused)
  sketchybar --set space.$CURRENT icon.highlight=true \
                     label.highlight=true \
                     background.border_color=$GREY
fi
