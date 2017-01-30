[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
ibus-daemon -drx

exec dbus-launch --sh-syntax --exit-with-session openbox-session
