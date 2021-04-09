NPM_PACKAGES="$HOME/.npm-packages"

export PS1='%B%F{green}'$PS1
export PATH="\
/opt/sbt-1.4.5/bin:\
$HOME/projects/scripts:\
$HOME/.local/bin:\
$NPM_PACKAGES/bin:\
$PATH"

export MANPATH="\
$MANPATH:\
$NPM_PACKAGES/share/man:\
"

export PATH=$PATH:~/.jenv/bin
eval "$(jenv init -)"

export MY_DOCS=~/docs
alias todo="$EDITOR $MY_DOCS/_misc/todo"
alias notes="$EDITOR $MY_DOCS/_misc/notes"

alias -s txt="$EDITOR"
alias -s md="$EDITOR"
alias -s scala="$EDITOR"
alias -s hs="$EDITOR"
alias -s js="$EDITOR"
alias -s ts="$EDITOR"
alias -s yaml="$EDITOR"
alias -s cpp="$EDITOR"

alias -s mkv=mpv
alias -s mp4=mpv
alias -s avi=mpv
alias -s webm=mpv

alias -s pdf=mupdf-x11
alias -s html=xdg-open

alias -s jpg=feh
alias -s JPG=feh
alias -s jpeg=feh
alias -s png=feh

alias hanako-fm="mpv https://musicbird.leanstream.co/JCB069-MP3"

alias yt=youtube-dl
alias yta="youtube-dl -f bestaudio[ext=m4a]"
alias ytv="youtube-dl -f bestvideo+bestaudio"
alias ytf="youtube-dl --list-formats"

yt-proxified() {
  local proxies=(`
    curl -s https://raw.githubusercontent.com/clarketm/proxy-list/master/proxy-list.txt \
    | grep RU \
    | sed -E -e 's/([^ ]+) [^S]*(S?).*/\2\1/' -e 's_^S_https://_'
  `)
  while true; do
    local p="${proxies[`shuf -i1-${#proxies} -n1`]}"
    echo -n "\nTrying with $p...\n"
    yt -f 243+249 --proxy "$p" https://www.youtube.com/watch?v=$1 \
    && break
  done
}

yts() {
  echo $@ \
  | xs -d\  youtube-dl -f 243+139 https://www.youtube.com/watch?v={}
}

alias m=memo
alias me="memo --edit"
alias sf=screenfetch
alias xb=xbacklight
alias bat="upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep 'time to' | sed -Ee 's/  +/ /g' -e 's/^ //'"
alias feh="feh --auto-rotate --image-bg black -Z -."
alias lp-a4="lp -o fit-to-page -o PageSize=A4 -o PageRegion=A4 -o PaperDimension=A4 -o ImageableArea=A4"
alias ag-todos="ag '(((//|/?\*|#) )|\*\*|)\b(TODO|FIXME)\b(?!(:|.*INT-\d)).*$'"
alias top="top -o %CPU"
alias shtd="echo 'Shutdown enqueued...'; sudo shutdown -h"

alias ssha='eval "`ssh-agent -s`"'
alias sshk='ssh-agent -k'

vi() {
  if (( $# == 1 )); then
    arr=(${(s/:/)@})
    vim +${arr[-1]} -u /etc/vim/vimrc "${arr[1,-2]}"
  else
    vim -u /etc/vim/vimrc "$@"
  fi
}

gen-passw() {
  strings /dev/urandom \
  | grep -oE '[a-zA-Z0-9.,/\'\''"]' \
  | head -${1:-32} \
  | tr -d '\n'
  echo
}

alias rsx="redshift -x"
rs() { redshift -PO ${1}00; }

calc-music-checksums() {
  cksfv -c *.{flac,m4a,mp3} | grep -v '^;' | tee checksums.sfv
}

get-host-certificate() {
  local host=$1
  local port=${2:-443}
  openssl s_client -servername $host -connect $host:$port \
  < /dev/null 2> /dev/null \
  | sed -n '/BEGIN/,/END/p'
}

_join() {
  local IFS="$1"
  shift
  echo "$*"
}

ls-files() {
  local joined="`_join '|' $*`"
  find $* -type f | sed -E "s!($joined)/!!" | sort
}

alias wine32="WINEARCH=win32 WINEPREFIX=~/.wine32 wine"
alias winecfg32="WINEARCH=win32 WINEPREFIX=~/.wine32 winecfg"
alias winetricks32="WINEARCH=win32 WINEPREFIX=~/.wine32 winetricks"

alias am=alsamixer
alias am-bt="alsamixer -D bluealsa"

weather() {
  local data="{
    time: (.time | tonumber / 100),
    chanceofrain,
    humidity,
    precipMM,
    tempC,
    uvIndex,
    wind: (.winddir16Point + \", \" + .windspeedKmph + \" Kmph\"),
    desc: (.weatherDesc | map(.value) | join(\"; \"))
  }"
  curl -s wttr.in?format=j1 \
  | jq "[
    (.current_condition[0] |{
      localObsDateTime,
      humidity,
      precipMM,
      temp_C,
      uvIndex,
      wind: (.winddir16Point + \", \" + .windspeedKmph + \" Kmph\"),
      desc: (.weatherDesc | map(.value) | join(\"; \"))
    }),
    (.weather[0] | {
      date: .date,
      hourly: .hourly
        | map(select((.time | tonumber / 100) >= (`date +%_H` / 3 | floor) * 3 ))
        | map($data)
    }),
    (.weather[1] | {
      date: .date,
      hourly: .hourly | map($data)
    })
  ]"
}

alias btc=bluetoothctl
alias btd="btc disconnect"

btv() {
  # Sets BT volume to 75%
  # TODO use udev rule unstead
  if amixer -D bluealsa >/dev/null; then
    local ctl=`amixer -D bluealsa scontrols | grep -i a2dp | cut -d\' -f2`
    amixer -D bluealsa set $ctl 75% > /dev/null
  fi
}

bt() {
  local devs=`sed -En -e 's/^pcm\.(.+) .*/\1/p' -e 's/.*device "(.+)"/\1/p' ~/.asoundrc`
  local target=${1:+`echo $devs | grep -A1 "$1" | tail -1`}
  if [[ -z "$target" ]]; then
    local curr=`btc info | sed -En 's/Device (.+) .*/\1/p'`
    if [[ -n "$curr" ]]; then
      >&2 printf "Device connected: "
      echo $devs | grep -B1 "$curr" | head -1
      return 0
    else
      >&2 echo "Possible devices:"
      >&2 (echo $devs | grep --invert-match ":" | xs echo - {})
      return 1
    fi
  fi
  local name=${1:+`echo $devs | grep "$1"`}
  if btc show >/dev/null; then
    btc connect "$target" && btv
  else
    >&2 echo "No bluetooth controller available!"
    >&2 echo "Will try to unblock bluetooth..."
    sudo rfkill unblock bluetooth
    for i in {1..5}; do
      sleep 2
      >&2 echo "#$i attempt to connect '$name'..."
      if btc connect "$target"; then
        btv
        >&2 echo $name
        return 0
      fi
    done
    >&2 echo "Unable to connect '$name'!"

    if tty -s; then
      read -k "a?Try rebinding/rescanning pci device for bluetooth? "
      echo
      [[ "$a" != y ]] && return 1
      su -c '
        dev=(/sys/bus/pci/drivers/?hci_hcd/0000:00:*)
        echo ${dev##*/} > ${dev%/*}/unbind
        sleep 1
        echo ${dev##*/} > ${dev%/*}/bind
        sleep 1
        echo 1 > $dev/rescan
      '
      echo 'Done, try again!'
    fi

    return 1
  fi
}

nc() {
  pgrep mpd >/dev/null || mpd
  ncmpcpp
}
mpdr() {
  mpd --kill 2> /dev/null
  mpd /etc/mpd-remote.conf
}
ncr() {
  pgrep mpd >/dev/null || mpdr
  nc -c ~/.ncmpcpp/config-remote
}

discogs() {
  local s="$@"
  w3m https://www.discogs.com/search?q=${s// /+}
}

yt2cue() {
  # RS="\r\n"
  # match($0, "([0-9:]+) *\\( *(.+) *\\) *(.+) *", arr)
  gawk 'BEGIN{num=1}
  match($0, "([0-9:]+) *- *(.+) *", arr) {
    split(arr[1],time,":")
    time[1]=time[1]*60+time[2]
    time[2]=time[3]

    artist = "Johann Sebastian Bach" # arr[2]
    title = arr[2]

    printf "TRACK %02d AUDIO\n", num
    printf "  TITLE \"%s, %s\"\n", prefix, title
    printf "  PERFORMER \"%s\"\n", artist
    printf "  INDEX 01 %02d:%02d:00\n\n", time[1], time[2]
    num+=1
    next
  }
  {
    gsub(/^ +| +$/, "", $0)
    ! /^\[/ && prefix=$0
    next
  }'
}

mnt() {
  local dev=$1

  if [[ ! "$dev" ]]; then
    local ds=(`ls /dev/sd?? 2>/dev/null`)
    if (( ! ${#ds} )); then
      echo "No devices available!"
      return 1
    elif (( ${#ds} == 1 )); then
      dev=${ds[1]}
    else
      sudo lsblk -lo path,label -e 259
      echo
      read "dev?Which one? "
      echo
    fi
  fi

  local devs
  if [[ -e "/dev/$dev" ]]; then
    devs=("/dev/$dev")
  elif [[ "$dev" = /dev/* && -e "$dev" ]]; then
    devs=("$dev")
  else
    devs=(`sudo lsblk -lo path,label -e 259 | grep $dev | cut -d\  -f1`)
  fi

  if [[ -z "$devs" ]]; then
    echo "There's no \"$dev\" available!"
    return 1
  fi

  if (( $#devs == 1 )) && [[ "$devs" =~ '^/dev/sd[a-z]$' ]] && ls "$devs"* | grep -q '[0-9]$'; then
    devs=(`ls "$devs"* | grep '[0-9]$'`)
  fi
  local one=`(( ${#devs[@]} == 1 )) && echo 1`

  for dev in "${devs[@]}"; do
    local label=""
    [[ "$one" && "$2" ]] && label="$2"
    [[ -z "$label" ]] && label="`sudo lsblk -no label $dev`"
    [[ -z "$label" ]] && label="`sudo lsblk -no name $dev`"
    local to="/mnt/$label"
    local i=1
    while { mount | grep -q "$to" } {
      i=$(($i + 1))
      to=$to$i
    }
    sudo mkdir -p "$to"
    if grep -q "\s$to\s" /etc/fstab && sudo mount "$to" \
        || sudo mount -o umask=000 "$dev" "$to" 2>/dev/null \
        || (sudo mount "$dev" "$to" && sudo chown $USER:$USER "$to"); then
      echo "\"$dev\" is mounted to \"$to\""
      [[ $one ]] && pushd "$to"
    fi
  done
}

umnt() {
  local from=$1
  if [ -z "$from" ]; then
    for m in `mount | grep /mnt | cut -d\  -f3`; do
      [[ "$PWD" = "$m"* ]] && from="$m" && break
    done
    if [ -z "$from" ]; then
      echo "No mount point were specified!"
      return 1
    fi
  fi
  [[ "$from" != /mnt/* ]] && from="/mnt/$from"
  mount | grep -q "$from" && [[ "$PWD" = "$from"* ]] && cd ~
  local dev=`mount | grep $from | cut -d\  -f1 | sed 's/[0-9]\+$//'`
  sync
  sudo sh -c "umount '$from' && rm -d '$from' && echo '$from unmounted'"
  if (( ! `mount | grep -c $dev` )) && whence -p eject-device >/dev/null; then
    read -k "a?No more mounts for $dev, eject it? "
    echo
    [[ "$a" != y ]] && return
    eject-device $dev
  fi
}

# Phone

mnt-phone() {
  mkdir -p $TMPDIR/mtp
  mtpfs $TMPDIR/mtp
}
umnt-phone() {
  fusermount -u $TMPDIR/mtp
  rm -d $TMPDIR/mtp
}

# Work

alias docker-start="sudo rc-service docker start"
alias docker-stop="sudo rc-service docker stop"

sbt-ta() {
  sbt -Dsbt.supershell=false -Dsbt.color=true \
    testAll \
    2>/dev/null \
  | \sed -En '/\[.*(info|error).*\]/p'
}

sbtv-to() {
  sbt "$1 / Test / testOnly ${2:+*$2*} ${3:+-- -z \"$3\"}"
}

sbt-to() {
  sbt -Dsbt.supershell=false -Dsbt.color=true \
    "$1 / Test / testOnly ${2:+*$2*} ${3:+-- -z \"$3\"}" \
    2>/dev/null \
  | \sed -En '/\[.*(info|error).*\]/p'
}

sbt-it() {
  sbt -Dsbt.supershell=false -Dsbt.color=true it:test 2>/dev/null \
  | \sed -En '/\[.*(info|error).*\]/p'
}

sbt-ito() {
  sbt -Dsbt.supershell=false -Dsbt.color=true \
  "$1 / IntegrationTest / testOnly ${2:+*$2*} ${3:+-- -z \"$3\"}" \
  2>/dev/null \
  | \sed -En '/\[.*(info|error).*\]/p'
}

sbtv-ito() {
  sbt "$1 / IntegrationTest / testOnly ${2:+*$2*} ${3:+-- -z \"$3\"}"
}

jnote() {
  docker run -v "$PWD":/home/jovyan/work -p 8888:8888 jupyter/scipy-notebook
}

setup-ssh-terminal() {
  ssh $1 mkdir -p .terminfo/r
  scp /usr/share/terminfo/r/rxvt-unicode-256color $1:.terminfo/r
}

source ~/work/_issues/source-me.sh

export MY_SCRIPTS=~/work/_scripts
export PATH=$PATH:$MY_SCRIPTS
ss() { vim $MY_SCRIPTS/${1:-misc}-source.sh; }

if [[ -d $MY_SCRIPTS ]]; then
  for s in $(ls $MY_SCRIPTS/*-source.sh); do
    source $s
  done
fi

# Scala Metals

_check-tmpdir() {
  if [[ ! -w "$TMPDIR" ]]; then
    echo "No writable TMPDIR specified!"
    return 1
  fi
}

_push-metals-tmpfs() {
  _check-tmpdir || return 1
  local project=`basename $PWD`
  local target="$TMPDIR/.bloop/$project"
  [[ -d "$target" ]] && echo "$target already exists" && return 0
  mkdir -p "$TMPDIR/.bloop"
  if [[ -d .bloop ]]; then
    mv .bloop $target \
    || return 1
  else
    mkdir $target
  fi
  ln -s $target .bloop \
  && echo "Pushed to $target"
}

_pop-metals-tmpfs() {
  _check-tmpdir || return 1
  local project=`basename $PWD`
  local target="$TMPDIR/.bloop/$project"
  [[ ! -d "$target" ]] && echo "Nothing to pop at $target" && return 1
  rm .bloop \
  && mv $target .bloop \
  && echo "Popped from $target"
}

metals() {
  local file=${1:-build.sbt}
  if [[ -n "$1" && ! -f "${file%:*}" ]]; then
    file=(**/"$1".scala)
  fi
  if [ -f "${file%:*}" ]; then
    if _push-metals-tmpfs; then
      if vim "$file"; then
        sleep 1
        _pop-metals-tmpfs
      fi
    fi
  else
    echo "Unable to find: $file"
  fi
}

smb-start() {
  mkdir -p $TMPDIR/samba
  sudo chown nobody $TMPDIR/samba
  sudo chmod g+w $TMPDIR/samba
  sudo rc-service samba start
}

smb-stop() {
  sudo rc-service samba stop
}

rec-screen() {
  local adev=`pactl list short sources | grep -Eo '\b\S+\.monitor\b' | tail -1`
  echo $adev

  pactl set-source-mute $adev false
  echo "Source unmuted."
  pactl set-source-volume $adev 100%
  echo "Volume set to 100%."

  xset s off -dpms
  echo "Screen saver turned off."

  # TODO utilize xrectsel
  ffmpeg -y -f x11grab -draw_mouse 0 -show_region 1 -video_size 800x600 \
    -framerate 25 -i :0.0+1000,400 \
    -f pulse -i $adev -ac 1 \
    $TMPDIR/output.mkv

  xset s on +dpms
  echo "Screen saver turned on."
}
