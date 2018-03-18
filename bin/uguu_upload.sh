#! /usr/bin/env bash

# uguu_upload.sh
# Upload images to uguu.se from the command line.
# Similar to imgur_upload.sh, but simpler.
# © 2018 deterenkelt.


# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3 of the License,
# or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but without any warranty; without even the implied warranty
# of merchantability or fitness for a particular purpose.
# See the GNU General Public License for more details.


# Requires
# GNU sed >= 4.2.1 (tested with it)
# GNU grep >= 2.9 (tested with it)
# GNU bash >= 4.2 (strong dependency)
# cURL >=7.38.0 (tested with it)
#
# Optional dependencies
# xsel or xclip to copy URL to clipboard.

set -feEu

usage() {
	cat <<-EOF
	Usage:
	./uguu_upload.sh <last|lastr|/path/to/image> [r|rand]

	Options:
	          last – use the most recent image from XDG_DESKTOP_DIR.
	         lastr – same as last, but searches recursively.
	/path/to/image – uploads image by path.

	       r, rand – URL should have a short random name.

	Uploads images to uguu.se and output their URLs to stdout.
	If xsel or xclip is available, URLs are put on the X selection buffer
	for easy pasting.
	EOF
}

err() { echo "ERROR: $@" >&2; exit 5; }

if [ $# -eq 0 ]; then
	usage
	err 'no file specified.'
elif [ "$1" = '-h' -o "$1" = '--help' ]; then
	usage
	exit 0
elif [ -r "$1" ]; then
	file="$1"
elif [[ "$1" =~ ^lastr?$ ]]; then
	# 'r' makes the search recursive.
	[[ "$1" =~ r$ ]] || maxdepth='-maxdepth 1'
	file=$(find $(xdg-user-dir DESKTOP) $maxdepth \
	            -type f \(    -iname '*.png'  \
	                       -o -iname '*.jpg'  \
	                       -o -iname '*.jpeg' \
	                       -o -iname '*.gif' \) -print0 \
	       | xargs -0 stat --format '%Y %n' \
	       | sort -nr \
	       | sed -nr 's/^\S+ //p;Q' )
else
	err "$1 is neither a valid path nor a code (valid codes: “last”, “lastr”."
fi


type curl &>/dev/null || err 'couldn’t find curl, which is required.'

if [[ "${2:-}" =~ ^(r|rand)$ ]]; then
	upload_name="randomname=on"
else
	upload_name="${file##*/}"
	upload_name="name=$upload_name"
fi

response=$(curl -i -F "$upload_name"                           \
                   -F file=@"$file"                             \
                   'https://uguu.se/api.php?d=upload-tool' 2>&1  ) \
    || { echo "$response"; err 'cURL failed.'; }

[ "$response" ] || err 'response is empty.'

link=$(sed -rn '$ { s/^https.*$/&/; T; p; Q1 }' <<<"$response") || success=t

if [ -v success ]; then
	echo -e "OK\nLink: $link"
else
	echo Fail…
	err ${response:-unknown}
fi

xdg-open "$link" &


if [ -v DISPLAY ]; then
	type xsel &>/dev/null && echo -n "$link" | xsel \
		|| type xclip &>/dev/null && echo -n "$link" | xclip \
		|| echo 'Didn’t copy to clipboard: no xsel or xclip.' >&2
else
	echo 'Didn’t copy to clipboard: DISPLAY is not set.' >&2
fi

exit 0
