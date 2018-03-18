#! /usr/bin/env bash

hsetroot -solid \#000000 -alpha ${2:-0} -full "$HOME/.env/wallpapers/`ls -1tr ~/.env/wallpapers/ | tail -n1`" -brightness ${1:-0.07}