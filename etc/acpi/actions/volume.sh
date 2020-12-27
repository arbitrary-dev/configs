#!/bin/sh

#HANDLE="`amixer -D bluealsa | grep A2DP | cut -d\' -f2`"
#DEVICE="${HANDLE:+bluealsa}"

HANDLE="${HANDLE:-Master}"
DEVICE="${DEVICE:-pulse}"
USER=man

case "$1" in
  *up)   su $USER -c "amixer -D '$DEVICE' -q -M set '$HANDLE' playback 5%+" ;;
  *down) su $USER -c "amixer -D '$DEVICE' -q -M set '$HANDLE' playback 5%-" ;;
  *mute) su $USER -c "amixer -D '$DEVICE' -q set '$HANDLE' playback toggle" ;;
esac
