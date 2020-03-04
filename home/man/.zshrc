export PS1='%B%F{green}'$PS1
export PATH="\
"~"/projects/scripts:\
"~"/.local/bin:\
$PATH"

export PATH=$PATH:~/.jenv/bin
eval "$(jenv init -)"

export MY_DOCS=~/docs
alias todo="$EDITOR $MY_DOCS/_misc/todo"
alias notes="$EDITOR $MY_DOCS/_misc/notes"

alias vr="vim ~/.zshrc"

alias -s md="$EDITOR"
alias -s mkv=mpv
alias -s mp4=mpv
alias -s avi=mpv
alias -s pdf=mupdf-x11
alias -s jpg=feh
alias -s jpeg=feh
alias -s png=feh

alias yta="youtube-dl -f bestaudio[ext=m4a]"
alias ytv="youtube-dl -f bestvideo+bestaudio"

alias m=memo
alias sf=screenfetch
alias xb=xbacklight
alias bat="upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep 'time to' | sed -Ee 's/  +/ /g' -e 's/^ //'"
alias feh="feh --auto-rotate --image-bg black -Z -."
alias stack=stack-bin

alias am=alsamixer
alias am-bt="alsamixer -D bluealsa"
alias bt=bluetoothctl
alias nc=ncmpcpp
alias mpd-remote="sudo CFGFILE=/etc/mpd-remote.conf rc-service mpd restart"
alias mpd-restart="sudo rc-service mpd restart"
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
  if [[ ! "$1" ]]; then
    sudo lsblk -lo path,label -e 259
    return 1
  fi

  local main_dev
  if [[ -e "/dev/$1" ]]; then
    main_dev="/dev/$1"
  elif [[ "$1" = /dev/* && -e "$1" ]]; then
    main_dev="$1"
  else
    main_dev=`sudo lsblk -lo path,label -e 259 | grep "$1" | cut -d\  -f1`
  fi
  if [[ -z "$main_dev" ]]; then
    echo "There's no \"$1\" available!"
    return 1
  fi

  local devs=("$main_dev")
  if [[ ! "$devs" =~ '[0-9]$' ]] && ls "$devs"* | grep -q '[0-9]$'; then
    devs=(`ls "$devs"* | grep '[0-9]$'`)
  fi
  local one=`(( $#devs == 1 )) && echo 1`

  for dev in "${devs[@]}"; do
    local label=""
    [[ $one && "$2" ]] && label="$2"
    [[ -z "$label" ]] && label="`sudo lsblk -no label $dev`"
    [[ -z "$label" ]] && label="`sudo lsblk -no name $dev`"
    local to="/mnt/$label"
    sudo mkdir -p "$to"
    if grep -q "\s$to\s" /etc/fstab && sudo mount "$to" \
        || sudo mount -o umask=000 "$dev" "$to" 2>/dev/null \
        || (sudo mount "$dev" "$to" && sudo chown $USER:$USER "$to"); then
      echo "\"$dev\" is mounted to \"$to\""
      [[ $one ]] && cd "$to"
    fi
  done
}

umnt() {
  local from="$1"
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
  local dev=`mount | grep /mnt | cut -d\  -f1 | sed 's/[0-9]\+$//'`
  sudo sh -c "umount '$from' && rm -d '$from' && echo '$from unmounted'"
  if (( ! `mount | grep -c $dev` )) && whence -p eject-device >/dev/null; then
    read -k1 -s "a?No more mounts for $dev, eject it? "
    echo
    [[ "$a" != y ]] && return
    eject-device $dev
  fi
}

# Phone

mnt-phone() {
  sudo mkdir -p /mnt/phone
  sudo chown $USER:$USER /mnt/phone
  go-mtpfs /mnt/phone &
}
umnt-phone() {
  fusermount -u /mnt/phone
  sudo rm -r /mnt/phone
}

# Work

alias docker-start="sudo rc-service docker start"
alias docker-stop="sudo rc-service docker stop"

esc=$(print '\033')

sbt-t() {
  sbt testAll \
  | \grep -E "${esc}\[32m|${esc}\[31m"
}

sbt-to() {
  sbt -Dsbt.supershell=false "$1 / Test / testOnly *$2*"
}

sbt-it() {
  sbt it:test \
  | \grep -E "${esc}\[32m|${esc}\[31m"
}

sbt-ito() {
  sbt "it:testOnly *$1* ${2:+-- -z \"$2\"}" \
  | \grep -E "${esc}\[32m|${esc}\[31m"
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

# JIRA

j() { jira show $* | \less -iXFR; }
jh() { jira show $1 -f "%id %summary"; }
js() { jira list | less; }
alias jw="jira work"

# Scala Metals

build-metals() {
  local version="$1"
  if [ -z "$version" ]; then
    echo -e "No version specified!\nTry: https://scalameta.org/metals/docs/editors/vim.html#generating-metals-binary"
    return 1
  fi
  read -k1 -s "a?Build metals-vim v$version (previous will be removed)? "
  echo
  [[ "$a" != y ]] && return 1
  rm -f ~/.local/bin/metals-vim*
  coursier bootstrap \
    --java-opt -Xss4m \
    --java-opt -Xms100m \
    --java-opt -Dmetals.client=coc.nvim \
    org.scalameta:metals_2.12:$version \
    -r bintray:scalacenter/releases \
    -r sonatype:snapshots \
    -o ~/.local/bin/metals-vim-$version -f \
  && ln -s ~/.local/bin/metals-vim{-$version,}
}

check-tmpdir() {
  if [[ ! -w "$TMPDIR" ]]; then
    echo "No writable TMPDIR specified!"
    return 1
  fi
}

push-metals-tmpfs() {
  check-tmpdir || return 1
  local project=`basename $PWD`
  local target="$TMPDIR/.bloop/$project"
  [[ ! -d "$target" ]] && mkdir -p $target
  ls .bloop/*.json >/dev/null 2>&1 && cp .bloop/*.json $target/
  rm -rf .bloop
  ln -s $target .bloop
  sbt clean
  echo "Pushed to $target"
}

pop-metals-tmpfs() {
  check-tmpdir || return 1
  local project=`basename $PWD`
  local target="$TMPDIR/.bloop/$project"
  [[ ! -d "$target" ]] && echo "Nothing to pop at $target" && return 1
  rm -f .bloop
  mkdir .bloop
  cp $target/*.json .bloop/
  rm -rf $target
  echo "Popped from $target"
}
