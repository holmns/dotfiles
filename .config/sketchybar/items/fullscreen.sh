#!/bin/sh

# Invisible watcher that hides the bar while a native-fullscreen window is
# focused (see plugins/fullscreen.sh for the why). Triggered by aerospace's
# on-focus-changed callback, by macOS space switches (entering/leaving native
# fullscreen always switches spaces), and a slow poll as a safety net.

sketchybar --add event aerospace_focus_change

fullscreen_watcher=(
  drawing=off
  updates=on # default when_shown would starve this hidden item of events
  update_freq=30
  script="$PLUGIN_DIR/fullscreen.sh"
)

sketchybar --add item fullscreen_watcher left \
           --set fullscreen_watcher "${fullscreen_watcher[@]}" \
           --subscribe fullscreen_watcher aerospace_focus_change \
                                          space_change \
                                          display_change \
                                          front_app_switched \
                                          system_woke
