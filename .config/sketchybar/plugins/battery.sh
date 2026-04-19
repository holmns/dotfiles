#!/bin/bash

source "$CONFIG_DIR/colors.sh"

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"
POWERMODE="$(pmset -g | awk '/powermode/ {print $2}')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case ${PERCENTAGE} in
  [8-9][0-9] | 100)
    LABEL="􀛨"
    ;;
  7[0-9])
    LABEL="􀺸"
    ;;
  [4-6][0-9])
    LABEL="􀺶"
    ;;
  [1-3][0-9])
    LABEL="􀛩"
    ;;
  [0-9])
    LABEL="􀛪"
    ;;
esac

if [[ "$CHARGING" != "" ]]; then
  LABEL="􀢋"
fi

if [[ "$POWERMODE" == "1" ]]; then
  COLOR="0xfff5a627"
else
  COLOR="$WHITE"
fi

sketchybar --set "$NAME" icon="${PERCENTAGE}%" label="$LABEL" label.color="$COLOR"
