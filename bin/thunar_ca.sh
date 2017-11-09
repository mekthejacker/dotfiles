#!/usr/bin/env bash

# thunar_ca.sh – set of custom actions for Thunar file manager.
#set -x
action=$1
shift

echo '-->'
echo $@
echo '<--'
for filename in "$@"; do
    [ -r "$filename" ] && {
		[ -d "$filename" ] && {
			while read -d $'\0' unreadable; do
				inaccessible[${#inaccessible[@]}]="$unreadable"
			done < <(find "$filename" ! -readable -print0)
		}
		[ -v first_file ] || first_file="$filename"
		:
	}||{ inaccessible+=("$filename"); }
done

[ -v inaccessible ] && \
	Xdialog --msgbox "The following files or folders are not accessible:\n
`for ((i=0; i<${#inaccessible[@]}; i++)); do echo ${inaccessible[i]}; done`" 0x0 \
	&& exit 3

case "$action" in
	'--convert-to-jpeg')
		~/bin/image_operations.sh conv2jpeg "$@"
		;;
	'--pictures-to-video')
		~/bin/image_operations.sh conv2mp4 "$@"
		;;
	'--glue-images')
		~/bin/image_operations.sh glue "$@"
		;;
	'--filename-to-clipboard')
		xclip -rmlastnl <<< `echo "'$first_file'"` 2>/dev/null \
			|| Xdialog --msgbox "`[ $? -eq 127 ] && echo 'xclip not found.' \
			|| echo 'xclip failed.'`" 0x0
		;;
	'--show-files')
		# For testing purposes
		Xdialog --msgbox "`for i in "$@"; do echo $i; done`" 0x0
		;;
	*)
		Xdialog --msgbox "Action is not specified." 0x0
esac
