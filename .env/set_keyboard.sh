#!/usr/bin/env bash

## Due to electromagnetic interference, badly shielded USB cables (this is
##  especially true for extension cords) may cause input devices to be
##  re-enabled, so it’s handy to have this script mentioned in i3 config
##  among those things to be done at reloading configuration.

[ -e ~/.env/xkbcomp.$HOSTNAME.xkm ] \
	&& xkbcomp_map="$HOME/.env/xkbcomp.$HOSTNAME.xkm" \
	|| xkbcomp_map="$HOME/.env/xkbcomp.xkm"  # generic
xkbcomp $xkbcomp_map $DISPLAY

## Setting NumLock
numlockx off
numlockx on
# Keyboard auto-repeat on
# NB "xset r on" doesn’t work.
xset r
## Start kbdd to keep diferent layouts for each window
kbdd
## Make all keys sticky
#xkbset sticky -twokey -latchlock

# I don’t map z x c v b becasue can press them accidentally.
# Decrease brush size
touch='Wacom Bamboo 2FG 6x8 Finger touch'
pad='Wacom Bamboo 2FG 6x8 Pad pad'
# Undo
xsetwacom --set "$pad" Button 3 'key z'
# Reset canvas rotation
xsetwacom --set "$pad" Button 8 'key +shift 1 -shift'
# Swap colors
xsetwacom --set "$pad" Button 9 'key f13'
# Default colours
xsetwacom --set "$pad" Button 1 'key f14'
# Disable touch
xsetwacom --set "$touch" Touch off

# Stylus buttons work as middle and right mouse buttons,
# I’m not sure how to catch the via xev.

 # Reset mouse acceleration/threshold
#  Should be
#  $ xset q | grep accel
#  acceleration:  2/1    threshold:  4
#
xset m default