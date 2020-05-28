#!/bin/sh

event=$1

max=`cat /sys/class/backlight/intel_backlight/max_brightness`
cur=`cat /sys/class/backlight/intel_backlight/brightness`
lvl=`bc -l <<< "a=2*l($cur)+0.5;scale=0;a/1"`

[[ $event = video/brightnessup ]] && inc=1 || inc=-1

lvl=$(( $lvl + $inc ))
lvl=$(( $lvl < 5 ? $(( $inc > 0 ? 5 : 0 )) : $lvl ))

new=`bc -l <<< "a=e($lvl/2)+0.5;scale=0;a/1"`
new=$(( $new > $max ? $max : $new ))

#echo $lvl $new >> /tmp/brightness.log
echo -n $new > /sys/class/backlight/intel_backlight/brightness
