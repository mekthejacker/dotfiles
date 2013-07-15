#!/bin/bash

. ~/.preinit
# For ck-launch-session to work the following options must be set
# CONFIG_USB_SUSPEND=y		<- Required for properly shutting down and powering USB hubs,
#							   for like, external USB HDD.
# CONFIG_IDE=n				<- This breaks both udev, and udisks.
# CONFIG_AUDITSYSCALL=y		<- This is really required, it might work out of fluke with
#                              gnome-base/gdm but that's pretty much it.
# In case of troubles: http://forums.gentoo.org/viewtopic-t-858965-highlight-.html
exec ck-launch-session \
	 dbus-launch --sh-syntax --exit-with-session \
	 ssh-agent \
	 i3 &>/dev/null
#	 i3 -V -d all >~/.i3/stdout 2>~/.i3/stderr
