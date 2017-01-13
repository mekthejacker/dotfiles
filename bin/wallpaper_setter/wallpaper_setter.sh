#!/usr/bin/env bash

# wallpaper_setter.sh
# A daemon to set and adjust wallpapers.
# Picks a random image from a directory and sets it as wallpaper.
# Tries to define if the new wallpaper has the same aspect ratio as the screen.
# Can remember history of wallpapers as well as brightness and fill mode chosen
#   for them.
# It accepts commands in runtime, which allows to change its behaviour without
#   restart. It can also restore the state it had when it was terminated, so
#   it’s just suited to be put somewhere in autostart script.
# wallpaper_setter.sh © 2014–2016 deterenkelt

# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3 of the License,
# or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but without any warranty; without even the implied warranty
# of merchantability or fitness for a particular purpose.
# See the GNU General Public License for more details.

# Depends on
# - identify from imagemagick;
# - xrandr;
# - bc;
# - hsetroot (to set wallpapers);
# - Xdialog (required only for GUI directory choosing dialog andinfo window).
# Tested with GNU bash-4.2.45, GNU sed-4.2.1 and GNU grep-2.14.

str="$@"
if [ -v D -a ! -z "$str" ]; then
	[ "${str//*-S*/}" ] && {
		# client
		LOGFILE="$HOME/wallpaper_client.log"
	}||{
		# server
		LOGFILE="$HOME/wallpaper_server.log"
	}
fi

lock=/tmp/wallpaper_setter.lock

show_usage() {
	cat <<-"EOF"
	Usage:

	Starting as daemon:
	./wallpaper_setter.sh -S -d directory [daemon options]

	Sending commands to daemon:
	./wallpaper_setter.sh [client options]

	Get helpful information:
	./wallpaper_setter.sh -h|-H|-v|-i


	Info
	――――
	-i             Shows path to the current wallpaper.
	-h             Shows this help.
	-H             Briefly explains how this script works with examples.
	-v             Prints version and legal information.

	Daemon options
	――――――――――――――
	-S             Starts as a daemon.
	-d directory   Initial directory to search wallpapers for.


	Client options
	――――――――――――――

	-b amount      Sets or adjust brightness  of the current  image.  The value
	               must be enclosed in the range [-1..1]. To increase  or decre-
	               ase brightness,  -  or  +  sign must precede  the value, e.g.
	               -0.2, +0.1 etc.
	-r             Restricts to subdirectory.  Calls GUI interface  with a list
	               of subdirectories  to pick. After  selection wallpapers will
	               be taken  only from selected  directory  (and its subdirecto-
	               ries). This option  also forces  new wallpaper  to be chosen
	               and set  from the new directory.  This  option  implies ‘-u’.
	-R directory   CLI  version  of the above.  Instead  of calling  GUI,  sets
	               restriction to the directory passed as the argument.
	-u             Updates  the internal  list of files in the directory it cur-
	               rently looks for wallpapers.
	-w             Redraws  current  wallpaper.  Useful  in  autostart  scripts,
	               if this script  is left hanging  in the background  for some
	               reason.

	Options for both the daemon and the client
	――――――――――――――――――――――――――――――――――――――――――
	-B amount      Sets  the initial brightness value  for  the next  wallpaper.
	-f             Forces  an action.  At the  current  state  using  this  key
	               in addition  to ‘-n’  will cancel the effect of ‘-k’ and set
	               a new wallpaper.
	-k             Keeps current  wallpaper.  Ignore  commands  that try to set
	               a new wallpaper, i.e. ‘-n’ commands. The main purpose  is to
	               override a cron job that automates changing.
	-l             Sets a limit on the collection size. I.e. the maximum number
	               of images,  that are stored  in history.  Set to 0  in order
	               to make it  unlimited.  If  unset, the  limit  is equal to 5,
	               which is the default.
	-m             Changes mode in which  current  image is shown  on the screen.
	               Available modes  are the ones  ‘hsetroot’ uses:  fill,  full,
	               center and tile.
	-n             Set up the next (random) wallpaper.
	-p             Moves back in the history to previously set wallpaper.
	-q             Be quiet.  Nothing will be printed to the output, so it’d be
	               safe to use in a cron job.
	-s             Scales images that are smaller than screen to fill it (saving
	               proportions), instead of placing them in center in scale 1:1.
	-z directory   Refreshes symbolic link to the current wallpaper in the dire-
	               ctory  on changing.  And if it  doesn’t  exist,  creates one.

	The order of keys is important!
	Report bugs to https://github.com/deterenkelt/dotfiles/issues
	EOF
}

explain_how_this_works() {
	cat <<-"EOF"
	Brief explanation on how it’s supposed to run
	―――――――――――――――――――――――――――――――――――――――――――――
	First, the script must be started in the background with ‘-d’ option,
	specifying the directory containing wallpapers
	    ([nohup] ./wallpaper_setter.sh -d ~/my_favourite_wallpapers) &

	This would be the daemon part. All the calls described below are calls
	to the already running daemon.

	Do not specify the directory for them, as the server already keeps it, and
	specifying one another time will lead to another running server using
	the same pipes and unforseen consequences™.

	Then some jobs may be put in the crontab file (open it with ‘crontab -e’).
	    # To change wallpaper every ten minutes and produce no messages in case
	    # of errors or if current wallpaper must be kept.
	    */10 * * * * /path/to/wallpaper_setter.sh -qn
	    # wallpapers for daytime
	    0 5 * * * /path/to/wallpaper_setter.sh -R ~/daytime_wallpapers/
	    # wallpapers for nighttime
	    0 20 * * * /path/to/wallpaper_setter.sh -R ~/nighttime_wallpapers/
	    # update the list daily
	    0 0 * * * /path/to/wallpaper_setter.sh -u

	Signals
	―――――――
	  This script has two hooks end user may find handy to use:
	  - on SIGUSR1 script will export its data to files.
	  - on SIGUSR2 it will export data and reload itself. For example, if there is
	    a new version then, instead of restarting it manually with typing
	    all the necessary keys or copypasting them, it’s enough to replace
	    the script file and execute
	      pkill -USR2 -f 'wallpaper_setter.sh'
	    or even
	      pkill -USR2 -f wallp
	    if you’re sure it will not kill any other processes.
	EOF
}

show_version() {
	cat <<-EOF
	wallpaper_setter.sh $VERSION
	Copyright © 2014–2016 deterenkelt
	License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
	This is free software: you are free to change and redistribute it.
	There is NO WARRANTY, to the extent permitted by law.
	EOF
}

[ ${BASH_VERSINFO[0]:-0} -eq 4 ] &&
[ ${BASH_VERSINFO[1]:-0} -le 1 ] ||
[ ${BASH_VERSINFO[0]:-0} -le 3 ] && {
	echo "Bash v4.2 or higher required." >&2
	return 3 2>/dev/null || exit 3
}

[ "$BASH_SOURCE" != "$0" ] && {
	echo -e 'This script wasn’t meant to be sourced. See usage (-h).' >&2
	return 4
}

VERSION=20151104

set -f # Don’t mess with my asterisks, dumb bash!
shopt -s extglob

[ -d ~/.wallpaper_setter ] || {
	mkdir ~/.wallpaper_setter || {
		echo "Couldn’t create directory ‘$HOME/.wallpaper_setter’." >&2
		exit 5
	}
}
for pipe in rx tx; do
	[ -p ~/.wallpaper_setter/$pipe ] || {
		mkfifo ~/.wallpaper_setter/$pipe || {
			echo "Couldn’t create pipe ‘$HOME/.wallpaper_setter/$pipe’." >&2
			exit 6
		}
	}
	eval ${pipe}pipe="~/.wallpaper_setter/$pipe"
done
# Otherwise reading directly from the pipe will cause blocks, e.g. SIGTERM trap
#   will may only be able to execute after something will be read from the pipe.
exec {rxpipe_fd}<>$rxpipe
exec {txpipe_fd}<>$txpipe

# $1 – Error message
ermes() {
#	which ${ERR_CMD%% *} &>/dev/null \
	#		&& eval exec `echo "$ERR_CMD" | sed -r "s~([^\])%m~\1${0//\//\\/}: ${1//\//\\/}~"` \
	[ -v BE_QUIET ] || notify-send --hint int:transient:1 -t 3500 -a wallpaper "${0##*/}" "$1"
	echo -e "Error: $1." >&2
}

# $1 – Command to send to the script in background
send_command() {
	[ -v LOGFILE ] && set -x && exec &>$LOGFILE
	local command=$1 try=0 c=0 partial_success success
	# while there are more than 1 clients hanging wait for them to finish.
	# It’s to prevent from simultaneous writing to the rxpipe
	# while [ "`pgrep -cf "wallpaper_setter.sh\s+-[^S]"`" -gt 1 ] \
	# 	  && \
	# 	  [ "`ps -o pid= --sort=lstart -$(pgrep -f "wallpaper_setter.sh\s+-[^S]") | head -n1`" != $$ ]; do
	# 	sleep 15
	# 	[ $((++c)) -gt 4 ] && {
	# 		ermes "Quitting after 1 minute of waiting."
	# 		return 7
	# 	}
	# done
	while [ -e $lock ]; do
		sleep 15
		[ $((++c)) -gt 4 ] && {
			ermes "Quitting after 1 minute of waiting."
			return 7
		}
	done
	touch $lock || exit 3
	trap "rm $lock; trap - RETURN" RETURN
	until [ -v partial_success ]; do
		# Add timestamp as 1st field? Commands may pile up.
		# Add directive to flush buffer on the server side?
		# stamp=$(date +'%-d %b %Y %H:%M:%S' --date=@`date +%s`)
		# echo $stamp $command > $rxpipe
		echo $command > $rxpipe
		read -t 15 -u $txpipe_fd
		[ "$REPLY" = "ACK $command" ] && partial_success=t
		# If not successful, maybe flush tx pipe?
		[ $((++try)) -eq 3 ] && [ ! -v partial_success ] && {
			ermes "$0: Command ‘$command’ wasn’t accepted."
			return 7
		}
	done
	until [ -v success ]; do
		read -t 60 -u $txpipe_fd
		[ "$REPLY" = "DONE $command" ] && success=t
		# If not successful, maybe flush tx pipe?
		[ $((++try)) -eq 3 ] && [ ! -v success ] && {
			ermes "Command ‘$command’ couldn’t complete."
			return 7
		}
	done
	[ -v LOGFILE ] && set +x
	return 0
}

COLLECTION_FILE="$HOME/.wallpaper_setter/collection"

while getopts ':b:B:d:e:fhHikl:mnNpqrR:Sqsuvw' option; do
	case $option in
		b)
			[[ "$OPTARG" =~ ^[-+]?[0-9]\.?[0-9]?$ ]] || {
				ermes "‘-b’: incorrect value for brightness: ‘$OPTARG’."
				exit 8
			}
			send_command "set_brightness $OPTARG" || exit $?
			;;
		B)
			[[ "$OPTARG" =~ ^[-+]?[0-9]\.?[0-9]?$ ]] \
				&& INITIAL_BRIGHTNESS="-brightness $OPTARG" || {
				ermes "‘-B’: incorrect value for brightness: ‘$OPTARG’."
				exit 9
			}
			;;
		d)
			[ -d "$OPTARG" ] && WALLPAPER_DIR="$OPTARG" || {
				ermes "‘-d’: no such directory: ‘$OPTARG’."
				exit 10
			}
			;;
		# e)
		# 	# T! To test passing of the action try these options
		# 	#    -d ~/ -e "echo message: ‘%m’ action: ‘%a’" -d nonexisted_dir
		# 	# This should output
		# 	# message: ‘./.i3/wallpaper_setter.sh: No such dir: nonexisted_dir.’
		# 	# action: ‘./.i3/wallpaper_setter.sh  "-d"  "/home/user/"  "-e"
		# 	#          "echo -e \"message: ‘%m’\naction: ‘%a’\""  "-d"
		# 	#          "nonexisted_dir" ’
		# 	[ "$OPTARG" ] || {
		# 		echo 'Please set an error reporting utility via ‘-e’ option.' >&2
		# 		exit 11
		# 	}
		# 	for param in "$@"; do
		# 		# 4×\ per 3×escaping = 1×\ as it was on output like in ‘\n’
		# 		param="${param//\\/\\\\\\\\\\\\}"
		# 		# ———"——— for ‘"’ to become ‘\’+‘"’
		# 		param="${param//\"/\\\\\\\\\\\\\\\"}"
		# 		param=${param//\//\\\/}
		# 		param=${param//\'/\\\'}
		# 		param=${param//\&/\\\&}
		# 		param=${param//\%/\\\%}
		# 		# Array would be nicer here, but it messes with quotes adding
		# 		#   its own, so it’s better to make it just a string.
		# 		params="$params \\\\\"$param\\\\\" "
		# 	done
		# 	ERR_CMD=`echo -n "$OPTARG" |\
		# 	         sed -r "s/%a/${0//\//\\\/} ${params} \&/g"`
		#	;;
		f)
			FORCE_COMMANDS=t
			;;
		h)
			show_usage
			exit 0
			;;
		H)
			explain_how_this_works | $PAGER
			exit 0
			;;
		i)
			send_command 'show_current_image_path' || exit $?
			;;
		k)
			send_command 'keep_current_wallpaper' || exit $?
			;;
		l)
			[ "$OPTARG" =~ ^[0-9]+$ ] && COLLECTION_LIMIT=$OPTARG || {
				ermes "‘-l’: ‘$OPTARG’ must be a number."
				exit 12
			}
			;;
		m)
			send_command 'change_fill_mode' || exit $?
			;;
		n)
			[ -v BE_QUIET ] && {
				send_command 'next_command_be_quiet' || exit $?
			}
			if [ -v FORCE_COMMANDS ]; then
				send_command 'force_next_wallpaper' || exit $?
			else
				send_command 'next_wallpaper' || exit $?
			fi
			;;
		p)
			send_command 'previous_wallpaper' || exit $?
			;;
		q)
			BE_QUIET=t
			[ -v LOGFILE ] || exec >/dev/null 2>&1
			;;
		r)
			send_command 'restrict_to_directory' || exit $?
			;;
		R)
			[ -d "$OPTARG" ] || {
				ermes "No such directory: ‘$OPTARG’."
				exit 13
			}
			send_command "restrict_to_directory $OPTARG" || exit $?
			;;
		s)
			SCALE_DONT_CENTER=t
			;;
		S)
			SERVER=t
			;;
		u)
			send_command 'update_list' || exit $?
			;;
		v)
			show_version
			exit 0
			;;
		w)
			send_command 'redraw_wallpaper' || exit $?
			;;
		z)
			[ -d "$OPTARG" ] && LINK_DIR="$OPTARG" || {
				ermes "-z option requires a directory as an argument."
				exit 38
			}
			;;
		N) # FOR TEST PURPOSES ONLY
			send_command 'hang_forever' || exit $?
			;;
		\?)
			ermes "Invalid option: ‘-$OPTARG’."
			exit 14
			;;
		:)
			ermes "Option ‘-$OPTARG’ requires an argument."
			exit 15
			;;
	esac
done

# I wanted the client to accept multiple commands at once, e.g. -fnk
# This is what this variable is needed for — to be sure script will exit before
#   it will start a server.
[ -v SERVER ] || exit 0

# If the execution went here, it means we’re running in the background.
#   Only -d, -e, -s and -l options may be set
[ -v WALLPAPER_DIR ] && cd "$WALLPAPER_DIR" || {
	show_usage
	exit 16
}

import_collection() {
	[ -r $COLLECTION_FILE.rc ] && {
		local counter=0
		while IFS= read -r -d $'\0'; do
			case $((counter++)) in
				0)
					[ -d "$REPLY" ] && cd "$REPLY"
					;;
				1)
					[[ "$REPLY" =~ ^[0-9]+$ ]] && c_index="$REPLY"
					;;
				2)
					[ "$REPLY" = keep ] && KEEP_CURRENT_WALLPAPER=t
					;;
			esac
		done < <(cat $COLLECTION_FILE.rc \
			| sed -rn '1h; 2,$ H; ${g; s/^(.*)\n([^\n]+)\n([^\n]+)$/\1\x00\2\x00\3\x00/g; p}')
		set +f
		ls $COLLECTION_FILE.+([0-9]) &>/dev/null && {
			for f in $COLLECTION_FILE.+([0-9]); do
				[ -r "$f" ] \
					&& local lines=`wc -l <"$f"` \
					&& [[ "$lines" =~ ^[0-9]+$ ]] \
					&& [ $lines -ge 2 ] \
					&& local index=${f##*.} && {
					collection[index]="`<$f`"
				} || ermes "Collection file ‘$f’ cannot be read or is broken."
			done
		}
		set -f
	}
	[ -v c_index ] || c_index='-1'
}

# $1 — index of the item to update
update_in_collection() {
	collection[$1]="$image
$fillmode
$brightness"
	return 0
}

# $1 — index of the item to restore
restore_from_collection() {
	local field_number=0 idx=$1
	unset image fillmode brightness
	while IFS= read -r -d $'\0' data; do
		case $((field_number++)) in
			0)
				[ -r "$data" ] && image="$data"
				;;
			1)
				[[ "$data" == -@(center|tile|fill|full) ]] \
					&& fillmode="$data"
				;;
			2)
				[[ "$data" =~ ^-brightness\ [-+]?[0-9]\.?[0-9]?$ ]] \
					&& brightness="$data"
				;;
		esac
	done < <(echo -n "${collection[idx]}" \
		| sed -rn '1h; 2,$ H; ${g; s/^(.*)\n([^\n]+)\n([^\n]+)$/\1\x00\2\x00\3\x00/g; p}')
	# This way it should work even if ${collection[$1]} expands
	#   to only one line (or no lines).
	[ -v fillmode ] || fillmode='-full'
	[ -v brightness ] || brightness='-brightness 0'
	[ -v image ] && {
		hsetroot $fillmode "$image" $brightness || return $?;
	}|| hsetroot -solid "#efefef" || return $?
	return 0
}

export_collection() {
	local keep
	set +f
	rm $COLLECTION_FILE.* 2>/dev/null
	set -f
	for ((i=0; i<${#collection[@]}; i++)); do
		echo -n "${collection[$i]}" > "$COLLECTION_FILE.$i"
	done
	[ -v KEEP_CURRENT_WALLPAPER ] \
		&& keep='keep' \
		|| keep='don’t keep'
	echo -n "$PWD
$c_index
$keep" > "$COLLECTION_FILE.rc"
}

update_list() {
	unset wlps_list
	# FIXME: identify returns dimensions per each frame of animated gif.
	local matchext="png jpg jpeg jpe tiff"
	local ext=`echo "$matchext" |\
	           sed -r 's/\s/ -o /g; s^([a-zA-Z0-9_-]{3,})^-iname *.\1^g'`
	while IFS= read -r -d $'\0' fname; do
		wlps_list[${#wlps_list[@]}]="$fname"
	done < <(find -P . \( $ext \) -print0)
	[ ${#wlps_list[@]} -eq 0 ] && {
		ermes "No images in ‘$PWD’ to be set as wallpaper!"
	}
	return 0
}

# EXPECTS:
#   image — absolute path to an image.
# SETS:
#   fillmode — one of modes that hsetroot accepts.
test_image() {
	read i_width i_height < <(identify -format "%W %H" "$image")
	[[ "$i_width" =~ ^[0-9]+$ ]] || return 3
	[[ "$i_height" =~ ^[0-9]+$ ]]	|| return 4
	# Experimental: if one of the dimensions of the image is more than
	#   three times greater than the one of the screen, it doesn’t suit us.
	[ $((i_width/s_width)) -ge 3 ] && return 5
	[ $((i_height/s_height)) -ge 3 ] && return 6
	# If one of the dimensions of the image is greater than the one
	#   of the screen, force -fill fillmode.
	if [ $i_width -gt $s_width -o $i_height -gt $s_height ]; then
		fillmode='-full'
	else # It is equal in size or smaller than the screen
		i_aspect_ratio=`echo "scale=2;$i_width/$i_height" | bc -q` && {
			[ "$s_aspect_ratio" = "$i_aspect_ratio" ] \
				&& fillmode='-fill' \
				|| {
				[ -v SCALE_DONT_CENTER ] \
					&& fillmode='-full' \
					|| fillmode='-center'
			}
		} || return 7 # couldn’t calculate image aspect ratio
	fi
	return 0
}

next_wallpaper() {
	if [ ${#wlps_list[@]} -eq 0 ]; then
		ermes "No wallpapers. Did you try to update the list?"
		return 33
	else
		[ $((++c_index)) -lt ${#collection[@]} ] \
			&& restore_from_collection $c_index \
			|| {
			# Find new random image that wouldn’t be among those which are
			#   already in collection.
			local try=0
			until [ -v unique ]; do
				local unique=t
				image="${wlps_list[$((RANDOM%${#wlps_list[@]}))]}"
				for ((i=-1; i<${#collection[@]}; i++)); do
					[ "$image" = "`echo -n "${collection[$((i+1))]}" | sed -rn '1h; 2,$ H; ${g; s/^(.*)\n[^\n]+\n[^\n]+$/\1/g; p}' `" ] && unset unique
					if [ $((i+1)) -eq ${#collection[@]} ]; then
						# What to do if the image has been already set
						#   1..$COLLECTION_LIMIT times ago?
						[ -v unique ] && test_image && break 2 || {
							unset unique # cause we need to try more.
							[ $((++try)) -eq ${#collection[@]} ] && {
								# If we can’t try more (in case the count
								#   of images in currently selected folder
								#   is below $COLLECTION_LIMIT), or
								#   COLLECTION_LIMIT is set to unlimited…
								c_index=$((RANDOM%${#collection[@]}))
								restore_from_collection $c_index || return $?
								return 0
								# This way we can also restore the preferences
								#   user has assigned to that image!
							}
							## II. just set it if it has passed the test?
							# && [ -v passed_the_test ] && unique=t
							## III. return?
							# && return
							## IV. throw an error?
							# && {
							# 	ermes "Couldn’t pick new wallpaper after $try tries."
							# 	exit 17
							# }
						}
					fi
				done
			done

			brightness=${INITIAL_BRIGHTNESS:--brightness 0} # fillmode is already set by test_image()
			[ ${#collection[@]} -lt $COLLECTION_LIMIT ] \
				&& update_in_collection ${#collection[@]} \
				|| {
				for ((i=1; i<${#collection[@]}; i++)); do
					collection[$((i-1))]=${collection[$i]}
				done
				update_in_collection $((i-1))
				let c_index--
			}
			hsetroot $fillmode "$image" $brightness
			[ -v LINK_DIR ] && ln -sf "$image" "$LINK_DIR/"
		}
	fi
	return 0
}

change_fill_mode() {
	local modes=(-fill -full -center -tile)
	for ((i=0; i<${#modes[@]}; i++)); do
		[ $fillmode = ${modes[$i]} ] && let ++i && break
	done
	[ $i -eq ${#modes[@]} ] && let i=0
	fillmode=${modes[$i]}
	hsetroot $fillmode "$image" $brightness || return $?
	update_in_collection $c_index || return $?
}

# $1 — brightness amount (see usage above)
set_brightness() {
	new_br="$1"
	old_br="${brightness#* }"
	[[ "$new_br" =~ ^[-+] ]] && { # need to adjust first
		# Strange is…
		# If result for new_br="`…`" ← is enclosed in quotes, it equals to zero
		#   instead of ‘thats_bad’
		new_br=`echo "scale=1; a=$old_br $new_br;
			if (a>=-1 && a<=1) print a else print \"thats_bad\"" \
			| bc -q | sed -r 's/^([-+]?)(\.[0-9])$/\10\2/'`
		[ "$new_br" = thats_bad ] && set +x && return 3
	}
	brightness="-brightness $new_br"
	hsetroot $fillmode "$image" $brightness || return $?
	update_in_collection $c_index
}

previous_wallpaper() {
	[ $c_index -ne -1 ] && {
		[ $((--c_index)) -lt 0 ] && c_index=0
		restore_from_collection $c_index || return $?
	}
	return 0
}

# $1 — Directory to restrict search to.
restrict_to_directory() {
	cd "$1"
	update_list
	c_index=-1
	collection=()
	next_wallpaper
}

# Creating collection.
# It supposed to be a list of cherry-picked wallpapers which user places
#   here by calling KEEP_CURRENT_WALLPAPER while in some kind of collection-fill
#   mode that is not implemented yet.
# As for now it is just list of five previously set wallpapers with ability
#   to move backwards and forwards on that list.
[ -v COLLECTION_LIMIT ] || COLLECTION_LIMIT=5
[ $COLLECTION_LIMIT -eq 0 ] && COLLECTION_LIMIT=8192 \
	|| { [ $? -eq 2 ] && COLLECTION_LIMIT=8192; }
collection=()

read s_width s_height <<< `xrandr | \
	sed -nr 's/^\s+([0-9]+)x([0-9]+).*\*.*/\1\n\2/p;T;Q0'`
[[ "$s_width" =~ ^[0-9]+$ ]] || {
	ermes 'Couldn’t retrieve screen width.'
	exit 18
}
[[ "$s_height" =~ ^[0-9]+$ ]]	|| {
	ermes 'Couldn’t retrieve screen height.'
	exit 19
}
s_aspect_ratio=`echo "scale=2;$s_width/$s_height" | bc -q` || {
	ermes 'Couldn’t calculate screen aspect ratio.'
	exit 20
}

import_collection
[ $c_index -gt -1 ] && restore_from_collection $c_index
# Cheking a big folder may take a long time, so let faster necessary checks
#   and restoring old image be first.
update_list

trap "export_collection;
      exec {rxpipe_fd}<&-;
      exec {txpipe_fd}<&-;
      exit 0;" HUP TERM INT QUIT KILL

trap "export_collection" USR1

trap 'export_collection;
      exec {rxpipe_fd}<&-;
      exec {txpipe_fd}<&-;
      "$0" "$@" &
      exit 0;' USR2

while read -u $rxpipe_fd; do
	[ -v LOGFILE ] && set -x && exec &>$LOGFILE
	[ -v NEXT_COMMAND_BE_QUIET ] && {
		[ -v BE_QUIET ] || wasnt_quiet=t
		BE_QUIET=t
	}
	case "$REPLY" in
		change_fill_mode)
			echo "ACK $REPLY" > $txpipe
			# No need to set KEEP_CURRENT_WALLPAPER since there will be no read
			#   from the rx pipe until this function finishes.
			change_fill_mode &&	echo "DONE $REPLY" > $txpipe
			;;
		force_next_wallpaper)
			echo "ACK $REPLY" > $txpipe
			unset KEEP_CURRENT_WALLPAPER
			next_wallpaper && echo "DONE $REPLY" > $txpipe
			;;
		keep_current_wallpaper)
			echo "ACK $REPLY" > $txpipe
			KEEP_CURRENT_WALLPAPER=t
			[ -v BE_QUIET ] || notify-send --hint int:transient:1 -t 3500 "${0##*/}" "Keeping current wallpaper."
			echo "DONE $REPLY" > $txpipe
			;;
		next_command_be_quiet)
			echo "ACK $REPLY" > $txpipe
			NEXT_COMMAND_BE_QUIET=t
			echo "DONE $REPLY" > $txpipe
			;;
		next_wallpaper)
			echo "ACK $REPLY" > $txpipe
			if [ -v KEEP_CURRENT_WALLPAPER ]; then
				ermes "Keeping current wallpaper. Call with -f to force change."
				echo "DONE $REPLY" > $txpipe
			else
				next_wallpaper && echo "DONE $REPLY" > $txpipe
			fi
			;;
		previous_wallpaper)
			echo "ACK $REPLY" > $txpipe
			previous_wallpaper && echo "DONE $REPLY" > $txpipe
			;;
		restrict_to_directory)
			echo "ACK $REPLY" > $txpipe
			dir="`Xdialog --no-buttons \
			          --title 'Where shall I take wallpapers?' \
			          --backtitle 'Where shall I take wallpapers?' \
			          --dselect \"$PWD\" $((WIDTH-200))x$((HEIGHT-100)) 2>&1`" \
			    && [ -d "$dir" ] && restrict_to_directory "$dir" \
			    && echo "DONE $REPLY" > $txpipe
			export_collection
			;;
		show_current_image_path)
			echo "ACK $REPLY" > $txpipe
			Xdialog --infobox "$image" 0x0 4000
			echo "DONE $REPLY" > $txpipe
			;;
		update_list)
			echo "ACK $REPLY" > $txpipe
			update_list && echo "DONE $REPLY" > $txpipe
			;;
		redraw_wallpaper)
			echo "ACK $REPLY" > $txpipe
			hsetroot $fillmode "$image" $brightness \
				&& echo "DONE $REPLY" > $txpipe
			;;
		hang_forever) # for test purposes
			echo "ACK $REPLY" > $txpipe
			while true; do sleep 1; done
			;;
		*)
			if grep -qE "^restrict_to_directory\s.+$" <<< "$REPLY"; then
				echo "ACK $REPLY" > $txpipe
				dir="`echo "$REPLY" | sed -r 's/^\S+\s(.*)$/\1/'`"
				if [ -d "$dir" ]; then
					restrict_to_directory "$dir"
				else
					ermes "Couldn’t set scope to ‘$restricted_dir’: no such directory."
				fi
				echo "DONE $REPLY" > $txpipe
			elif grep -qE "^set_brightness\s[-+]?[0-9]\.?[0-9]?$" <<< "$REPLY"; then
				echo "ACK $REPLY" > $txpipe
				set_brightness ${REPLY#* } \
					&& echo "DONE $REPLY" > $txpipe \
					|| echo "Couldn’t adjust brightness." >&2 >& $txpipe
			else
				echo "Unrecognized command: ‘$REPLY’." > $txpipe
			fi
			;;
	esac
	[ -v wasnt_quiet ] && {
		unset NEXT_COMMAND_BE_QUIET BE_QUIET wasnt_quiet
	}
	export_collection  # to have settings saved in case of sudden power loss
done
