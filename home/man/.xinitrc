xrdb ~/.Xresources
urxvtd --quiet --opendisplay --fork
exec ck-launch-session dbus-launch --sh-syntax --exit-with-session awesome
