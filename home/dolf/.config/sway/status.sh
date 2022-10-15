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

  note='<span rise="-2pt">𝅘𝅥𝅮</span>'
  MUSIC=
  if pgrep mpd >/dev/null && (mpc | fgrep -q '[playing]'); then
    MUSIC=`mpc -f "[$note [%artist% - ]%title% $note]" | grep 𝅘𝅥𝅮`
    if [ -z "$MUSIC" ]; then
      file=`mpc -f '[%file%]' | head -1`
      MUSIC="$note "`basename "$file"`" $note"
    fi
    # Trim to 64 chars.
    MUSIC=`printf "$MUSIC" | sed -E "s_($note) (.{64}).+ ($note)_\1 \2… \3_"`
    MUSIC=`printf "$MUSIC" | sed -E "s_[ ,.\!?({]+(… $note)_\1_"`
    # Address &'s.
    MUSIC="$(printf "$MUSIC" | sed -E "s/&/&amp;/g")"
    [ ! -z "$MUSIC" ] && MUSIC="$MUSIC  "
  fi

  echo "$MUSIC$BATTERY$MEMORY$DATETIME "

  sleep 7
done
