#!/bin/bash

# Common part of ~/.xinitrc and ~/.xsession
. ~/.preinit.sh
# For ck-launch-session to work the following options must be set
# CONFIG_USB_SUSPEND=y		← Required for properly shutting down and powering
#                               USB hubs, and external USB HDD.
# CONFIG_IDE=n				← This breaks both udev and udisks.
# CONFIG_AUDITSYSCALL=y		← gdm requires it(?)
# In case of troubles: http://forums.gentoo.org/viewtopic-t-858965-highlight-.html
exec ck-launch-session \
	 dbus-launch --sh-syntax --exit-with-session \
	 i3 &>/dev/null
#	 i3 -V -d all >~/.i3/stdout 2>~/.i3/stderr
