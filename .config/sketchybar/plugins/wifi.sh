#!/bin/bash

IPV4=$(ipconfig getifaddr en0)

if [[ -z "$IPV4" ]]; then
  ICON="􀙈"  # disconnected
elif [[ "$IPV4" == 172.20.10.* ]]; then
  ICON="􀉤"  # hotspot
else
  ICON="􀙇"  # wifi
fi

sketchybar --set wifi icon="$ICON"
