#!/bin/sh

HANDLE="`amixer -D bluealsa | grep A2DP | cut -d\' -f2`"
DEVICE="${HANDLE:+bluealsa}"

HANDLE="${HANDLE:-Master}"
DEVICE="${DEVICE:-default}"

case "$1" in
  *up)   amixer -D "$DEVICE" -q -M set "$HANDLE" playback 5%+ ;;
  *down) amixer -D "$DEVICE" -q -M set "$HANDLE" playback 5%- ;;
  *mute) amixer -D "$DEVICE" -q set "$HANDLE" playback toggle ;;
esac
