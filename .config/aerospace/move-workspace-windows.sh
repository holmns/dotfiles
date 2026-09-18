#!/bin/bash
# Move every window in the focused workspace to workspace $1, then follow them there.
#
# Layout note: AeroSpace has no "move a whole container" command, so windows are
# moved one at a time. The target's tiling order follows the source order, which
# preserves simple side-by-side tilings. Deeply nested splits / accordion layouts
# get flattened into the target workspace's default tiling.

set -euo pipefail

target="${1:?usage: move-workspace-windows.sh <workspace>}"
aerospace=/opt/homebrew/bin/aerospace

current=$("$aerospace" list-workspaces --focused)
[ "$current" = "$target" ] && exit 0

# Snapshot the window list first: moving windows re-tiles the source as we go.
ids=$("$aerospace" list-windows --workspace "$current" --format '%{window-id}')

while read -r wid; do
  [ -n "$wid" ] || continue
  "$aerospace" move-node-to-workspace --window-id "$wid" "$target"
done <<< "$ids"

"$aerospace" workspace "$target"
