#!/bin/bash
# Switch to workspace index $1 (1-9) on the currently focused monitor.
# Main monitor holds workspaces 1-9; secondary holds A-I.

set -euo pipefail

idx="${1:?usage: focus-workspace.sh <1-9>}"
aerospace="/opt/homebrew/bin/aerospace"

if [ "$("$aerospace" list-monitors | wc -l | tr -d ' ')" = "1" ]; then
  target="$idx"
else
  case "$("$aerospace" list-workspaces --focused)" in
    [A-I])
      letters=(A B C D E F G H I)
      target="${letters[$((idx - 1))]}"
      ;;
    *) target="$idx" ;;
  esac
fi

"$aerospace" workspace "$target"
