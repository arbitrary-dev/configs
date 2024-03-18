#!/bin/bash

group=${1%%/*}
action=${1#*/}
device=$2
id=$3
value=$4
user=semyon
user_id=`id -u $user`

log_unhandled() {
  logger "ACPI event unhandled: $*"
}

case "$group" in
  button)
    case "$action" in
      wlan)
        if rfkill --output SOFT | grep -q "\bblocked\b"; then
          rfkill unblock all
          awesome-notify "Radio unblocked"
        elif pgrep bluetoothd && bluetoothctl info | grep -q "Connected: yes"; then
          # Block wifi only if there's a BT device connected.
          rfkill block wifi
          awesome-notify "Wi-Fi blocked"
        else
          rfkill block all
          awesome-notify "Radio blocked"
        fi
        ;;
      power)
      sleep)
        # handled by elogind
        ;;
      battery)
        if [[ "$device" == "BAT" ]]; then
          loginctl hibernate
        fi
        ;;
      volumeup)
        amixer -q -M set Master playback 5%+
        vicious-force volwidget
        ;;
      volumedown)
        amixer -q -M set Master playback 5%-
        vicious-force volwidget
        ;;
      mute)
        DISPLAY=:0.0 \
        su $user -c "
          XDG_RUNTIME_DIR=/run/user/$user_id pactl set-sink-mute @DEFAULT_SINK@ toggle
        "
        vicious-force volwidget
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
