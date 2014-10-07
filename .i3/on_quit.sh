#! /usr/bin/env bash

# This script serves three purposes:
# - kill iftops that were running in urxvtc windows, because they will load
#   100% of CPUs after losing their consoles (they were launched with sudo,
#   remember?) There is no cure.
# - gracefully kill firefox (and other apps), that were started from
#   startup_apps array in ~/.i3/autostart.sh. If firefox altered files
#   with private data, he needs some time to check it and ask confirmation
#   if the altered data seem to have lower size then one loaded at the start.
#   Earlier versions had problems and wiped the files, so I had to git checkout
#   them back.
# - erase /tmp/decrypted before exit, to be sure none of decrypted files are
#   left when I’m not by the computer.

[ "${ENV_DEBUG/*q*/}" ] || {
	exec &>/tmp/envlogs/on_quit
	set -x
}

sudo /usr/bin/killall iftop

[ "`sed -n "/case/,/esac/{s/^\s*$HOSTNAME)/&/p}" ~/.i3/autostart.sh 2>/dev/null`" ] \
	&& host_name=$HOSTNAME \
	|| host_name='\*'
eval `sed -n "/case/,/esac/{    # inside the case statement
         /^\s*$host_name/{    # there must be a section for hostname or common section
         :b1 s/^\s*;;/&/; t q1    # until end of the section found
             s/^\s*startup_apps/&/; T n1; p    # print startup_apps declaration
         :n1 n; b b1    # and skip other lines
         :q1 Q
		 }
	  }"  ~/.i3/autostart.sh`
for app in ${startup_apps[@]}; do
	# actual app, not bash wrapper, that must continue
	pkill -xf "^/.*$app$"
done
until [ -v ready_to_quit ]; do
	ready_to_quit=t
	for app in ${startup_apps[@]}; do
		# any process, including bash wrapper that must end gracefully
		pgrep -f "$app" && unset ready_to_quit
	done
	sleep 1
done

rm -rf /tmp/decrypted
i3-msg exit
