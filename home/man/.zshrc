export PS1='%B%F{green}'$PS1
export PATH="\
"~"/projects/scripts:\
"~"/.local/bin:\
$PATH"

export MY_DOCS=~/docs

alias vr="vim ~/.zshrc"

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

  local devs=(`ls "$main_dev"* | grep -E '[0-9]$'`)
  local one=`(( $#devs == 1 )) && echo 1`

  for dev in "${devs[@]}"; do
    local label=""
    [[ $one && "$2" ]] && label="$2"
    [[ -z "$label" ]] && label="`sudo lsblk -no label $dev`"
    [[ -z "$label" ]] && label="`sudo lsblk -no name $dev`"
    local to="/mnt/$label"
    sudo mkdir -p "$to"
    if sudo mount -o umask=000 "$dev" "$to"; then
      [[ $one ]] && cd "$to" || echo "\"$dev\" mounted to \"$to\""
    fi
  done
}

umnt() {
  # TODO get from PWD
  [[ ! "$1" ]] && echo "Specify a mount point from /mnt !" && return 1
  local from="/mnt/$1"
  mount | grep -q "$from" && [[ "$PWD" = "$from"* ]] && cd ~
  sudo umount "$from" && sudo rm -d "$from"
}

export PATH=$PATH:~/.jenv/bin
eval "$(jenv init -)"

alias yta="youtube-dl -f bestaudio[ext=m4a]"
alias ytv="youtube-dl -f bestvideo+bestaudio"

alias m=memo
alias bat="upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep 'time to' | sed -Ee 's/  +/ /g' -e 's/^ //'"

# Phone

alias mount-phone="go-mtpfs /mnt/phone &"
alias umount-phone="fusermount -u /mnt/phone"

# Work

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
