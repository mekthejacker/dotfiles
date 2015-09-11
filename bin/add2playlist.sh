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
	                --inputbox 'New playlist name:' 300x100 '.m3u' ) \
		&& echo "$current_song_path" > "$MPD_PLAYLIST_DIR/$reply"
else
	reply=$(Xdialog --no-buttons \
	                --title 'Choose playlist' \
	                --backtitle "Choose playlist to add ‘${current_song_artist_title##*/}’" \
	                --fselect "$MPD_PLAYLIST_DIR/" $((WIDTH-200))x$((HEIGHT-100)) 2>&1 ) \
		&& [ -f "$reply" ] && {
		grep -qF "$current_song_path" "$reply" || {
			echo "$current_song_path" >> "$reply"
			new_song_added=t
		}
	}
fi

[ -v new_song_added ] && {
	pkill -HUP ncmpcpp
	urxvtc -name ncmpcpp -e ncmpcpp
}

# Taking off urgent hint
i3-msg "workspace 9:MPD; focus child; workspace back_and_forth"
