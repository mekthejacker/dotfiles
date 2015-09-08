#!/usr/bin/env bash

# thunar_ca.sh – set of custom actions for Thunar file manager.
#set -x
action=$1
shift

DESKTOP=`xdg-user-dir DESKTOP`

echo '-->'
echo $@
echo '<--'
for filename in "$@"; do
    if [ -r "$filename" ]; then
		[ -d "$filename" ] && {
			while read -d $'\0' unreadable; do
				inaccessible[${#inaccessible[@]}]="$unreadable"
			done < <(find "$filename" ! -readable -print0)
		}
		[ -v first_file ] || first_file="$filename"
		:
	else inaccessible[${#inaccessible[@]}]="$filename";	fi
done

[ -v inaccessible ] && \
	Xdialog --msgbox "The following files or folders are not accessible:\n
`for ((i=0; i<${#inaccessible[@]}; i++)); do echo ${inaccessible[$i]}; done`" 0x0 \
	&& exit 3

case "$action" in
#	'--roll-up') was removed in favor of thunar-archive-plugin.
	'--show-the-font')
		font_file=`file -i "$first_file" | sed -nr 's/^([^:]+):[^;]+font[^;]+;.*/\1/p'`
		if [ "$font_file" ]; then
			pan_text="Съешь ещё этих мягких французских булок да выпей чаю"
			mono_text='“Illinois-1” – does this sound proudly? I don’t think so.
func1() {
    a=${WRRIIII[@]}
    b=$(sed \"s/a/b/g\" <<< `echo lol` )
    [${argh)] && return
}'
			read width height <<< `xrandr |sed -rn 's/Screen 0:.*current ([0-9]+) x ([0-9]+),.*/\1\n\2/p'`
			# http://www.imagemagick.org/Usage/text/#pango_markup
			# set -x
			pt=24
			dpi=91
			line=1
			step=2
			convert \
				-size ${width}x$height \
				xc:white \
				-type Grayscale \
				-define 3 \
				-density $dpi \
				-depth 8 \
				-fill black \
				-pointsize $pt \
				-draw 'gravity North text 0,0 "'"${font_file##*/}"'"' \
				-font "$font_file" \
				-pointsize $pt \
				-draw 'gravity NorthWest text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt-$step)) \
				-draw 'gravity NorthWest text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt-$step)) \
				-draw 'gravity NorthWest text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt-$step)) \
				-draw 'gravity NorthWest text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt-$step)) \
				-draw 'gravity NorthWest text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt-$step)) \
				-draw 'gravity NorthWest text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt-step--)) \
				-draw 'gravity NorthWest text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt-$step)) \
				-draw 'gravity NorthWest text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt-$step)) \
				-draw 'gravity NorthWest text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt-$step)) \
				-draw 'gravity NorthWest text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt-$step)) \
				-draw 'gravity NorthWest text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $pt \
				-draw 'gravity NorthEast text 0,'$(( 48 + (line=1)*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt+$step)) \
				-draw 'gravity NorthEast text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt+$step)) \
				-draw 'gravity NorthEast text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt+$step)) \
				-draw 'gravity NorthEast text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt+step++)) \
				-draw 'gravity NorthEast text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt+$step)) \
				-draw 'gravity NorthEast text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt+$step)) \
				-draw 'gravity NorthEast text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt+$step)) \
				-draw 'gravity NorthEast text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt+$step)) \
				-draw 'gravity NorthEast text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt+$step)) \
				-draw 'gravity NorthEast text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=pt+$step)) \
				-draw 'gravity NorthEast text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $pan_text\"" \
				-pointsize $((pt=12)) \
				-draw 'gravity NorthWest text 0,'$(( 48 + $line*$line-$line + ($dpi/$pt + $pt )*line++ ))" \"${pt}pt $mono_text\"" \
				/tmp/font.png || {
				Xdialog --msgbox 'ImageMagick could not render that font.' 0x0
				exit 4
			}
			# set +x
			eog -f /tmp/font.png
			rm /tmp/font.png
		else
			Xdialog --msgbox "File ‘$first_file’ doesn’t look like a font file." 0x0
			exit 5
		fi
		;;
	'--convert-to-jpeg')
		for image in "$@"; do
			image="${image##*/}"
			[ -e "$DESKTOP/${image%.*}.jpg" ] && {
				Xdialog --ok-label="Rewrite" --cancel-label="Cancel" \
				        --yesno "File ‘$DESKTOP/${image%.*}.jpg’ already exists." 0x0 \
					|| rm "$DESKTOP/${image%.*}.jpg"
			}
			convert "$image" -quality 92 "$DESKTOP/${image%.*}.jpg" \
				&& notify-send  -t 2000 'Converted!' \
				|| notify-send  -t 2000 'Failed to convert…'
		done
		;;
	'--filename-to-clipboard')
		xclip <<< `echo "$first_file"` 2>/dev/null ||\
		Xdialog --msgbox "`[ $? -eq 127 ] && echo 'xclip not found.' || echo 'xclip failed.'`" 0x0
		;;
	'--show-files')
		# For testing purposes
		Xdialog --msgbox "`for i in "$@"; do echo $i; done`" 0x0
		;;
	*)
		Xdialog --msgbox "Action is not specified." 0x0
esac
