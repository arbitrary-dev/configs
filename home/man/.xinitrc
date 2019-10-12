xrdb ~/.Xresources

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto

urxvtd --quiet --opendisplay --fork

eval `luarocks path --bin`

# ~/.config/compton.conf
compton --daemon

exec awesome
