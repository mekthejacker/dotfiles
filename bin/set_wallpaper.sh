#! /usr/bin/env bash

file="$HOME/.env/wallpapers/$(ls -1tr ~/.env/wallpapers/ | tail -n1)"
[ -f "$file" ] || exit 5
hsetroot -solid \#000000 -alpha ${1:-200} -brightness ${2:-0.07} -full "$file"