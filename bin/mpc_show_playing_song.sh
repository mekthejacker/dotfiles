#! /usr/bin/env bash

# mpc_show_playing_song.sh
# Shows a notification window with the currently playing song in mpd.
# mpc_show_playing_song.sh © deterenkelt

shopt -s extglob
unset song cur_time duration;
# If there are no tags, where to take artist and title.
try_to_guess_from_filename=t
set -x

# Extracting data from the first two lines of mpc output
IFS=$'\n'  read -r -d $''  song cur_time duration  < <(mpc | sed -rn '1 {N; s/(.*)\n.* ([0-9:]+)\/([0-9:]+) \([0-9]+%\)/\1\n\2\n\3/p}')
IFS=$'\n'  read -r -d $''  artist title  < <(mpc -f '%artist%\n%title%' | sed -rn '1,2p')

# Prepending MM:SS with 00:, because `date` will think we give it HH:MM.
[[ "${cur_time//:/}" =~ :.*$ ]] || cur_time="00:$cur_time"
[[ "${duration//:/}" =~ :.*$ ]] || duration="00:$duration"
secs_left=$(( `date --date="$duration" -u +%s` - `date --date="$cur_time" -u +%s` ))
# Stripping unneccesary 00:0 and 00:0 ← the order is important!
time_left=`date --date="@$secs_left" -u +%H:%M:%S | sed -r 's/^00:0//;s/^00://'`
time_left+=" left."

if ! [ "$artist" -a "$title" ]; then
	#declare -p song cur_time duration
	# In case it’s a file path, strip preceding dirs.
	song=${song##*/}
	# Strip everything after ‘youtube’
	song=${song%youtube*}
	song=${song%Youtube*}
	song=${song%YouTube*}
	song=${song%YOUTUBE*}
	# strip the garbage that might be left after stripping ‘youtube’.
	song=${song%%*([ -])}
	# Trying to be intellectual and guess the artist and title.
	[[ "$song" =~ ^(.*)\ (-|–|—)\ (.*)$ ]] && {
		artist=${BASH_REMATCH[1]}
		title=${BASH_REMATCH[3]}
	}
fi

if [ "$artist" -a "$title" ]; then
	notify-send --hint int:transient:1 -t 4200 "$title" "by $artist\n\n$time_left"
else
	# String longer than 18 symbols can’t fit into Libnotify window.
	#[ ${#song} -gt 18 ] && song=${song:0:17}…
	notify-send --hint int:transient:1 -t 4200 "$song" "$time_left"
fi

# --hint int:transient:1 is to make this message pass the notification stack.
# The stack isn’t infinite and if it’s full, which is at about 20 messages,
# you won’t be able to see any new messages until you MANUALLY CLEAN it.