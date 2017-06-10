export PATH="${PATH}:~/scripts"
export PS1=$'%{\e[0;30m\e[42m%} %n %{\e[0m\e[0;32m%} %1d %{\e[0m%}'

stty -ixon
[[ $(tty) = "/dev/tty1" ]] && exec startx

# aliases

alias mp="mpd && mpdscribble"
alias nc=ncmpcpp
alias todo="vim ~/todo"
alias qmarks="vim ~/.config/qutebrowser/quickmarks"
alias vd=vimdiff

#PATH="/home/semyon/perl5/bin${PATH:+:${PATH}}"; export PATH;
#PERL5LIB="/home/semyon/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
#PERL_LOCAL_LIB_ROOT="/home/semyon/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
#PERL_MB_OPT="--install_base \"/home/semyon/perl5\""; export PERL_MB_OPT;
#PERL_MM_OPT="INSTALL_BASE=/home/semyon/perl5"; export PERL_MM_OPT;
