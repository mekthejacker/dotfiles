#! /usr/bin/env bash

# ~/.env/update_config.sh
# This script updates output names in i3 config and switches off unnecesary
# ones on startup.

sed -r "s/PRIMARY_OUTPUT/$PRIMARY_OUTPUT/g" ~/.env/i3.template.config > ~/.env/i3.config
for slave_substitute in ${!SLAVE_OUTPUT_*}; do
	declare -n slave=$slave_substitute
	sed -ri "s/$slave_substitute/$slave/g" ~/.env/i3.config
	[ -v PRELOAD_SH ] && xrandr --output $slave --off
done
# Hide the bar if on plasma
#[ $HOSTNAME = home ] && sed -ri '/bar \{/,/\}/ {s/(^\s*mode\s+)dock/\1hide/}' ~/.env/config
[ -v PRELOAD_SH ] || i3-msg restart
