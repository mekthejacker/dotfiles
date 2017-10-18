# /usr/bin/env bash

# yt-pl-download.sh
# Downloads a youtube playlist by passed URL and saves audio tracks as AAC.
# to specified folder. Change --audio-format from ‘best’ to ‘mp3’,
# if you need files in mp3.

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