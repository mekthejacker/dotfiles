#!/usr/bin/env bash

# dp() {
# $1 — package name 
# package=$1
# FEATURES="${FEATURES} nostrip" USE="$USE debug" CFLAGS="$CFLAGS -ggdb" CXXFLAGS="$CFLAGS" emerge $package
# echo -n 'Type a command to execute > '
# read

# Assume that binary will segfault (or something other whatever) and exit immidiately
#   so we need just provide what to execute and simulate manual input for commands
#   run, bt and quit and reply ‘y’  to the question about exit.
# gdb -ex run -ex bt -ex quit --args $REPLY <<< yes
# }