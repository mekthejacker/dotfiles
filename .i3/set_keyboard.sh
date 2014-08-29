#!/usr/bin/env bash

## Due to electromagnetic interference, badly shielded USB cables (this is
##  especially true for extension cords) may cause input devices to be
##  re-enabled, so it’s handy to have this script mentioned in i3 config
##  among those things to be done at reloading configuration.
xkbcomp ~/.env/xkbcomp.xkb $DISPLAY
## Setting NumLock
numlockx off
numlockx on
## Start kbdd to keep diferent layouts for each window
kbdd
## Make all keys sticky
#xkbset sticky -twokey -latchlock

# I don’t map z x c v b becasue can press them accidentally.
# Decrease brush size
xsetwacom --set 'Wacom Bamboo 2FG 6x8 Finger pad' Button 3 'key F5'
# Increase brush size
xsetwacom --set 'Wacom Bamboo 2FG 6x8 Finger pad' Button 8 'key F7'
# Swap colors
xsetwacom --set 'Wacom Bamboo 2FG 6x8 Finger pad' Button 9 'key F3'
# Undo
xsetwacom --set 'Wacom Bamboo 2FG 6x8 Finger pad' Button 1 'key +ctrl z -ctrl'
