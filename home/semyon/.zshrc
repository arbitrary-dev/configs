export PATH="${PATH}:/home/semyon/scripts"
export PS1=$'%{\e[0;30m\e[42m%} %1d %{\e[0m\e[0;32m%}%{\e[0m%} '

# To reset any issues with broken newline
stty sane

stty -ixon

[[ $(tty) = "/dev/tty1" ]] && exec startx

# aliases

alias qmarks="vim ~/.config/qutebrowser/quickmarks"
alias vd=vimdiff
alias yta="youtube-dl -f 'bestaudio[ext=m4a]'"

alias mnt-phone="go-mtpfs /mnt/phone &"
alias mnt-usb="mount /mnt/usb"

nc() {
  mpd 2>/dev/null && mpdscribble
  ncmpcpp
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

#PATH="/home/semyon/perl5/bin${PATH:+:${PATH}}"; export PATH;
#PERL5LIB="/home/semyon/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
#PERL_LOCAL_LIB_ROOT="/home/semyon/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
#PERL_MB_OPT="--install_base \"/home/semyon/perl5\""; export PERL_MB_OPT;
#PERL_MM_OPT="INSTALL_BASE=/home/semyon/perl5"; export PERL_MM_OPT;
