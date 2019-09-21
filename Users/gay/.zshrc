[[ -f /etc/.profile ]] && source /etc/.profile

export MAVEN_OPTS="-Xmx1g"

export PATH="\
"~"/projects/scripts:\
"~"/Library/Android/sdk/platform-tools:\
"~"/.local/bin:\
$PATH"

alias m=memo
alias sf=screenfetch
alias nc=ncmpcpp
alias yta="youtube-dl -f bestaudio[ext=m4a]"
alias ytv="youtube-dl -f bestvideo+bestaudio"
alias docker-tty="screen ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/tty"

alias nc-ext="ncmpcpp -c /Users/gay/.ncmpcpp/config-ext"
mpd-ext() {
  mpd ~/.mpd/mpd-ext.conf
  mpdscribble --port 6601 --pidfile ~/.mpdscribble/pid-ext
  mpdkeys --port 6601 &
  disown
}

alias todo="vim ~/Documents/_misc/todo"
alias notes="vim ~/Documents/_misc/notes"

_find-files() {
  find $1 -name ".git*" -prune -o -type f -print | sed -E "s|^$1/||" | sort
}

compare-dirs() {
  my-sdiff <(_find-files $1) <(_find-files $2)
}

eval "$(jenv init -)"

remind() {
  if [[ ! $DEEPVOICE ]]; then
    echo "Define DEEPVOICE env variable with path to deepvoice3_pytorch"
    return 1
  fi

  if (( ! $# )); then
    echo "Usage: $0 5[smh] <of_what>"
    return 1
  fi

  local stime
  if [[ ${1[-1]} =~ "[0-9s]" ]]; then
    stime=${1%s}
  elif [[ ${1[-1]} = m ]]; then
    stime=`bc <<< "${1%m} * 60"`
  elif [[ ${1[-1]} = h ]]; then
    stime=`bc <<< "${1%h} * 60 * 60"`
  else
    echo "What is this '$1'? Only seconds, minutes & hours supported."
    return 1
  fi

  local what=$2
  if [[ ! $what ]]; then
    [[ -t 0 ]] && echo "Type a reminder and press [Ctrl+D] on a newline..."
    what=`cat -`
  fi

  local tmp=/tmp/remind-`whoami`-`date +%s`
  rm -rf $tmp
  mkdir $tmp
  echo $what > $tmp/text
  local params="preset=deepvoice3_vctk,builder=deepvoice3_multispeaker"
  if ! ( cd $DEEPVOICE; python3 synthesis.py --hparams=$params --speaker_id=5 \
    checkpoint.pth $tmp/text $tmp > /dev/null )
  then
    return 1
  fi
  echo "OK!"

  _reminder $stime $tmp > /dev/null 2>&1 &
  disown
}

_reminder() {
  local tmp=$2

  sleep $1

  mpc volume 5
  local vol=`osascript -e "get Volume settings" \
    | sed 's/.*output volume:([0-9]+).*/\1/'`
  vol=`bc -l <<< "scale=1; $vol / 14"`
  sleep 0.5
  osascript -e "set Volume `bc <<< "$vol + 1"`"
  mpc volume 1
  for a in $tmp/*.wav; do
    ffplay -nodisp -autoexit -hide_banner $a
    sleep 0.25
  done
  osascript -e "set Volume $vol"
  mpc volume 5
  sleep 0.5
  mpc volume 100

  rm -rf $tmp
}

[ -f ~/work/_issues/source-me.sh ] \
&& source ~/work/_issues/source-me.sh

export MY_DOCS=~/Documents
d() {
  local str=$MY_DOCS
  for i in $@; do str+=/**/*$i*; done

  local _ifs=$IFS
  IFS=$'\n'
  local files=($(eval "ls $str 2> /dev/null"))
  IFS=$_ifs

  if (( $#files > 1 )); then
    echo "Which one?"
    for f in $files; do echo $f; done
    return 1
  elif (( !$#files )); then
    echo "No such document!"
    return 1
  fi

  if [[ $files =~ \\.(pdf|doc|xls|jpe?g)$ ]]; then
    open $files &
    disown
  else
    vim $files
  fi
}
ds() { ls $MY_DOCS | sed s/.pdf//; }

export MY_SCRIPTS=~/work/.scripts
export PATH=$MY_SCRIPTS:$PATH
ss() { vim $MY_SCRIPTS/$1-source.sh; }

if [[ -d $MY_SCRIPTS ]]; then
  for s in $(ls $MY_SCRIPTS/*-source.sh); do
    source $s
  done
fi

post-json() { curl -k -X POST -H "Content-Type: application/json" -d $2 $1; }

# JIRA

j() { jira show $* | \less -iXFR; }
js() { jira list | less; }
alias jw="jira work"
