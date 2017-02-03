#! /usr/bin/env bash

# mpc_show_playing_song.sh
# Shows a notification window with the currently playing song in mpd.
# mpc_show_playing_song.sh © deterenkelt

unset song cur_time duration;
# Extracting data from the first two lines of mpc output
IFS=$'\n'  read -r -d $''  song cur_time duration  < <(mpc | sed -rn '1 {N; s/(.*)\n.* ([0-9:]+)\/([0-9:]+) \([0-9]+%\)/\1\n\2\n\3/p}')
declare -p song cur_time duration
# Prepending MM:SS with 00:, because `date` will think we give it HH:MM.
[[ "${cur_time//:/}" =~ :.*$ ]] || cur_time="00:$cur_time"
[[ "${duration//:/}" =~ :.*$ ]] || duration="00:$duration"
declare -p song cur_time duration
secs_left=$(( `date --date="$duration" -u +%s` - `date --date="$cur_time" -u +%s` ))
declare -p secs_left
# Stripping unneccesary 00:0 and 00:0 ← the order is important!
time_left=`date --date="@$secs_left" -u +%H:%M:%S | sed -r 's/^00:0//;s/^00://'`
msg="$song
$time_left"

notify-send --hint int:transient:1 -t 3500 mpd "$msg"