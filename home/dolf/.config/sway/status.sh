#!/bin/sh

while true; do

  note='<span rise="-2pt">𝅘𝅥𝅮</span>'
  MUSIC=
  if pgrep mpd >/dev/null && (mpc | fgrep -q '[playing]'); then
    # Get metadata from MPD
    MUSIC=`mpc -f "[[%artist% - ]%title%]|[%file%]" current`
    # Crop filenames
    [[ "$MUSIC" =~ \.[0-9a-zA-Z]{3,4}$ ]] \
    && MUSIC=`basename "$MUSIC"`
  else
    # Get metadata from PulseAudio
    MUSIC=`
      pacmd list-sink-inputs \
      | sed 's/\\\"/\&quot;/g' \
      | awk -F\" '
        /state: RUNNING/ { is_playing = 1 }
        is_playing && /media.name = / {
          gsub(" - mpv$", "", $2)
          gsub("^(ALSA |)Playback|My Pulse Output$", "", $2) # chromium
          gsub("^Simultaneous output on .+", "", $2) # some random apps
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
    # Remove emojis
    #MUSIC=`perl -CS -pe 's/ ?\p{Emoji}//g' <<< "$MUSIC"`
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
        if (memory < 1000) { printf "%dM", memory }
        else if (memory < 1024) { printf "1G" }
        else { printf "%.2gG", memory / 1024 }
        exit
      }
    ' /proc/meminfo
  `
  # Swap
  MEMORY+=`
    awk '
      /^SwapTotal:/ { swap_total = $2 }
      /^SwapFree:/ { swap_free = $2 }
      # Zswapped seems to be included in the above metric
      swap_total && swap_free {
        used = (swap_total - swap_free) / 1024
        # Show swap only if it is 64+ Mb
        if (used >= 64) {
          if (used < 1000) { printf " (%dM)", used }
          else if (used < 1024) { printf "1G" }
          else { printf " (%.2gG)", used / 1024 }
        }
        exit
      }
    ' /proc/meminfo
  `
  MEMORY+='  '

  DATETIME=`date +'%Y-%m-%d %H:%M'`

  echo "$MUSIC$BATTERY$CPU$MEMORY$DATETIME "

  sleep 7
done
