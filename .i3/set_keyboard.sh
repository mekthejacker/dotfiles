#!/usr/bin/env bash

## Due to electromagnetic interference badly shielded USB cables (especially
##  if you use extension cords) may cause input devices to be re-enabled,
##  so it’s handy to reload keyboard settings by i3’s reload config call.
xkbcomp ~/.env/xkbcomp.xkb $DISPLAY
## Setting NumLock
numlockx off
numlockx on
## Start kbdd to keep diferent layouts for each window
kbdd
## Make all keys sticky
#xkbset sticky -twokey -latchlock
