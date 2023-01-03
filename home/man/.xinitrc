[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto

urxvtd --quiet --opendisplay --fork

# ~/.config/picom.conf
picom --daemon

export GTK_IM_MODULE=xim
export QT_IM_MODULE=xim
export XMODIFIERS=@im=ibus
ibus-daemon -drx

# Decreases touchpad sensitivity (was 30)
synclient FingerHigh=52

# See: ~/.xbindkeysrc
xbindkeys

# it's not strictly required in terms of audio
# handling. It may be required in future for the non-audio usecases
# described above.
#
# For non-audio purposes, PipeWire is installed in many configurations as more
# and more software depends on it for e.g. screensharing, sandboxing,
# and window previews, so users will need to act based on their preferred
# setup rather than simply avoiding installing PipeWire, as it is
# increasingly required as a dependency.
#
#gentoo-pipewire-launcher &

exec dbus-launch --autolaunch=$(cat /var/lib/dbus/machine-id) awesome
