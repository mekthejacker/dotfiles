#!/bin/bash

. ~/.preinit
exec ck-launch-session \
	 dbus-launch --sh-syntax --exit-with-session \
	 ssh-agent \
	 i3 -V -d all > ~/.i3/stdout 2> ~/.i3/stderr
#	 i3 &>/dev/null
