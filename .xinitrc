#!/bin/bash

# Common part of ~/.xinitrc and ~/.xsession
. ~/.preload.sh
# For ck-launch-session to work the following options must be set
# CONFIG_USB_SUSPEND=y		← Required for properly shutting down and powering
#                               USB hubs, and external USB HDD.
# CONFIG_IDE=n				← This breaks both udev and udisks.
# CONFIG_AUDITSYSCALL=y		← gdm requires it(?)
# In case of troubles: http://forums.gentoo.org/viewtopic-t-858965-highlight-.html

[ "${ENV_DEBUG/*i*/}" ] \
	&& i3_cmdline='i3 -c ~/.env/i3.config &>/dev/null' \
	|| i3_cmdline='i3 -c ~/.env/i3.config --shmlog-size=26214400 -V -d all >/tmp/envlogs/i3.stdout 2>/tmp/envlogs/i3.stderr'

# i3 wm uses its own tool to gather logs
#	|| i3_cmdline='i3 -c ~/.env/i3.config --shmlog-size=26214400 -V -d all'

eval exec ck-launch-session dbus-launch --sh-syntax --exit-with-session $i3_cmdline
