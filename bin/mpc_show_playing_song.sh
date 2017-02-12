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
time_left+=" left."
msg="$song
$time_left"

# Variations
# notify-send --hint int:transient:1 -t 3500 mpd "$msg"
# notify-send --hint int:transient:1 -t 3500 " " "$msg"
notify-send --hint int:transient:1 -t 3500 "$song" "$time_left"

# --hint int:transient:1 is to make this message pass the notification stack.
# The stack isn’t infinite and if it’s full, which is at about 20 messages,
# you won’t be able to see any new messages until you MANUALLY CLEAN it.