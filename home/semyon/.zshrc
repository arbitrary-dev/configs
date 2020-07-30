export PATH="${PATH}:/home/semyon/scripts"
export PS1=$'%{\e[0;30m\e[42m%} %1d %{\e[0m\e[0;32m%}%{\e[0m%} '

# To reset any issues with broken newline
stty sane

stty -ixon

[[ $(tty) = "/dev/tty1" ]] && exec startx

# aliases

alias -s ly=$EDITOR

alias am=alsamixer
alias qmarks="vim ~/.config/qutebrowser/quickmarks"
alias vd=vimdiff
alias yta="youtube-dl -f 'bestaudio[ext=m4a]'"
alias feh="feh --auto-rotate --geometry 640x480"

alias mnt-phone="go-mtpfs /mnt/phone &"
alias mnt-usb="mount /mnt/usb"

nc() {
  mpd 2>/dev/null && mpdscribble
  ncmpcpp
}

bat() {
  local bat=/org/freedesktop/UPower/devices/battery_BAT1
  if [[ "$1" = -a ]]; then
    upower -i $bat
  else
    upower -i $bat \
    | sed -En '/state|time to/{s/.*: +(.+)/\1/p}'
  fi
}

export MY_DOCS=/home/semyon/docs

doc() { vim $MY_DOCS/$1; }

join_by() { local IFS="$1"; shift; echo "$*"; }

todo() {
	local t=$(join_by - $0 $*)
  doc _misc/"$t"
}

alias notes="doc _misc/notes"

bt() {
  if (( ! $# )); then
    echo "Choose device to connect to:"
    bluetoothctl <<< devices | grep Device | cut -d\  -f3-
    return
  fi

  # Connect
  local dev=`bluetoothctl <<< devices | grep -i "device.*$1" | cut -d\  -f2-`
  dev=(${(s/ /)dev})
  echo "Connecting to ${dev[@]:1}..."
  (cat <<EOF && sleep 2) | bluetoothctl
power on
connect ${dev[1]}
EOF

  # Set volume
  local ctl=`amixer -D bluealsa scontrols | cut -d\' -f2 | head -1`
  amixer -D bluealsa sset $ctl 75%
}

gnumeric-txt() {
  ssconvert \
    -T Gnumeric_stf:stf_assistant \
    -O "separator='	' format=preserve" \
    $1 fd://1
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
  sudo sh -c "umount '$from' && rm -d '$from' && echo '$from unmounted'"
  if (( ! `mount | grep -c $dev` )) && whence -p eject-device >/dev/null; then
    read -k "a?No more mounts for $dev, eject it? "
    echo
    [[ "$a" != y ]] && return
    eject-device $dev
  fi
}
