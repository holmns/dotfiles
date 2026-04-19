#!/bin/bash

CONNECTED=$(scutil --nwi | grep -q "Not Reachable" && echo 0 || echo 1)

if [[ "$CONNECTED" == "0" ]]; then
  ICON="􀙈"
else
  ICON="􀙇"
fi

sketchybar --set wifi icon="$ICON"
