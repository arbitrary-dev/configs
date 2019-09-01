xrdb ~/.Xresources
urxvtd --quiet --opendisplay --fork
eval `luarocks path --bin`
exec awesome
