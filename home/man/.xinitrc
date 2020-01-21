[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto

urxvtd --quiet --opendisplay --fork

eval `luarocks path --bin`

# ~/.config/compton.conf
compton --daemon

export GTK_IM_MODULE=xim
export QT_IM_MODULE=xim
export XMODIFIERS=@im=ibus
ibus-daemon -drx

# Decreases touchpad sensitivity (was 30)
synclient FingerHigh=52

exec awesome
