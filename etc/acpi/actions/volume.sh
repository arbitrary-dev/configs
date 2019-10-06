#!/bin/sh

case "$1" in
  *up)   amixer -q -M set Master playback 5%+ ;;
  *down) amixer -q -M set Master playback 5%- ;;
  *mute) amixer -q set Master playback toggle ;;
esac
