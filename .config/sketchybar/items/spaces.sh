#!/usr/bin/env bash

#SPACE_ICONS=("1" "2" "3" "4")

# Destroy space on right click, focus space on left click.
# New space by left clicking separator (>)

sketchybar --add event aerospace_workspace_change

# Aerospace monitor IDs don't match sketchybar's display IDs, so map each
# aerospace monitor to the right sketchybar `display=` number. Shared with the
# workspace-change handler so both paths agree on where a space renders.
# Why: without this, workspaces render on the wrong (or no) physical display.
source "$CONFIG_DIR/helpers/workspace_icons.sh"

for m in $(aerospace list-monitors | awk '{print $1}'); do
  sb_display=$(sb_display_for "$m")
  for i in $(aerospace list-workspaces --monitor $m); do
    sid=$i
    label_icon=$sid
    space=(
      space="$sid"
      icon="$label_icon"
      icon.color=$GREY
      icon.highlight_color=$WHITE
      icon.padding_left=10
      icon.padding_right=10
      display=$sb_display
      padding_left=2
      padding_right=2
      label.padding_right=20
      label.color=$GREY
      label.highlight_color=$WHITE
      label.font="sketchybar-app-font:Regular:14.0"
      label.y_offset=-1
      background.color=$BACKGROUND_1
      background.border_color=$BACKGROUND_2
      script="$PLUGIN_DIR/space.sh"
    )

    sketchybar --add space space.$sid left \
               --set space.$sid "${space[@]}" \
               --subscribe space.$sid mouse.clicked
  done
done

# Fill in every workspace's icon strip + visibility from one shared code path.
ws_refresh


space_creator=(
  icon=􀆊
  icon.font="$FONT:Semibold:14.0"
  padding_left=10
  padding_right=8
  label.drawing=off
  display=active
  #click_script='yabai -m space --create'
  script="$PLUGIN_DIR/space_windows.sh"
  #script="$PLUGIN_DIR/aerospace.sh"
  icon.color=$WHITE
)

# sketchybar --add item space_creator left               \
#            --set space_creator "${space_creator[@]}"   \
#            --subscribe space_creator space_windows_change
sketchybar --add item space_creator left               \
           --set space_creator "${space_creator[@]}"   \
           --subscribe space_creator aerospace_workspace_change
