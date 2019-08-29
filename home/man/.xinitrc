xrdb ~/.Xresources
urxvtd --quiet --opendisplay --fork
eval `luarocks path --bin`
exec ck-launch-session dbus-launch --sh-syntax --exit-with-session awesome
