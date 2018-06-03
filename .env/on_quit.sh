#! /usr/bin/env bash

#  on_quit.sh
#  Kills all containers spawned within an i3 session. This helps programs
#  like firefox to quit gracefully.

[ "${ENV_DEBUG/*q*/}" ] || {
	exec &>/tmp/envlogs/on_quit
	set -x
}

declare -A apps2wait=(
	[firefox]=
	[Thunar]=
	[pidgin]=
	[gimp]=
	[wine]=
	[libreoffice]=
)

i3-msg '[class=".*"] kill'

until [ -v ready_to_quit ]; do
	sleep 0.5
	for app in ${!apps2wait[@]}; do
		pgrep -af "$app" &>/dev/null || apps2wait[$app]='quit'
	done
	ready_to_quit=t
	for app in ${!apps2wait[@]}; do
		[ "${apps2wait[$app]}" != 'quit' ] && unset ready_to_quit
	done
done

i3-msg exit
