#!/bin/sh

if [ "$1" == "pre" ]; then
  sudo -u dolf sh -c 'XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1 swaylock'
fi
