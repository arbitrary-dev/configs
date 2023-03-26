#!/bin/sh

while true; do

  note='<span rise="-2pt">𝅘𝅥𝅮</span>'
  MUSIC=
  if pgrep mpd >/dev/null && (mpc | fgrep -q '[playing]'); then
    # Get metadata from MPD
    MUSIC=`mpc -f "[[%artist% - ]%title%]" | head -1`
    if [ -z "$MUSIC" ]; then
      file=`mpc -f '[%file%]' | head -1`
      MUSIC=`basename "$file"`
    fi
  else
    # Get metadata from PulseAudio
    MUSIC=`
      pacmd list-sink-inputs \
      | awk -F\" '
        /state: RUNNING/ { is_playing = 1 }
        is_playing && /media.name = / {
          gsub(" - mpv$", "", $2)
          gsub("^Playback$", "", $2) # chromium
          print $2
          exit
        }
      '
    `
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

  BAT=`upower -i /org/freedesktop/UPower/devices/battery_BAT0`
  CHARGE=`sed -En '/percentage/{s/.*: +(.+)/\1/p}' <<< $BAT`
  STATE=`sed -En '/state/{s/.*: +(.+)/\1/p}' <<< $BAT`
  [ "$STATE" == "charging" ] && STATE="+"
  [ "$STATE" == "discharging" ] && STATE="−"
  TIMETO=`sed -En '/time to/{s/.*: +(.+)/\1/p}' <<< $BAT`
  [ ! -z "$TIMETO" ] && TIMETO=" ($STATE$TIMETO)"
  BATTERY=
  [ "$STATE" != "fully-charged" ] && BATTERY="$CHARGE$TIMETO  "

  CPU=`cut -d\  -f1 /proc/loadavg`
  CPU+=' '`
    sed -e s/schedutil/sched/  \
        -e s/powersave/psave/  \
        -e s/performance/perf/ \
      /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  `'  '

  MEMORY=`
    free --human \
    | awk '{print $3}' \
    | sed -nE "s/(.+[GM])i/\1/p" \
    | awk '{if (NR==1) printf "%s ",$0; else printf "(%s) ",$0}'`' '

  DATETIME=`date +'%Y-%m-%d %H:%M'`

  echo "$MUSIC$BATTERY$CPU$MEMORY$DATETIME "

  sleep 7
done
