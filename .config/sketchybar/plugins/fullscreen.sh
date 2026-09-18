#!/usr/bin/env bash

# Hide the bar while the focused window is in macOS *native* fullscreen.
# The bar runs with topmost=window, which draws it above every window --
# including native-fullscreen apps (videos, games), where it used to float on
# top of the content. AeroSpace tracks native-fullscreen windows with the
# special window-layout "macos_native_fullscreen", so the focused window's
# layout tells us when to get out of the way.
#
# AeroSpace's own `fullscreen` command (alt-f) respects the outer gaps and
# never collides with the bar, so it deliberately does NOT hide anything.
#
# Fails open: if aerospace is unreachable or no window is focused, the bar
# just stays visible.

layout=$(aerospace list-windows --focused --format '%{window-layout}' 2>/dev/null)

case "$layout" in
  *fullscreen*) sketchybar --bar hidden=on ;;
  *)            sketchybar --bar hidden=off ;;
esac
