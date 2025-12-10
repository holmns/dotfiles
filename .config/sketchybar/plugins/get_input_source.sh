#!/bin/sh

# hangul and english item

# Read the plist data
plist_data=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources)
current_input_source=$(echo "$plist_data" | plutil -convert xml1 -o - - | grep -A1 'KeyboardLayout Name' | tail -n1 | cut -d '>' -f2 | cut -d '<' -f1)

if [ "$current_input_source" = "ABC" ]; then
    sketchybar --set input_source label="A" \
        label.padding_left=5 \
        label.padding_right=9 \
        label.y_offset=0

elif [ "$current_input_source" = "Thai" ]; then
    sketchybar --set input_source label="ก" \
        label.padding_left=6 \
        label.padding_right=10 \
        label.y_offset=2
else
    sketchybar --set input_source label="-"
fi
