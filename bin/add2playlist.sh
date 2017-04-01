#!/usr/bin/env bash

# add2playlist.sh
# Script adds a song currently playing in mpd to a playlist from ~/.mpd/playlists/.
# By default it’ll try to get mpd music library dir, get file path from mpc,
#   output a selection dialog with available playlist files and store
#   current song in a chosen playlist if it’s not already there.
# The playlist is supposed to be filled with paths to files relative to mpd
#   library, no xml.

# Params:
# -c    create a new playlist with this song instead of selecting existed one.
# -C    mpd client to send HUP to.

# Requires: mpd, mpc, Xdialog.
# Written with ncmpcpp and i3 WM in mind.

MPD_MUSIC_DIR=`sed -nr 's^\s*music_directory\s+"(.*)/*".*^\1^p' ~/.mpd/mpd.conf`
MPD_MUSIC_DIR=${MPD_MUSIC_DIR/#~/$HOME}
MPD_PLAYLIST_DIR=`sed -nr 's^\s*playlist_directory\s+"(.*)/*".*^\1^p' ~/.mpd/mpd.conf`
MPD_PLAYLIST_DIR=${MPD_PLAYLIST_DIR/#~/$HOME}
# MPD_CLIENT=ncmpcpp

current_song_path=`mpc -f "%file%" | head -n1`
current_song_artist_title=`mpc -f "[[%artist% – ]%title%]|[%file%]" | head -n1`

[ "$1" = '-c' ] && CREATE_NEW_PLAYLIST=t

while read -d $'\0'; do
	available_playlists[${#available_playlists[@]}]="${REPLY/.m3u/}"
done <  <(find "$MPD_PLAYLIST_DIR" -iname "*.m3u" -print0)

if [ -v CREATE_NEW_PLAYLIST -o ${#available_playlists[@]} -eq 0 ]; then
	reply=$(Xdialog --title 'Creating a new playlist' \
	                --backtitle 'Creating a new playlist' \
	                --inputbox 'New playlist name:' 400x150 '.m3u' 2>&1) \
		&& echo "$current_song_path" > "$MPD_PLAYLIST_DIR/$reply"
else
	latest_pl=$(ls -t1 "$MPD_PLAYLIST_DIR" | head -n1)
	reply=$(Xdialog --no-buttons \
	                --title 'Choose playlist' \
	                --backtitle "Choose playlist to add ‘${current_song_artist_title##*/}’" \
	                --fselect "$MPD_PLAYLIST_DIR/$latest_pl" $((WIDTH-WIDTH/10))x$((HEIGHT-HEIGHT/10)) 2>&1 ) \
		&& [ -f "$reply" ] && {
		grep -qF "$current_song_path" "$reply" || {
			echo "$current_song_path" >> "$reply"
			new_song_added=t
		}
	}
fi

current_ws=`i3-msg -t get_workspaces | sed -nr 's/.*"([0-9]+:[^"]+)","visible":(true|false),"focused":true.*/\1/p'`
mpd_ws=`sed -rn 's/^\s*workspace ([0-9]+:MPD).*/\1/p'  ~/.i3/config`

# Taking off urgent hint
# There may be two cases:
#   1. I just add a random song to playlist while doing some work on another
#      workspace, which means that ncmpcpp will have an urgent hint that I need
#      to take off and return to my old workspace.
#   2. I add a bunch of songs from the current playlist to their own. I am
#      already at the workspace with MPD and there’s no urgent hint to take off.
[ "$current_ws" = "$mpd_ws" ] || {
	# Not sure if this is still needed, cause ncmpcpp updates fast.
	# [ -v new_song_added ] && {
	# 	pkill -HUP ncmpcpp
	# 	urxvtc -name ncmpcpp -e ncmpcpp
	# }
	i3-msg "workspace $mpd_ws; focus child; workspace back_and_forth"
}
