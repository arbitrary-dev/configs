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
      | sed 's/\\\"/\&quot;/g' \
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
    # Return escaped quotes back (were needed for the AWK script)
    MUSIC=`sed 's/&quot;/"/g' <<< "$MUSIC"`
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
    awk '
      /^MemTotal:/ { total = $2 }
      /^MemAvailable:/ { avail = $2 }
      total && avail {
        memory = (total - avail) / 1024
        if (memory < 1024) { printf "%dM", memory }
        else { printf "%.2gG", memory / 1024 }
        exit
      }
    ' /proc/meminfo
  `
  # Swap + Zswap
  MEMORY+=`
    awk '
      /^SwapTotal:/ { swap_total = $2 }
      /^SwapFree:/ { swap_free = $2 }
      /^Zswapped:/ { zswap = $2 }
      swap_total && swap_free && zswap != "" {
        memory = (swap_total - swap_free + zswap) / 1024
        # Show swap if 16+ Mb
        if (memory > 16 && memory < 1024) { printf " (%dM)", memory }
        else { printf " (%.2gG)", memory / 1024 }
        exit
      }
    ' /proc/meminfo
  `
  MEMORY+='  '

  DATETIME=`date +'%Y-%m-%d %H:%M'`

  echo "$MUSIC$BATTERY$CPU$MEMORY$DATETIME "

  sleep 7
done
