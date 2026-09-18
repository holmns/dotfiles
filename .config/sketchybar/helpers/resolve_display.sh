#!/bin/sh
# Resolve sketchybar `display=` numbers from aerospace monitor IDs.
#
# aerospace numbers monitors independently from macOS, so an aerospace monitor ID
# can't be handed to sketchybar's `display=` directly -- items land on the wrong
# screen, or off-screen (parked at -9999) when the number points at a display
# that isn't currently rendering. aerospace_display_map.py builds the correct
# mapping, but it shells out to system_profiler (~200ms), which is too slow to run
# on every workspace switch. So the result is cached and only recomputed when the
# monitor topology actually changes.
#
# Usage: source this file, then `sb_display_for <aerospace-monitor-id>`.

_dm_map="${TMPDIR:-/tmp}/sketchybar_display_map"
_dm_sigf="${TMPDIR:-/tmp}/sketchybar_display_map.sig"
_dm_sig=$(aerospace list-monitors | tr '\n' ';')

if [ ! -s "$_dm_map" ] || [ "$(cat "$_dm_sigf" 2>/dev/null)" != "$_dm_sig" ]; then
  python3 "$CONFIG_DIR/helpers/aerospace_display_map.py" 2>/dev/null > "$_dm_map"
  printf '%s' "$_dm_sig" > "$_dm_sigf"
fi

# Echo the sketchybar display number for an aerospace monitor ID
# (falls back to the ID itself if the map has no matching entry).
sb_display_for() {
  _want=$1
  _out=$1
  while IFS='|' read -r _aid _sb; do
    [ "$_aid" = "$_want" ] && _out=$_sb
  done < "$_dm_map"
  printf '%s' "$_out"
}
