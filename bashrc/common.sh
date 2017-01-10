#
 #  Various functions that make the life easier. Kind of an addition to ~/bin.
#

# Viruses writers don’t expect that.
alias firefox='firefox --profile ~/.ff'
alias imgur="~/bin/imgur_upload.sh"
#
 #  Managing two git repos for ~/, dotfiles is public.
#

alias dotgit="`which git` --work-tree $HOME --git-dir $HOME/dotfiles.git"
alias gengit="`which git` --work-tree $HOME --git-dir $HOME/general.git"

# DESCRIPTION:
#     Overriding git for $HOME to maintain configs in one public (dotiles)
#     and one private (general) repo.
git() {
	[ "$PWD" = "$HOME" ] && {
		local opts="--work-tree $HOME --git-dir dotfiles.git" doton=t genon= left=$'\e[D' right=$'\e[C' input_is_ready
		until [ -v input_is_ready ]; do
			echo -en "Which repo would you like to operate on? ${doton:+\e[32m}dotfiles${doton:+\e[0m <} ${genon:+> \e[32m}general${genon:+\e[0m} "
			read -sn1
			[ "$REPLY" = $'\e' ] && read -sn2 rest && REPLY+="$rest"
			[ "$REPLY" ] && {
				case "$REPLY" in
					"$left")
						opts="--work-tree $HOME --git-dir dotfiles.git"
						doton=t; genon=
						;;
					"$right")
						opts="--work-tree $HOME --git-dir general.git"
						doton=; genon=t
						;;
				esac
				echo -en "\r\e[K" # \K lear line
			}||{
				echo
				input_is_ready=t
			}
		done
	}
	`which git` $opts "$@"
}

# DESCRIPTION:
#     Check if a file in $HOME is in dotfiles of general repo,
# TAKES:
#     $1 — file path under $HOME
isinrepo() {
	[ "$*" ] || {
		echo -e "Usage:\t${FUNCNAME[0]} $HOME/…/<filename>\n"
		return
	}
	local found
	[ "`dotgit ls-files "$1"`" -ef "$1" ] \
		&& echo "$@: Found in dotfiles." && found=t
	[ "`gengit ls-files "$1"`" -ef "$1" ] \
		&& echo "$@: Found in general." && found=t
	[ -v found ] || {
		echo "$@: Not found."
		return 3
	}
}

at-msg() {
	local when msg
	read -p "Examples: ‘+10 mins’, ‘19:30’."$'\n'"When? > " when
	read -p "Text message: > " msg
	date --date="$when" +"%H:%M" >/dev/null || return 4

	at "`date --date="$when" +"%H:%M"`" \
	     <<<"mpc |& sed -n '2s/playing//;T;Q1' || {
	             mpc pause                     >/dev/null
	             echo '{ \"command\": [\"set_property\", \"pause\", true] }' | socat - ~/.mpv/socket
	             echo '{ \"command\": [\"set_property\", \"fullscreen\", false] }' | socat - ~/.mpv/socket
	             aplay ~/.env/Tutturuu_v2.wav  >/dev/null
	             mpc play                      >/dev/null
	         }
	         DISPLAY=$DISPLAY Xdialog --msgbox \"\n   $msg   \n\" 200x100"
	# Should add exit fullscreen command for mpv.
	# See JSON IPC for mpv.
	# 1. find an mpv instance (by WM_CLASS? or from the list of X windows? i3 workspace windows?)
	# 2. find whether the current mpv instance is in fullscreen mode
	# 3. if it is, then send a command to socket to exit fullscreen.
	# For #3 to work IPC socket path should be added to the mpv config.
}

# DESCRIPTION:
#     Takes a magnet link and places a .torrent file made of it to a directory.
#     USeful for rtorrent
# TAKES:
#   $1 — magnet link
#   $2 — path to resulting .torrent file
magnet-to-torrent() {
	[ -z "$*" -o $# -ne 2 ] && {
		cat <<EOF
Usage: magnet-to-torrent <magnet link> <new file path>
EOF
		return
	}
	[[ "$1" =~ xt=urn:btih:([^&/]+) ]] || {
		echo 'Invalid magnet link!' >&2
		return 3
	}
	[ -d "${2%/*}" ] || {
		echo "No such directory: ${2%/*}" >&2
		return 4
	}
	echo "d10:magnet-uri${#1}:${1}e" > "$2"
	echo "Copied to $2"
}

# Compresses all png files in CWD
# $1 — minimum size, under which no compression shall be done
#      If not set 1M (1MiB) is the default.
compress-screenshot() {
	[ "$1" ] && {
		[[ "$1" =~ ^[0-9]+[KMG]$ ]] && min_size=${1/K/k} \
			||{ echo "The parameter should conform to that pattern: [0-9]+[KMG]." >&2; return 3; }
	}|| min_size=1M
	crush() {
		which pngcrush &>/dev/null && {
			pngcrush -reduce "$1" "/tmp/$1"
			mv "/tmp/$1" "$1"
		}
	# which convert &>/dev/null && [ -v JPEG_CONVERSION ] && {
	# 	convert "$shot" -quality $JPEG_CONVERSION "${shot%.*}.jpg"
	# 	rm "$shot"
	# }
	}
	export -f crush
	find  -iname "*.png" -size +$min_size -printf "%f\n" | parallel --eta crush
	export -nf crush
}

# Copies current MPD playlist to a specified folder.
copy-playlist() {
	err() { echo "$1" >&2; [ "$2" ] && return $2; }  # $1 — message; $2 — return code
	local cur_pl='current' dest="$HOME/desktop/music/" \
		  pl_dir pl library_path got_a_sane_reply
	pl_dir=`sed -nr 's/^\s*playlist_directory\s+"(.+)"\s*$/\1/p' ~/.mpd/mpd.conf`
	[ "$pl_dir" ] || err 'mpd.conf doesn’t have playlist_directory?' 3
	library_path=`sed -nr 's/^\s*music_directory\s+"(.+)"\s*$/\1/p' ~/.mpd/mpd.conf`
	library_path="${library_path/#\~/$HOME}"
	rm -r $dest/*
	eval [ -d "$pl_dir" ] \
		|| err 'Playlist directory is indeterminable.' 4
	eval [ -d "$library_path" ] \
		|| err 'Path to music library is indeterminable.' 5
	# [ "$*" ] && dest="$*" || {
	# 	dest="$HOME/phone_card"
	# 	disk=`sudo /sbin/findfs LABEL=PHONE_CARD` \
	# 		&& sudo /bin/mount -t vfat -o users,fmask=0111,dmask=0000,rw,codepage=866,iocharset=iso8859-5,utf8 $disk $HOME/phone_card \
	# 			|| return `err "Default destination PHONE_CARD cannot be found." 7`
	# }
	eval pushd $pl_dir
	rm -vf $cur_pl.m3u
	mpc save "$cur_pl"  # MPD_HOST must be set in the environment
	[ -f "$cur_pl.m3u" ] || err 'Playlist wasn’t saved' 6
	[ -w "$dest" ] && {
		while read filepath; do
			filepath="${filepath/$library_path/}"
			cp -v  "$library_path/$filepath" "$dest" || {
				unset got_a_sane_reply
				until [ -v got_a_sane_reply ]; do
					read -n1 -p 'Error on copying. Continue? [Y/n] > '; echo
					case "$REPLY" in
						y|Y|'') got_a_sane_reply=t;;  # And skip further messages
						n|N) break 2;;
						*) echo 'Y or N.';;
					esac
				done
			}
		done < "$cur_pl.m3u"
		popd
	}||{ popd; err "Destination dir ‘$dest’ is not writable." 7; }

    # [ "$dest" = "$HOME/phone_card" ] && {
	# 	sudo /bin/umount "$dest"
	# 	rm -rf "$dest"
	# }
}

# $1 — filename to fix figure dashes in
fix-fdash() {
	[ -w /tmp/c ] && sed -ri 's/^- (.*)$/‒ \1/g' /tmp/c
}

mount-box() {
	gpg -qd --output /tmp/decrypted/secrets.`date +%s` ~/.davfs2/secrets.gpg
	sudo /root/scripts/mount_box.sh $USER &
}

umount-box() {
	sudo /root/scripts/mount_box.sh $USER umount &
}

# TAKES:
#     $1 — file name to upload.
spr() {
	[ -r "$1" ] || {
		echo 'Pass a file name to paste.'
		return 3
	}
	#firefox http://sprunge.us/aXZI?py#n-7
	curl -F 'sprunge=<-' http://sprunge.us <"$1" \
		| perl -p -e 'chomp if eof' | tee /dev/tty | xclip
	echo
}


# TAKES:
#     $1 — file to encrypt. Encrypted version will be palced along with it.
gpg-enc() {
	GTK_IM_MODULE= QT_IM_MODULE= gpg \
		--batch -se --output $1.gpg --yes -R *$ME_FOR_GPG $1
}

# Check unicode symbols
chu() { echo -n "$@" | uniname; }  # from uniutils package

arecord-mixed() {
	set -x
	sudo /sbin/modprobe snd_aloop
	# Applications which sound is to be recorded may need to be restarted.
	cp ~/.asoundrc.mix ~/.asoundrc
	# 2 is the number of the Loopback card.
	arecord -D "hw:2,1" -f cd -t wav /tmp/s.wav
	rm  ~/.asoundrc
	sudo /sbin/modprobe -r snd_aloop
	set +x
}

# DESCRIPTION
#    Records sound from microphone and converts it to mp3
rec() {
	local ts
	ts=`date +%s`
	arecord -f cd -t wav /tmp/$ts.wav
	ffmpeg -i /tmp/$ts.wav -codec:a libmp3lame -qscale:a 0 /tmp/$ts.mp3
	echo -n /tmp/$ts.mp3 | xclip
}

fpic() { find /home/picts -iname "*$@*"; }

# DESCRIPTION:
#     Adds all hosts in a given subnet to the java exception site list.
# TAKES:
#     $1 — A net address without the last octet, 192.168.2 for example.
java-site-exception() {
	local exception_list=$HOME/.java/deployment/security/exception.sites \
	      exceptions o site e match c
	exceptions=(`<$exception_list`)
	[[ "$1" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || {
		echo "Usage:    ${FUNCNAME[0]} 192.168.2" >&2
		return
	}
	c=0
	for o in {1..254}; do
		for site in "https://$1.$o/" "http://$1.$o/"; do
			unset match
			for e in ${exceptions[@]}; do
				[ "$site" = "$e" ] && match=t
			done
			[ -v match ] || {
				echo "$site" >>$exception_list
				let c++
			}
		done
	done
	echo "Added $c hosts."
}
# Thanks, Krishna!


ffmpeg-webm-from-one-picture() {
	set -x
	ffmpeg -y -i "$1" -i "$2" -c:v libvpx  -c:a libvorbis -b:a 192k -tune stillimage -strict experimental "$3.webm"
	set +x
}

 # Forwards local ports via $1 to $2.
#
ssh-ipmi() {
    local gw=$1 ipmi=$2 found
    case "$mode" in
    	''|ipmi)
			# 80, 443 – webiface
			# 623 – java?
			# 5900 – virtual disk I/O?
			ports=(80 443 623 5900)
    		;;
		ilo)
			# 80, 443 – webiface
			# 763 – moonshot cartridge iLO
			# 17988 – java?
			# 17990 – virtual disk I/O?
			ports=(80 443 763 17988 17990)
			;;
	esac
    # We’d usually want to bind $ipmi to a local address, such as 127.0.0.x,
    # with the last octet of $ipmi left as is.
    o=${ipmi##*.}
    pgrep -f "ssh.*-L\s*127\.0\.0\.$o:" &>/dev/null && {
        # Our preferred octet is occupied, looking for the first available.
        for ((i=0; i<255; i++)); do
            for ((j=1; j<254; j++)); do
                [ $i -eq 0 -a $j -eq 1 ] && continue  # skip for 127.0.0.1:80
                pgrep -f "ssh.*-L\s*127\.0\.$i\.$j:" &>/dev/null || {
                    found=t
                    break 2
                }
            done
        done
        [ -v found ] || {
            echo 'Error: Couldn’t find a free address in 127.0/16.' >&2
            return 3
        }
        local_addr=127.0.$i.$j
        :
    }|| local_addr=127.0.0.$o
    ssh -Nf -C $gw -L $local_addr:${ports[0]}:$ipmi:${ports[0]} \
                   -L $local_addr:${ports[1]}:$ipmi:${ports[1]} \
                   -L $local_addr:${ports[2]}:$ipmi:${ports[2]} \
                   -L $local_addr:${ports[3]}:$ipmi:${ports[3]}
    pgrep -af "ssh.*$gw\s+-L\s*$local_addr:.*:$ipmi:"
}
ssh-clear() { pkill -9 -f "ssh.*-L.*"; }
ssh-ilo() { mode=ilo ssh-ipmi "$@"; }
ssh-moonsht-ilo() { mode=moonsht-ilo ssh-ipmi "$@"; }

 # Creates a backup of ~/.ff
#
firefox-backup() {
	echo 'Make sure you have uninstalled all old add-ons!'
	# Clean the cache
	rm -rf ~/.ff/cache2/*
}

 # Creates a video from a picture and an audio file
#  $1 – a picture
#  $2 – an audio file
#
ffmpeg-1-picture() {
	webm_name=`basename "$2"`
	ffmpeg -y -i "$1" -c:v libvpx-vp9 -b 5000k -an -aq-mode 0 \
	       -pass 1 -speed 4 -threads 1 -tile-columns 0 -frame-parallel 0 \
	       -g 9999 -tune stillimage -strict experimental -f webm /dev/null \
	&& ffmpeg -y -i "$1" -i "$2" -c:v libvpx-vp9 -b:v 5000k -c:a libvorbis -b:a 192k \
	          -pass 2 -speed 0 -threads 1 -tile-columns 0 -frame-parallel 0 \
	          -auto-alt-ref 1 -lag-in-frames 25 -tune stillimage -strict experimental "${webm_name%.*}.webm"
}

 # $1 – filename
#
update-version() {
	set -x
	[ -w "$1" ] || {
		echo "$1 is not a writeable file!" >&2
		exit 3
	}
	sed -ri "s/^VERSION=(\'|\").*(\'|\")\s*/VERSION='`date +%Y%m%d-%H%M`'/" "$1"
	set +x
}

rec-my-desktop-nobar() { rec-my-desktop nobar; }
rec-my-desktop-nobar-audio() { rec-my-desktop nobar audio; }
rec-my-desktop-audio() { rec-my-desktop audio; }
rec-my-desktop-audio-nobar() { rec-my-desktop audio nobar; }
 # Records desktop with ffmpeg
#  TAKES:
#    rec-my-desktop [nobar] [audio] [crf0|crf18|bv1m|bv2m|bv3m|bv4m]
rec-my-desktop() {
	set -x
	local adj w h audio bitrate \
	      crf0=' -b:v 0 -crf 0 ' \
	      crf18=' -b:v 0 -crf 18' \
	      bv1m=' -b:v 1000k ' \
	      bv2m=' -b:v 2000k' \
	      bv3m=' -b:v 3000k' \
	      bv4m=' -b:v 4000k'
	# If we don’t want i3bar to get in the video
	[ "$1" = nobar ] && { adj='+0,25'; shift; }
	[ "$1" = audio ] && { audio='-f alsa -ac 2 -i hw:0 -async 1 -acodec pcm_s16le'; shift; }
	# If we use adjustment, height must be decreased accordingly
	[ -v adj ] && h=$((HEIGHT - 25)) || h=$HEIGHT  # I set WIDTH and HEIGHT in ~/.preload.sh
	w=$WIDTH  # width is WIDTH anyway
	if   [ "$1" = crf0 ]; then bitrate=$crf0
	elif [ "$1" = crf18 ]; then bitrate=$crf18
	elif [ "$1" = bv1m ]; then bitrate=$bv1m
	elif [ "$1" = bv2m ]; then bitrate=$bv2m
	elif [ "$1" = bv3m ]; then bitrate=$bv3m
	elif [ "$1" = bv4m ]; then bitrate=$bv4m
	else
		[ $h -ge 720 ] && bitrate=$bv2m || bitrate=$bv1m
	fi
	ffmpeg -y -f x11grab -s ${w}x$h -framerate 30 -i $DISPLAY$adj -vcodec libx264 $bitrate -preset ultrafast /tmp/output.mkv
	set +x
}