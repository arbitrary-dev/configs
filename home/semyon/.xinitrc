#!/bin/sh

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
urxvtd --quiet --opendisplay --fork
xset +fp ~/.fonts
exec awesome
