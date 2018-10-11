#!/bin/bash

group=${1%%/*}
action=${1#*/}
device=$2
id=$3
value=$4
user=semyon

log_unhandled() {
  logger "ACPI event unhandled: $*"
}

case "$group" in
  button)
    case "$action" in
      wlan)
        wl=/etc/init.d/net.wlp5s0b1
        if [[ $($wl status | sed -r "s/.*?: //") == "stopped" ]]; then
          $wl start
        else
          $wl stop
        fi
        ;;
      power)
        if [[ "$device" == "PBTN" ]]; then
          /etc/acpi/actions/powerbtn.sh
        fi
        ;;
      sleep)
        # needed to handle event just once
        if [[ "$device" == "SBTN" ]]; then
          s2ram
        fi
        ;;
      battery)
        if [[ "$device" == "BAT" ]]; then
          s2disk
        fi
        ;;
      volumeup)
        amixer -q -M set Master playback 5%+
        DISPLAY=:0.0 su $user -c "echo 'vicious.force({volwidget})' | awesome-client"
        ;;
      volumedown)
        amixer -q -M set Master playback 5%-
        DISPLAY=:0.0 su $user -c "echo 'vicious.force({volwidget})' | awesome-client"
        ;;
      mute)
        amixer -q set Master playback toggle
        DISPLAY=:0.0 su $user -c "echo 'vicious.force({volwidget})' | awesome-client"
        ;;
      *) log_unhandled $* ;;
    esac
    ;;
  video)
    case "$action" in
      brightnessup)
        DISPLAY=:0.0 su $user -c "xbacklight +5"
        ;;
      brightnessdown)
        DISPLAY=:0.0 su $user -c "xbacklight -5"
        ;;
      *) log_unhandled $* ;;
    esac
    ;;
  *) log_unhandled $* ;;
esac
