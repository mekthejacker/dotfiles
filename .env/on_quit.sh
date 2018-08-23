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

halfseconds=0
until [ -v ready_to_quit ]; do
	sleep 0.5
	let ++halfseconds
	for app in ${!apps2wait[@]}; do
		pgrep -u $USER -af "$app"  &>/dev/null || apps2wait[$app]='quit'
	done
	ready_to_quit=t slowpoke_apps=()
	for app in ${!apps2wait[@]}; do
		[ "${apps2wait[$app]}" != 'quit' ] && {
			unset ready_to_quit
			slowpoke_apps+=($app)
		}
	done
	#  Every five seconds (10 halfseconds) show why aren’t we quitting.
	(( halfseconds % 10 == 0 )) && {
		[ ${#slowpoke_apps[@]} -eq 1 ] \
			&& they_aint_quitting='isn’t quitting.' \
			|| they_aint_quitting='aren’t quitting.' \
		notify-send --hint int:transient:1 \
		            --urgency normal \
		            -t 2200 \
		            "$(IFS=', '; echo "${slowpoke_apps[*]^^}")"  \
		            "$they_aint_quitting" \
		|| :
	}
done

i3-msg exit
