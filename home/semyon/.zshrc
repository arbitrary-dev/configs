export PATH="${PATH}:~/scripts"
export PS1=$'%{\e[0;30m\e[42m%} %n %{\e[0m\e[0;32m%} %1d %{\e[0m%}'

stty -ixon
[[ $(tty) = "/dev/tty1" ]] && exec startx

# aliases

alias todo="vim ~/todo"
alias vd=vimdiff
