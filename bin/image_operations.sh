#! /usr/bin/env bash

# image_operations.sh
# A helper script for a file manager like Thunar to work with images.
# © deterenkelt

 # Dependencies
#
#      common:  notify-send, Xdialog, stat, file, mktemp, identify, ffmpeg;
#   conv2jpeg:  convert;
#        glue:  convert;
#     pngcomp:  pngcrush, parallel;
#    conv2mp4:  convert,
#               mpv (or whatever media player you put in $media_player),
#               viewnior (or whatever picture viewer you put in $picture_viewer);
#  anigif2mp4:  convert.
#
#  P.S. convert and identify are parts of imagemagick package.

show_usage() {
	cat <<-EOF
	Usage:
	./image_operations.sh <MODE> <files or directories>

	Pass whatever, MODE will throw off any files
	        incompatible with these
	               formats
	                  ↓

	MODE         INPUT FORMATS    OUTPUT
	—————————    —————————————    ————————————————————————————————————————————
	conv2jpeg    PNG, TIFF        Each file converts to JPEG.

	glue         JPEG, PNG,       All images combine into one big JPEG,
	             GIF (simple),    where they are aligned in a column.
	             TIFF

	pngcomp      PNG              Same PNG, but with size reduced.

	conv2mp4     JPEG, PNG,       Creates a web browser compatible video file.
	             GIF (simple),    For the formats on the left:
	             TIFF             1. If multiple files passed, then converts
	                                 this series of images to an mp4 file
	                                 with a rate of 25 frames/second.
	                              2. If a single file passed, then you could
	                                 choose between
	                                 - mute video, that shows only a still
	                                   image (you choose the duration);
	                                 - a video with an audio track put over
	                                   an image (in that case duration will be
	                                   taken from the audio track).

	anigif2mp4   GIF (animated)   3. If the file(s) passed are animated GIF,
	                                 then each file will be converted to mp4
	                                 separately. It is an alias to conv2mp4
	                                 with a restriction to animated GIF only.

	DEFAULT SETTINGS (that you may change)
	——————————————————————————————————————
	Overwrite? – YES      By deafult, overwrites resulting files. You may
	                      comment ‘force_overwrite=t’ to make the script ask
	                      you instead.

	JPEG quality? – 96    Quality for resulting JPEGs is 96. Can be adjusted
	                      with ‘conv2jpeg_quality’ variable.

	Convert	              Doesn’t convert grayscale PNG and TIFF to JPEG,
	grayscale? – NO       you may comment ‘conv2jpeg_dont_convert_grayscale=t’
	                      to convert them too.

	Minimum file size     Doesn’t convert files smaller than 300 KiB.
	to convert an image   You may alter the size in this variable:
	to JPEG? – 300 KiB    ‘conv2jpeg_dont_convert_smaller_than_k’.

	Minimum file size     Doesn’t compress PNG images smaller than 1000 KiB
	to apply PNG com-     Look for this variable to change size:
	pression? — 1000 KiB  ‘pngcomp_dont_compress_if_smaller_than_k’.

	Avoid conversion      If the conversion couldn’t make the source file
	to JPEG,              smaller, it’s useless. We don’t replace source
	if the new file       files in that case. But you may force conversion
	is bigger? – YES      with uncommenting ‘conv2jpeg_ignore_blown_size=t’.

	EOF

	# FFMPEG-3.4 takes care of the proper timing when it converts
	# an animated GIF to MP4.

	# You NEED to check the result of anigif2mp4, because
	# conversion from GIF to MP4 has two pitfalls:
	#   - some GIFs, which second layer and above do not have pixels
	#     at 0:0, may have such layer SHIFTED, resulting MP4 will be a mess.
	#   - GIFs which background is transparent will have it white in MP4.
	#     The edges of the picture and transparency will look ugly and rough
	#     on white, because usually there’s either some grayish colour
	#     of the window, or a checkered pattern, which smoothes this edge.
}


set -feE
shopt -s extglob

on_exit() {
	echo 101 >$pipe
	wait $xdialog_pid
	[ -v tmpdir ] && rm -rf "$tmpdir"
}
trap 'on_exit' EXIT TERM INT QUIT KILL

show_error() {
	local file=$1 line=$2 lineno=$3
	echo -e "$file: An error occured!\nLine $lineno: $line" >&2
	notify-send "${BASH_SOURCE##*/}" "Error: check the console."
}
 # The reason we need this function is because set +e won’t remove the trap.
#  So after disabling the errexit shell option, we also need to remove that
#  trap manually and put it back.
#
traponerr() {
	case "$1" in
		set)
			# NB single quotes – to prevent early expansion
			trap 'show_error "$BASH_SOURCE" "$BASH_COMMAND" "$LINENO"' ERR
			;;
		unset)
			# NB trap '' ERR will ignore the signal.
			#    trap - ERR will reset command to 'show_error "$BASH_SOURCE…'
			trap '' ERR
			;;
	esac
}
traponerr set

deps=(notify-send Xdialog stat file mktemp identify ffmpeg)

 # Show a report, when not all files, specified on the command line,
#  were taken into processing. This will also report simple/animated
#  GIFs, when they mismatch the $mode – because there’s only one MIME
#  type for both of them.
#
# VERBOSE=t

VERSION=20171119

# YOU DON’T NEED TO CHANGE THIS LINE
notify_send='notify-send --hint int:transient:1 -t 3000 -i info'

 # Video player to use for ‘conv2mp4’,
#  to check what came out of conversion.
#
media_player='mpv --loop-file=inf --fs=yes'

 # Picture viewer for ‘anigif2mp4’. To open GIF images
#  so you could compare the original image to the MP4,
#  which would be shown after.
#
picture_viewer='viewnior --fullscreen'

 # You can put/alternate transient options for ffmpeg here.
#  Only transient – it will be a bad idea to change codec here.
#
ffmpeg='ffmpeg -hide_banner -threads 4'

 # Don’t ask, whether I want to overwrite resulting files.
#  Questions about deleting source files will still be there.
#  Comment to make script ask about overwriting
#
force_overwrite=t

 # Default quality for resulting JPEG images.
#  Sane range is 92…96. 100 is close to lossless.
#
conv2jpeg_quality=96

 # Skip grayscale images when converting to JPEG.
#  Grayscale PNG often, but not always, are smaller than JPEG.
#  Comment to force conversion.
#
conv2jpeg_dont_convert_grayscale=t

 # Skip files smaller than specified number of KiB,
#  when converting to JPEG.
#
conv2jpeg_dont_convert_smaller_than_k=300 # in KiB

# YOU DON’T NEED TO CHANGE THIS LINE
conv_size_limit_in_bytes=$((conv2jpeg_dont_convert_smaller_than_k*1024))

 # Allow conversion to JPEG,
#  even if the resulting file went bigger.
#  Uncomment to enable.
#
#conv2jpeg_ignore_blown_size=t

 # Skip PNG compression for small files.
#  Running pngcrush is costly on CPU time, running it on small images
#  brings no profit most of the time. Uncompressed screenshots
#  may have size of
#    1.2… 6… 12 MiB for 520p… 720p… 1080p (rougly)
#  These are the ones we usually want to find and compress,
#  not those lower than one megabyte.
#
pngcomp_dont_compress_if_smaller_than_k=1000 # in KiB

tmpdir=$(mktemp -d)

 # We need to see, what image formats are allowed for which mode
#  To differentiate between gifs and animated gifs, we’ll use
#  two different formats.
#
declare -A iformats=(
	[jpeg]='image/jpeg'
	[png]='image/png'
	# [apng]='image/png'   # Let’s ignore APNG for now.
	[gif]='image/gif'
	[tiff]='image/tiff'
)
declare -A allowed_formats_table=(
	[conv2jpeg]='png tiff'
	[pngcomp]='png'
	[glue]='jpeg png gif tiff'
	[conv2mp4]='jpeg png gif tiff'
	[anigif2mp4]='gif'
)

case "$1" in
	conv2jpeg)
		# Converts images to JPEG
		mode=conv2jpeg
		deps+=(convert)
		;;
	pngcomp)
		# Optimises the size of PNG images
		mode=pngcomp
		deps+=(pngcrush parallel)
		;;
	glue)
		# Combines several images into one,
		# putting them in a column.
		mode=glue
		deps+=(convert)
		;;
	anigif2mp4)
		# It is an alias for ‘conv2mp4’, restricted to animated gifs only.
		# The idea is that you can select a folder in file manager, and
		# convert all animated GIF in it to mp4. Without such an alias
		# user would have to *know all the paths to animated gifs*
		# in order to pass them to conv2mp4.
		mode=anigif2mp4
		only_animated_gif=t
		deps+=(convert)
		;;
	conv2mp4)
		# 1. Creates a video from separate images.
		#    Basically a slide show with 25 fps.
		# 2. Creates a video, that shows a single image
		#    with an audio track put over it.
		# 3. Converts an animated gif to mp4.
		# 4. Creates a video from a still image with
		#    set duration (useful for codec testing).
		mode=conv2mp4
		deps+=(convert ${media_player%% *} ${picture_viewer%% *})
		;;
	*)
		Xdialog --title "Usage – ${BASH_SOURCE##*/}" \
		        --no-wrap --fixed-font \
		        --no-cancel \
		        --textbox - \
		        800x600 \
		        <<<$(show_usage | sed -r 's/^/   /g; 1i\\n')
		exit 3
esac
shift

for bin in "${deps[@]}"; do
	which $bin >/dev/null || {
		echo "$bin wasn’t found." >&2
		errors=t
	}
done
[ -v errors ] && {
	notify-send -t 3000 "Check the console output for errors." "${BASH_SOURCE##*/}"
	exit 3
}

progress_window_initialise() {
	pipe="$tmpdir/progress_window_pipe"
	# It’d be suspicious that it does exist when it shouldn’t.
	[ -p $pipe ] && rm -f $pipe
	mkfifo $pipe
	exec {pipe_fd}<>$pipe
	pre='XXX\n'; post='\nXXX'
	Xdialog --title "$1 – ${BASH_SOURCE##*/}" \
	        --backtitle "$1" \
	        --gauge '' \
	        630x200 \
	        0% \
	        <$pipe &
	xdialog_pid=$!
}
progress_window_upd_text() {
	local s='XXX'$'\n' arg
	for arg in "$@"; do
		s+="$arg"
		s+=$'\n'
		s+="\\n"
		s+=$'\n'
	done
	s=${s%\\n$'\n'}
	s+='XXX'
	echo "$s" >$pipe
}

allowed_formats="${allowed_formats_table[$mode]}"
echo "Allowed formats: $allowed_formats."
images=()
declare -A throwoffs=()
# This is only to speed up the search for arguments
#   passed as folders. Real check will follow later.
# find patterns will turn 'jpeg gif png' to
#   \( -iname "*.jpeg" … -o -iname "*.png" \)
#
find_patterns=$(
	sed -r 's/ / -o -iname *\./g
	        s/^/\( -iname *\./
	        s/$/ \)/' \
	       <<<"${allowed_formats/jpeg/jpeg jpg jpe}")

# For starters, creating a list of all files
# and traversing directories.
for arg in "$@"; do
	if [ -r "$arg" ]; then
		if [ -f "$arg" ]; then
			images+=("$arg")
		elif [ -d "$arg" ]; then
			progress_window_initialise "Searching directory: $arg"
			echo 72% >$pipe
			while IFS= read -r -d $''; do
				images+=("$REPLY")
				subpath=${REPLY#$arg}
				subpath=${subpath%/*}
				file=${REPLY##*/}
				[ "$subpath" = "$file" ] && unset subpath
				[ ${#file} -gt 50 ] && {
					filetail=${file: -10:10}
					file=${file:0:40}…$filetail
				}
				progress_window_upd_text "$subpath" "$file" "${#images[@]}"
			done < <(find -L "$arg" -type f $find_patterns -print0)
			echo 101 >$pipe; wait $xdialog_pid
		else
			$notify_send 'Argument is not a directory or a file:' "$arg"
			exit 3
		fi
	else
		$notify_send 'Cannot read file:' "$arg"
		exit 3
	fi
done

echo "Checking MIME-type compatibility to ‘$mode’ mode…"
progress_window_initialise "Checking MIME-type compatibility to ‘$mode’ mode…"
total_files=${#images[@]}
[ -v test_path ] || test_path=''
for ((i=0; i<$total_files; i++)); do
	path=${images[i]}
	subpath=${path%/*}
	file=${path##*/}
	[ "$subpath" = "$file" ] && unset subpath
	[ ${#file} -gt 50 ] && {
		filetail=${file: -10:10}
		file=${file:0:40}…$filetail
	}
	progress_window_upd_text "$file" "$subpath" "$i/$total_files"
	[ "$path" = "$test_path" ] && set -x
	mimetype=$(file -L -b --mime-type "$path")
	unset image_matches_mode throwoff_reason
	for format in $allowed_formats; do
		[ "$mimetype" = "${iformats[$format]}" ] && {
			# GIF needs an additional check for animation
			[ "$mimetype" = 'image/gif' ] && {
				set -o pipefail
				# identify reports one line per animation cadre.
				# identify a shit and expands ‘*’ to all files.
				# No, that’s not shell expansion, set -f is on.
				# I’ve disabled globstar, but it’s identify, fucking identify.
				[ "$(identify -quiet -format '%n %i\n' "${path//\*/\\*}" | wc -l)" = 1 ] \
					&& giftype=simple \
					|| giftype=animated
				set +o pipefail
				[ $giftype = animated  -a  ! -v only_animated_gif ] && {
					throwoff_reason='Animated GIF are not allowed in this mode.'
					break
				}
				[ $giftype = simple  -a  -v only_animated_gif ] && {
					throwoff_reason='Non-animated GIF are not allowed in this mode.'
					break
				}
				case $giftype in
					simple) gif_files_present=t;;
					animated) anigif_files_present=t;;
				esac
			}
			image_matches_mode=t && break
		}
	done
	if [ -v image_matches_mode ]; then
		[ -v first_existing_index ] || first_existing_index=$i
	elif [ ! -v throwoff_reason ]; then
		throwoff_reason="MIME-type $mimetype not allowed in this mode."
	fi
	[ -v throwoff_reason ] && {
		throwoffs+=( ["$path"]="$throwoff_reason" )
		unset images[$i]
	}
	echo $((i*100/total_files)) >$pipe
	[ "$path" = "$test_path" ] && set +x
done
echo 101 >$pipe; wait $xdialog_pid

total_files_after_check=${#images[@]}
[ ${#throwoffs[@]} -ne 0  -a  -v VERBOSE ] && {
	throwoffs_title="$((total_files-total_files_after_check)) files were thrown off:"
	for path in "${!throwoffs[@]}"; do
		throwoffs_list+="$path:"$'\n\t'"${throwoffs["$path"]}"$'\n'
	done
	echo -e "\n$throwoffs_title" >&2
	echo "$throwoffs_list" >&2
	Xdialog --title "Files were discarded – ${BASH_SOURCE##*/}" \
	        --backtitle "$throwoffs_title" \
	        --fixed-font \
	        --ok-label Continue \
	        --cancel-label Abort \
	        --textbox - \
	        800x600 \
	        <<<"$throwoffs_list" || {
	    echo Aborted >&2
	    #notify-send "${BASH_SOURCE##*/}" "Aborted."
	    exit 3
	}
}
unset ${!throwoffs*}

# We have done the check on format
# and don’t need the alias any more.
[ "$mode" = anigif2mp4 ] && mode=conv2mp4

[ $mode = conv2mp4 ] && {
	# There must be GIF(s) only of one type.
	# set -x
	[ -v gif_files_present  -a  -v anigif_files_present ] && {
		echo "$mode doesn’t accept simple GIFs and animated GIFs simulataneously." >&2
		Xdialog --title "Conversion to MP4 – ${BASH_SOURCE##*/}" \
		        --msgbox "$mode doesn’t accept simple GIFs and animated GIFs simulataneously." \
		        600x120
		exit 3
	}
	[ ${#images[@]} -eq 1  -a  ! -v anigif_files_present ] && {
		stillimage=t
		image=${images[first_existing_index]}
		read -d '' hours minutes seconds attach_audio < <(
			Xdialog --title "Conversion to MP4 – ${BASH_SOURCE##*/}" \
			        --separator $'\n' \
			        --check "Attach an audiofile (and use its length)" \
			        --3spinsbox "Duration" 400x170 \
	    		    0 0010 0 h \
	    	        0 0059 0 m \
			        0 0059 5 s \
			        2>&1
			        # Fields: min max default label
			) || :
		if [ "$attach_audio" ]; then
			# User pressed OK
			if [ "$attach_audio" = checked ]; then
				audio_track=$(Xdialog --title "Choose a track to add – ${BASH_SOURCE##*/}" \
			    	                  --no-buttons \
			    	                  --fselect "${image%/*}" 800x600 \
				                      2>&1)
				[[ "`file -L -b --mime-type "$audio_track"`" =~ ^audio/[^/]+$ ]] || {
					Xdialog --title "Error – ${BASH_SOURCE##*/}" \
					        --backtitle "Not an audio track:"
					        --msgbox "$audio_track" \
					        800x140
					exit 3
				}
				# Audio type confirmed, getting duration.
				set +eE
				traponerr unset
				duration=$(ffprobe -v error -show_format "$audio_track" \
				           |& sed -rn 's/^duration=([0-9]+).*$/\1/p;T;Q5')
				[[ $? -eq 5  &&  "$duration" =~ ^[0-9]+$ ]] || {
					$notify_send "Couldn’t get track duration:" "${audio_track##*/}"
					exit 3
				}
				set -eE
				traponerr set
				m=$(ffprobe -v error -hide_banner \
				            -show_entries format_tags \
				            -of default=noprint_wrappers=1 \
				            "$audio_track" \
				    |& sed -rn "s/'/\\'/g;s/^TAG://g;s/^([^=]+)=(.*)$/[\1]='\2'/p" )
				# I would really like to grab all metadata without eval,
				# but that doesn’t seem possible with ‘declare -An → m’
				eval declare -A metadata=( "$m" )
			else
				duration=$(( ${hours:-0}*60*60 + ${minutes:-0}*60 + ${seconds:-5} ))
				[ $duration -eq 0 ] && {
					$notify_send "Zero length mp4 chosen"
					#$notify_send "Are you dumb ffs"
					exit 3
				}
			fi
		else
			# User pressed Cancel
			$notify_send "Aborted"
			exit 3
		fi
	}
	if [ -v anigif_files_present ]; then
		mp4_type='anigif2mp4'
	elif [ -v stillimage  -a  audio_track ]; then
		mp4_type='one_image_plus_track'
	elif [ -v stillimage ]; then
		mp4_type='one_looped_image'
	#elif [ -v some_time_in_the_future ];then
	#	mp4_type='there will be a proper type for slideshow with audio track'
		# it’s joke
	else
		mp4_type='slideshow'
	fi
}

[[ "$mode" =~ ^(conv2jpeg|pngcomp|glue|conv2mp4)$ ]] && {
	if [ -v force_overwrite ]; then
		overwrite='t'
	else
		Xdialog --title "${BASH_SOURCE##*/}" \
		--ok-label="Overwrite" \
		--cancel-label="Skip, keep the old file" \
		--buttons-style text \
		--yesno "If a file already exists…" 600x100 \
		&& overwrite='t'
	fi
}

# For conv2mp4 we ask separately,
# only on certain conditions.
[[ "$mode" =~ ^(conv2jpeg|glue)$ ]]  && {
	Xdialog --title "${BASH_SOURCE##*/}" \
            --ok-label="Delete" \
            --cancel-label="Keep" \
            --buttons-style text \
            --yesno "Delete source file(s)?" 400x80 \
    && delete_source='t'
}


 # Helper function for conv2jpeg.
#
size_is_valid() {
	local file="$1" size="$2"
	[[ "$size" =~ ^[0-9]+$ ]] || {
		$notify_send 'Failed to get size for' "${file##*/}"
		exit 3
	}
	return 0
}

 # As 4:2:0 YCrCb and thus libx264 cannot work on a source,
#  that has uneven number of pixels in height, we check
#  the image resolution and return an absolute path
#  to a cropped copy. If the height is even, function
#  returns the same path as passed to it.
#
#  P.S. Since we call this function in a subshell,
#       its stderr will be lost along with the messages
#       we send there. Echoing them to stdout would be
#       a bigger mistake, since then the error message
#       will get to the stdout and may be treated
#       as a command. Will be, if there would be newlines.
#  P.P.S. calling ‘exit’ here would be in vain, too, because
#         > subshell.
#
#  $1 – a path to an image to check height for.
#
crop_if_needed() {
	local image="$1" w h ws=0 hs=0 cropped_image
	[ -r "$image" ] || {
		echo "Cannot find image: $image" >&2
		return 3
	}
	read w h < <(identify -format '%w %h\n' "$image" |& head -n1 2>&1)
	[[ "$w" =~ ^[0-9]+$ && "$h" =~ ^[0-9]+$ ]] || {
		cat <<-EOF >&2
		Cannot verify image dimensions for $image
		returned width: $w
		returned height: $h
		EOF
		return 3
	}

	if [ $((h % 2)) -eq 0  -a  $((w % 2)) -eq 0 ]; then
		echo "$image"
		return 0
	else
		let 'h%2 > 0 && h-- && (hs=1), w%2 > 0 && w-- && (ws=1)'
		cropped_image="$tmpdir/${image##*/}"
		convert "$image" \
		        -crop ${w}x$h+$ws+$hs \
		        +repage \
		        "$cropped_image" \
		        || {
			echo -e "Couldn’t crop image with uneven dimensions:\n  $image" >&2
			return 3
		}
		echo "$cropped_image"
	fi
	return 0
}

#
 #  Main functions
 #  They are basically procedures, because there is no sense
 #  in making them standalone things – specifics of working
 #  on bunches of files make us to think about ‘what if’s,
 #  hence these numerous Xdialog’s and checks before the
 #  actual processing. There are too many global things.
#

 # Doesn’t take arguments. It’s basically a procedure.
#
conv2jpeg() {
	log=''
	skipped_because_already_exist=()
	skipped_because_too_small=()
	skipped_because_grayscale=()
	failed_convert_error=()
	failed_blown_size=()
	failed_new_file_unreadable=()
	for image in "${images[@]}"; do
		image_basename="${image##*/}"
		image_bytes=`stat --printf="%s" "$image"`
		size_is_valid "$image" "$image_bytes"
		result_image=${file_path:-${image%/*}}/${image_basename%.*}.jpg
		[ -e "$result_image" ] && {
			# Do not delete the source file by accident
			[ "$image" -ef "$result_image" ] && continue
			# Otherwise remove the destination image
			if [ -v overwrite ]; then
				rm "$result_image"
			else
				# Skipping.
				skipped_because_already_exist+=("$image")
				continue
			fi
		}
		[ -v conv2jpeg_dont_convert_grayscale ] && {
			# Do not convert grayscale images.
			convert "$image" -format '%[colorspace]' info: |& grep -q Gray && {
				skipped_because_grayscale+=("$image")
				continue
			}
		}
		[ "$image_bytes" -le $((conv2jpeg_dont_convert_smaller_than_k*1024)) ] && {
			skipped_because_too_small+=("$image")
			continue
		}
		if convert "$image" -quality ${conv2jpeg_quality:-96} "$result_image"; then
			result_image_bytes=`stat --printf="%s" "$result_image"`
			size_is_valid "$result_image" "$result_image_bytes"
			unset new_file_ok conversion_increased_size
			[[ "`file -L -b --mime-type "$result_image"`" =~ ^image/jpeg$ ]] \
				&& new_file_ok=t \
				|| failed_new_file_unreadable+=("$image")
			[ $result_image_bytes -ge $image_bytes ] \
				&& [ ! -v conv2jpeg_ignore_blown_size ] && {
				conversion_increased_size=t \
				failed_blown_size+=("$image")
			}
			if [ ! -v new_file_ok  -o  -v conversion_increased_size ]; then
				# Conversion didn’t give a readable file
				#   or a file smaller in size than the original.
				# We don’t remove source file in that case.
				rm "$result_image"
			else
				# Conversion created a JPEG file, that is readable
				#   and is smaller in size than the original file.
				# We keep it and check, if user wants the original file
				#   to be deleted.
				[ -v delete_source ] && rm "$image"
			fi
		else
			failed_convert_error+=("$image")
			rm -f "$result_image"
		fi
	done
	[ ${#skipped_because_already_exist[@]} -gt 0 ] && {
		log+=$'\n\n'"Skipped conversion for these files,"
		log+=$'\n'"because the JPEGs already exist and you chose not to overwrite:"$'\n\n'
		for ((i=0; i<${#skipped_because_already_exist[@]}; i++)); do
			log+="    ${skipped_because_already_exist[i]}"$'\n'
		done
	}
	[ ${#skipped_because_too_small[@]} -gt 0 ] && {
		log+=$'\n\n'"Skipped conversion for these files,"
		log+=$'\n'"because they were smaller than the minimum size of ${conv2jpeg_dont_convert_smaller_than_k}k:"$'\n\n'
		for ((i=0; i<${#skipped_because_too_small[@]}; i++)); do
			log+="    ${skipped_because_too_small[i]}"$'\n'
		done
	}
	[ ${#skipped_because_grayscale[@]} -gt 0 ] && {
		log+=$'\n\n\n'"Skipped conversion for these files,"
		log+=$'\n'"because the setting to not convert grayscale images is on:"$'\n\n'
		for ((i=0; i<${#skipped_because_grayscale[@]}; i++)); do
			log+="    ${skipped_because_grayscale[i]}"$'\n'
		done
	}
	[ ${#failed_convert_error[@]} -gt 0 ] && {
		log+=$'\n\n\n'"`which convert` failed for these files:"$'\n\n'
		for ((i=0; i<${#failed_convert_error[@]}; i++)); do
			log+="    ${failed_convert_error[i]}"$'\n'
		done
	}
	[ ${#failed_new_file_unreadable[@]} -gt 0 ] && {
		log+=$'\n\n\n'"Conversion gave unreadable JPEGs for these files:"$'\n\n'
		for ((i=0; i<${#failed_new_file_unreadable[@]}; i++)); do
			log+="    ${failed_new_file_unreadable[i]}"$'\n'
		done
	}
	[ ${#failed_blown_size[@]} -gt 0 ] && {
		log+=$'\n\n\n'"JPEGs turned out to be bigger for these files,"
		log+=$'\n'"so they were untouched:"$'\n\n'
		for ((i=0; i<${#failed_blown_size[@]}; i++)); do
			log+="    ${failed_blown_size[i]}"$'\n'
		done
	}
	[ "$log" ] && Xdialog --title "Conversion results – ${BASH_SOURCE##*/}" --no-cancel \
	                      --textbox - 800x600 <<<"$log"
}

 # Doesn’t take arguments. It’s basically a procedure.
#
conv2mp4() {
	# set -x
	local m artist title ssdir="$tmpdir/slideshow"
	case $mp4_type in
		'one_image_plus_track')
			mp4_filename=${image%.*}.mp4
			# Since ‘Artist – Title.mp4’ would be more convenient,
			# let’s try to look into the metadata we grabbed from $audio_track.
			[ "${metadata[artist]}" -a "${metadata[title]}" ] && {
					mp4_filename="${image%/*}/${metadata[artist]} – ${metadata[title]}.mp4"
					break
				}
			[ -e "$mp4_filename"  -a  ! -v overwrite ] && {
				$notify_send "File exists, skipping" "${mp4_filename##*/}"
				exit 3
			}
			# Notes:
			# 1. Audio track goes as first input – ffmpeg copies metadata
			#    from the first track by default.
			# 2. Loop must be before image (not sure, if eternal loop is
			#    really avoided by -shortest).
			# 3. most players, including HTML5, can’t play anything,
			#    that has chroma subsampling other than YUV 4:2:0.
			# 4. -crf only works with -b:v 0, duh.
			$ffmpeg ${overwrite:+-y} \
			        -i "$audio_track" \
			        -loop 1 \
			        -i "$(crop_if_needed "$image")" \
			        -c:v libx264 -pix_fmt yuv420p -b:v 0 -crf 18 \
			        -c:a aac -b:a 192k \
			        -tune stillimage \
			        -strict experimental \
			        -shortest \
			        -movflags +faststart \
			        "$mp4_filename"
			;;
		'one_looped_image')
			mp4_filename=${image%.*}.mp4
			[ -e "$mp4_filename"  -a  ! -v overwrite ] && {
				$notify_send "File exists, skipping" "${mp4_filename##*/}"
				exit 3
			}
			$ffmpeg ${overwrite:+-y} \
			        -loop 1 \
			        -i "$(crop_if_needed "$image")" \
			        -c:v libx264 -pix_fmt yuv420p -b:v 0 -crf 18 \
			        -tune stillimage \
			        -strict experimental \
			        -movflags +faststart \
			        "$mp4_filename"
			;;
		'slideshow')
			mp4_filename=${images[0]%.*}.mp4
			[ -e "$mp4_filename"  -a  ! -v overwrite ] && {
				$notify_send "File exists, skipping" "${mp4_filename##*/}"
				exit 3
			}
			# This expects, that all the files have same extension!
			glob_pattern='*.'${images[0]##*.}
			for image in "${images[@]}"; do
				# Check for if the passed images are actually images,
				# so we couldn’t get ffmpeg error because of garbage input?
				# [[ "`file -b --mime-type "$image"`" =~ ^image/jpeg$ ]]
				cp "$(crop_if_needed "$image")" "$ssdir"
			done
			pushd "$ssdir"
			$ffmpeg ${overwrite:+-y} \
			        -framerate 25 \
			        -pattern_type glob \
			        -i "$glob_pattern" \
			        -c:v libx264 -pix_fmt yuv420p -b:v 0 -crf 18 \
			        -movflags +faststart \
			        "$mp4_filename"
			popd
			[[ "`file -b --mime-type "$mp4_filename"`" =~ ^video/mp4$ ]] || {
				$notify_send "Conversion to mp4 failed"
				rm -f "$mp4_filename"
				exit 3
			}
			until [ -v ready ]; do
				$media_player "$mp4_filename"
				unset play_again
				play_again=$(
					Xdialog --title "Delete source images? – ${BASH_SOURCE##*/}" \
					        --ok-label "Delete" \
					        --cancel-label="No, keep" \
					        --buttons-style text \
					        --check "Ignore, play the file again" \
					        --yesno "Delete source files?" \
					        600x170 \
					        2>&1
					)
				exit_code=$?
				[ "$play_again" = checked ] && continue || ready=t
				[ $exit_code -eq 0 ] && {
						msg='Really delete?'
						msg+=$'\n'"Bitrate and sound (if any) are OK?"
						msg+=$'\n'"You won’t save a couple of pictures"
						msg+=$'\n'"to post where you can’t post videos?"
						Xdialog --title "Really delete? – ${BASH_SOURCE##*/}" \
					            --ok-label "Everything’s OK, delete" \
					            --cancel-label "No, stop!" \
					            --yesno "$msg" \
					            600x200
					} && {
						# We could use rm "${images[@]}", but the line might
					    #   be too long for rm to handle, this would require xargs.
						for image in "${images[@]}"; do rm "$image"; done \
							&& $notify_send "Source images removed." \
							|| $notify_send "Deletion aborted." # just in case something messes
					                                            # with the file system beside us
					}
			done
			;;
		'anigif2mp4')
			processed_counter=0
			pre_viewer_messages=t
			total="${#images[@]}"
			progress_window_initialise "Converting GIF images"
			for image in "${images[@]}"; do
				path=$image
				subpath=${path%/*}
				file=${path##*/}
				[ "$subpath" = "$file" ] && unset subpath
				[ ${#file} -gt 50 ] && {
					filetail=${file: -10:10}
					file=${file:0:40}…$filetail
				}
				progress_window_upd_text "$file" "$subpath" "$((++processed_counter))/$total"
				echo "$((processed_counter/100*total))%" >$pipe
				mp4_filename=${image%.*}.mp4
				[ -e "$mp4_filename"  -a  ! -v overwrite ] && {
					$notify_send "File exists, skipping" "${mp4_filename##*/}"
					exit 3
				}
				$ffmpeg ${overwrite:+-y} \
				        -i "$(crop_if_needed "$image")" \
				        -c:v libx264 -pix_fmt yuv420p -b:v 0 -crf 18 \
				        -tune stillimage \
				        -strict experimental \
				        -movflags +faststart \
				        "$mp4_filename"
				unset ready
				until [ -v ready ]; do
					[ -v pre_viewer_messages ] \
						&& Xdialog --title "Show original GIF – ${BASH_SOURCE##*/}" \
						           --backtitle "Comparison between GIF and MP4" \
						           --no-cancel \
						           --msgbox "Show the original GIF" \
						           600x170 \
						           2>&1
					$picture_viewer "$image"
					[ $processed_counter -gt 1 ] && checkbox='Don’t show this again'
					[ -v pre_viewer_messages ] && {
						cb_res=$(Xdialog --title "Show the MP4 – ${BASH_SOURCE##*/}" \
						                 --backtitle "Comparison between GIF and MP4" \
						                 --no-cancel \
						                 ${checkbox:+--check "$checkbox"} \
						                 --msgbox "Show the MP4" \
						                 600x170 \
						                 2>&1 )
						[ "$cb_res" = checked ] && unset pre_viewer_messages
					}
					$media_player "$mp4_filename"
					unset play_again
					set +eE
					traponerr unset
					play_again=$(
						Xdialog --title "Delete source image? – ${BASH_SOURCE##*/}" \
						        --backtitle "Image $processed_counter/$total" \
						        --ok-label "Delete" \
						        --cancel-label "Keep / Quit" \
						        --buttons-style text \
						        --check "Ignore, play the file again" \
						        --yesno "Delete source file?" \
						        600x170 \
						        2>&1
						)
					exit_code=$?
					set -eE
					traponerr set
					[ "$play_again" = checked ] && continue || ready=t
					if [ $exit_code -eq 0 ]; then
						rm "$image" \
							&& $notify_send "Source images removed." \
							|| $notify_send "Original file kept."
							# ^-- just in case something messes
							#     with the file system beside us
					else
						if Xdialog --title "Quit now? – ${BASH_SOURCE##*/}" \
						           --backtitle "Image skipped" \
						           --ok-label "Continue" \
						           --cancel-label="Quit" \
						           --buttons-style text \
						           --yesno "$((total-processed_counter)) left. Continue or Quit?" \
						           600x170 \
						           2>&1
						then
							ready=t
						else
							echo 'Aborted' >&2
							$notify_send "Aborted" "${BASH_SOURCE##*/}"
							exit 3
						fi
					fi
				done
			done
			echo 101 >$pipe; wait $xdialog_pid
			;;
	esac
}

 # Doesn’t take arguments. It’s basically a procedure.
#
glue() {
	# Ask whether conversion to jpeg needed
	# Ask about the resulting format: jpg, png, 8-bit/grayscale png
	convert "${images[@]}" -quality 96  -append "${images[0]%/*}/glued_`date +%s`.jpg"
}

 # Doesn’t take arguments. It’s basically a procedure.
#
pngcomp() {
	crush() {
		local path="$1"
		local crushed="$tmpdir/${path##*/}"
		pngcrush -reduce "$path" "$crushed"
		if [ -v overwrite ]; then
			mv "$crushed" "$path"
		else
			mv "$crushed" "${path%.*}.crushed.png"
		fi
	}
	export tmpdir
	[ -v overwrite ] && export overwrite
	export -f crush
	parallel --eta crush ::: "${images[@]}"
	export -fn crush
}

 # Executing the corresponding function.
#
$mode


 # Encoding features, that we cannot enable yet:
#
#  10-bit H264        – FF says ‘file is corrupt’
#  -pix_fmt yuv444p   – FF says ‘file is corrupt’

 # Todo:
#  Adaptive bitrate  – fit more mp3 into size if it’s >192k.
#  -framerate 1/25  – no player would be able to wind
#  -preset veryslow  – m-maybe
#  -vf "scale='min(1280,iw)':-2,format=yuv420p"  – gotta understand how it works first.

