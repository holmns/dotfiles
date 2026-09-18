#!/usr/bin/env bash
# Single source of truth for how the workspace (space) items look: their app-icon
# strips AND which ones are shown on screen.
#
# Why this exists: the strip-building loop used to be copy-pasted into spaces.sh,
# space_windows.sh and front_app.sh, and each event path refreshed a different
# subset of workspaces. That left icons (and visibility) stale whenever something
# changed a workspace that wasn't the focused one -- quitting an app, an app
# launching into a background workspace, or a window moving. ws_refresh rebuilds
# every workspace from one query, so every event path converges on the same
# correct state.

# Source icon_map once so mapping an app -> icon is an in-process shell function
# call instead of spawning a bash subprocess per window. That keeps a full "every
# workspace" refresh cheap enough to run on every app switch.
. "$CONFIG_DIR/plugins/icon_map.sh" >/dev/null 2>&1

# sb_display_for: aerospace monitor id -> sketchybar display number (cached).
. "$CONFIG_DIR/helpers/resolve_display.sh"

# Rebuild every workspace's icon strip and visibility, across all monitors, in a
# single sketchybar call.
#   ws_refresh            plain update (used by init / app-switch paths)
#   ws_refresh --animate  animate the label change (used by the switch path)
#
# Note: deliberately uses only indexed arrays / string ops so it runs on the
# stock macOS bash 3.2 that `/usr/bin/env bash` resolves to (no `declare -A`).
ws_refresh() {
  local anim=()
  if [ "$1" = "--animate" ]; then anim=(--animate sin 10); shift; fi

  # Always keep the focused workspace visible, even when it's empty.
  local focused
  focused=$(aerospace list-workspaces --focused)

  # One query for every window ("workspace|app"); reused for every workspace
  # below. Far cheaper than asking aerospace per workspace, which matters when
  # refreshing on every app switch.
  local windows
  windows=$(aerospace list-windows --all --format '%{workspace}|%{app-name}')

  local args=() m sb w ws app strip had
  for m in $(aerospace list-monitors | awk '{print $1}'); do
    sb=$(sb_display_for "$m")
    while IFS= read -r w; do
      [ -n "$w" ] || continue
      strip=" "
      had=0
      while IFS='|' read -r ws app; do
        [ "$ws" = "$w" ] || continue
        __icon_map "$app"
        strip="$strip $icon_result"
        had=1
      done <<EOF
$windows
EOF
      if [ "$had" = 1 ]; then
        # Has windows: show it on its monitor with its icon strip.
        args+=(--set "space.$w" label="$strip" display="$sb")
      elif [ "$w" = "$focused" ]; then
        # Empty but focused: show it anyway, with a placeholder.
        args+=(--set "space.$w" label=" —" display="$sb")
      else
        # Empty and not focused: hide it.
        args+=(--set "space.$w" label=" —" display=0)
      fi
    done <<EOF
$(aerospace list-workspaces --monitor "$m")
EOF
  done

  [ "${#args[@]}" -gt 0 ] && sketchybar "${anim[@]}" "${args[@]}"
}
