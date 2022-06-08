#!/bin/sh

while true; do
  MEMORY=`
    free --human \
    | awk '{print $3}' \
    | sed -nE "s/(.+[GM])i/\1/p" \
    | awk '{if (NR==1) printf "%s ",$0; else printf "(%s) ",$0}'`" "

  BAT=`upower -i /org/freedesktop/UPower/devices/battery_BAT0`
  CHARGE=`sed -En '/percentage/{s/.*: +(.+)/\1/p}' <<< $BAT`
  STATE=`sed -En '/state/{s/.*: +(.+)/\1/p}' <<< $BAT`
  [ "$STATE" == "charging" ] && STATE="+"
  [ "$STATE" == "discharging" ] && STATE="−"
  TIMETO=`sed -En '/time to/{s/.*: +(.+)/\1/p}' <<< $BAT`
  [ ! -z "$TIMETO" ] && TIMETO=" ($STATE$TIMETO)"
  BATTERY=
  [ "$STATE" != "fully-charged" ] && BATTERY="$CHARGE$TIMETO  "

  DATETIME=`date +'%Y-%m-%d %H:%M'`

  echo "$BATTERY$MEMORY$DATETIME "
  sleep 61
done
