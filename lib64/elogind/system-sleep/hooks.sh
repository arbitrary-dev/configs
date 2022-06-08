#!/bin/sh

if [ "$1" == "pre" ]; then
  pgrep swaylock >/dev/null \
  || sudo -u dolf sh -c 'XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1 swaylock'
  # Add some delay to avoid double suspend in Sway.
  sleep 2
fi
