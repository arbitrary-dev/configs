#!/bin/sh

while true; do
  CPU=`cut -d\  -f1 /proc/loadavg`'  '

  MEMORY=`
    free --human \
    | awk '{print $3}' \
    | sed -nE "s/(.+[GM])i/\1/p" \
    | awk '{if (NR==1) printf "%s ",$0; else printf "(%s) ",$0}'`' '

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

  note='<span rise="-2pt">𝅘𝅥𝅮</span>'
  MUSIC=
  if pgrep mpd >/dev/null && (mpc | fgrep -q '[playing]'); then
    # Get metadata from MPD
    MUSIC=`mpc -f "[[%artist% - ]%title%]" | head -1`
    if [ -z "$MUSIC" ]; then
      file=`mpc -f '[%file%]' | head -1`
      MUSIC=`basename "$file"`
    fi
  fi
  if [ -n "$MUSIC" ]; then
    # Trim to 64 chars.
    MUSIC=`sed -E 's_(.{64}).+_\1…_' <<< "$MUSIC"`
    MUSIC=`sed -E 's_[ ,.\!?({]+(…)$_\1_' <<< "$MUSIC"`
    # Address &'s.
    MUSIC=`sed -E 's/&/&amp;/g' <<< "$MUSIC"`
    # Add final notes
    MUSIC="$note $MUSIC $note  "
  fi

  echo "$MUSIC$BATTERY$CPU$MEMORY$DATETIME "

  sleep 7
done
