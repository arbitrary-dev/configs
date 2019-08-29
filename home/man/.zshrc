export PS1='%B%F{green}'$PS1

# Autostart X on login
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then exec startx; fi
