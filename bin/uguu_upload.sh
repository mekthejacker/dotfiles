#!/bin/bash

# uguu_upload.sh
# Upload images to uguu.se from the command line.
# Similat to imgur_upload.sh, but simpler.
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
# set -x

usage() {
	cat <<-EOF
	Usage: ${0##*/} <last|lastr|/path/to/file>
	Upload images to imgur.com and output their URLs to stdout.
	If xsel or xclip is available, URLs are put on the X selection buffer
	for easy pasting.
	EOF
}

ermes() { echo "ERROR: $@" >&2; }

[ $# -eq 0 ] && {
	ermes 'no file specified.'
	usage
	exit 3
}||{
	[ "$1" = '-h' -o "$1" = '--help' ] \
		&& usage \
		&& exit 0
}

type curl &>/dev/null || {
	ermes 'couldn’t find curl, which is required.'
	exit 4
}

file="$1"

[[ "$file" =~ ^lastr?$ ]] && { # Last image on the (w?hole) desktop
	[[ "$file" =~ r$ ]] || maxdepth='-maxdepth 1' # 'r' to make it recursive
	file=$(find `xdg-user-dir DESKTOP` $maxdepth \
	            -type f \( -iname '*.png'  \
	            -o -iname '*.jpg'  \
	            -o -iname '*.jpeg' \
	            -o -iname '*.gif' \) -print0 \
	       | xargs -0 stat --format '%Y %n' \
	       | sort -nr \
	       | sed -nr 's/^\S+ //p;Q')
}

[ ! -f "$file" ] && {
	ermes "file ‘$file’ doesn’t exist, skipping."
	errors=t
	exit 3
}
# The "Expect: " header is to get around a problem when using this through
#   the Squid proxy. Not sure if it’s a Squid bug or what.
# $file may contain spaces and " in the path.
# response=$(curl -F "key=$apikey" -H 'Expect: ' -F "image=@\"${file//\"/\\\"}\"" \
# 	http://imgur.com/api/upload.xml 2>/dev/null ) || {
# 	ermes 'upload failed.'
# 	errors=t
# 	exit 3
# }
[ "$2" = noname ] || file_name=${file##*/}
file_escaped="${file//\"/\\\"}"
response=$(curl -i -F name="$file_name" -F file=@"$file" \
https://uguu.se/api.php?d=upload-tool 2>/dev/null ) || {
	ermes 'upload failed.'
	errors=t
	exit 3
}
# imgur_errmsg=$(sed -nr '$ s`<error_msg>(.*)</error_msg>`\1`p;T;Q1' <<<"$response" ) || {
# 	ermes "imgur.com: ‘$imgur_errmsg’."
# 	errors=t
# 	exit 3
# }
[ "$response" ] || {
	ermes 'response is empty.'
	errors=t
	exit 3
}

link=$(sed -rn '$ { s/^https.*$/&/; T; p; Q1 }' <<<"$response")
[ $? -ne 0 ] && success=t

[ -v success ] \
	&& echo -e "OK\nLink: $link" \
	|| {
		echo Fail…
		error=$response
		ermes ${error:-unknown}.
		errors=t
		exit 3
	}
#url=$(sed -nr 's`.*<original_image>(.*)</original_image>.*`\1`p' <<<"$response" )
#deleteurl=$(sed -nr 's`.*<delete_page>(.*)</delete_page>.*`\1`p' <<<"$response" )
#echo $url
#echo "Delete page: $deleteurl" >&2
clipboard+="$link"$'\n'
xdg-open "$link" &


[ -v DISPLAY ] && {
	type xsel &>/dev/null && echo -n $clipboard | xsel || {
		type xclip &>/dev/null && echo -n $clipboard | xclip
	}  || ermes 'haven’t copied to the clipboard: no xsel or xclip.'
}||  ermes 'haven’t copied to the clipboard: no $DISPLAY'

[ -v errors ] && exit 5
exit 0
