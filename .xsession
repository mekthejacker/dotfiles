#!/bin/bash

# Common part of ~/.xinitrc and ~/.xsession
. ~/.preinit

# ~/.xsession do not need to run consolekit session, it should be already
#   done by display manager.
exec i3 &>/dev/null
# exec i3 -V -d all > ~/.i3/stdout 2> ~/.i3/stderr
