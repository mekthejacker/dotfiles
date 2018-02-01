#! /usr/bin/env bash

# This script serves one purpose:
# - gracefully kill firefox (and other apps), that were started from
#   startup_apps array in ~/.env/autostart.sh. If firefox altered files
#   with private data, he needs some time to check it and ask confirmation
#   if the altered data seem to have lower size then one loaded at the start.
#   Earlier versions had problems and wiped the files, so I had to git checkout
#   them back.

[ "${ENV_DEBUG/*q*/}" ] || {
	exec &>/tmp/envlogs/on_quit
	set -x
}

# Preventing firefox from messing the tabs when it closes ungracefully
i3-msg '[class=".*"] kill'
i3-msg exit
