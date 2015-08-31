#!/bin/bash

# Common part of ~/.xinitrc and ~/.xsession
. ~/.preload.sh
# For ck-launch-session to work the following options must be set
# CONFIG_USB_SUSPEND=y		← Required for properly shutting down and powering
#                               USB hubs, and external USB HDD.
# CONFIG_IDE=n				← This breaks both udev and udisks.
# CONFIG_AUDITSYSCALL=y		← gdm requires it(?)
# In case of troubles: http://forums.gentoo.org/viewtopic-t-858965-highlight-.html

pgrep -af gpg-agent && echo 'gpg-agent is still there at xinitrc time!' \
							|| echo 'No gpg-agent at xinitrc time!'

[ "${ENV_DEBUG/*i*/}" ] \
	&& i3_cmdline='i3 &>/dev/null' \
	|| i3_cmdline='i3 -V -d all >/tmp/envlogs/i3.stdout 2>/tmp/envlogs/i3.stderr'

eval exec ck-launch-session dbus-launch --sh-syntax --exit-with-session $i3_cmdline
