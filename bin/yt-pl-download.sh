# /usr/bin/env bash

# yt-pl-download.sh
# Downloads a youtube playlist by passed URL and saves audio tracks as AAC.
# to specified folder. Remembers what was already downloaded, so works fast.
# Change --audio-format from ‘best’ to ‘mp3’, if you need files in mp3.


 # Options for slow connections
#
# man -P"less -p '^\s*Format selection examples'" youtube-dl
# man -P"less -p '^\s*FORMAT'" youtube-dl

yt-pl() {
	local dir="$1" playlist="$2" format='aac'  # best|aac|flac|mp3|m4a|opus|vorbis|wav
	pushd "$dir"
	# list_of_donwload file will remember which youtube URLs
	# are already downloaded, so you could download only new playlist items
	# on sequential runs.
	youtube-dl --ignore-errors \
	           --extract-audio \
	           --audio-format "$format" \
	           --download-archive list_of_downloaded \
	           --no-post-overwrites \
	           "$playlist"
	popd
}

yt-pl "$1" "$2"

