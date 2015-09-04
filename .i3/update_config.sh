#! /usr/bin/env bash

# This script updates output names in i3 comfig and switches off unnecesary
#   ones on startup.
sed -r "s/PRIMARY_OUTPUT/$PRIMARY_OUTPUT/g" ~/.i3/config.template > ~/.i3/config
for slave in ${!SLAVE_OUTPUT_*}; do
	eval sed -ri \"s/$slave/\$$slave/g\" ~/.i3/config
	[ -v STARTUP ] && eval xrandr --output \$$slave --off
done
[ -v STARTUP ] || i3-msg restart
