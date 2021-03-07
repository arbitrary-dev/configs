#!/bin/sh

#HANDLE="`amixer -D bluealsa | grep A2DP | cut -d\' -f2`"
#DEVICE="${HANDLE:+bluealsa}"

case "$2" in
  VOLUP) export PULSE_RUNTIME_PATH=/run/user/1000/pulse/
         su man -c "amixer -q -M set Master playback 5%+" ;;
  VOLDN) export PULSE_RUNTIME_PATH=/run/user/1000/pulse/
         su man -c "amixer -q -M set Master playback 5%-" ;;
  MUTE)  export PULSE_RUNTIME_PATH="/run/user/1000/pulse/"
         su man -c "amixer -q set Master playback toggle" ;;
esac
