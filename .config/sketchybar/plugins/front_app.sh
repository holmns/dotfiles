#!/bin/sh

if [ "$SENDER" = "front_app_switched" ]; then
  FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
  WORKSPACE_WINDOWS=$(aerospace list-windows --workspace $FOCUSED_WORKSPACE | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

  sketchybar --set "$NAME" icon=$($CONFIG_DIR/plugins/icon_map.sh "$INFO") \
              label="$INFO"

  icon_strip=" "
  if [ "${WORKSPACE_WINDOWS}" != "" ]; then
    while read -r app
    do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
    done <<< "${WORKSPACE_WINDOWS}"
  else
    icon_strip=" —"
  fi

  sketchybar --set space.$FOCUSED_WORKSPACE label="$icon_strip"
fi
