## sourced from ~/.bashrc

. iforgot.sh
. wine.sh
. vm.sh
. not4public.sh

#
 #  Common aliases
#

# Watering plants and sending water meter data.
# See "schedule" block in ~/.i3/generate_json_for_i3bar.sh
alias wtr='touch ~/watered'
alias snt='touch ~/sent'
alias okiru='rm /tmp/okiru'
# rtorrent
alias rt="urxvtc -title rtorrent -hold \
                 -e /bin/bash -c 'chmod o+rw `tty` \
                    && sudo -u rtorrent -H tmux -u -S /home/rtorrent/.tmux/socket attach' &"
# For temporary freeing the connection from torrents.
rt-pause() {
	[ "${FUNCNAME[1]}" = rt-unpause ] && local unpause=t || local pause=t
	local rtstate=$(ps -o state,cmd ax | sed -rn "s:^([DRSTtWXZ])\s+$(which rtorrent).*:\1:p")
	case "$rtstate" in
		D) echo 'The process is in uninterruptible sleep (usually IO). I better not do anything.' >&2
		   return 3
		   ;;
		R|S) [ -v unpause ] \
		       && echo 'Already running!' \
		       || sudo -u rtorrent /usr/bin/pkill -STOP -xf /usr/bin/rtorrent;;
		T) [ -v pause ] \
		       && echo 'Already paused!' \
		       || sudo -u rtorrent /usr/bin/pkill -CONT -xf /usr/bin/rtorrent;;
		t) echo 'The process is stopped by debugger during the tracing. I better not do anything.' >&2
		   return 4
		   ;;
		W) echo '2.6 kernel? Am I on a router? /Ghi-hi-hi…/' >&2
		   return 5
		   ;;
		X) echo 'The process seems to be dead.' >&2
		   return 6
		   ;;
		Z) echo 'The process is in zombie state. Impossible to do start or stop.' >&2
		   return 7
		   ;;
		*) echo -e "Cannot recognize process state ‘$rtstate’." >&2
		   return 8
		   ;;
	esac
}
rt-unpause() { rt-pause; }
# Strike the earth!
alias d='dwarf-fortress'
alias dt='dwarftherapist'
alias ddt='/bin/bash -c "dwarf-fortress; i3-msg layout tabbed; sleep 15; dwarftherapist; i3-msg focus left"'
alias dk="pkill -9f '(Dwarf_Fortress|DwarfTherapist)'"
alias imgur="~/bin/imgur_upload.sh"
alias renpy="RENPY_EDIT_PY=~/.renpy/emacs.edit.r.py  renpy"
# Viruses writers don’t expect that.
alias firefox='firefox --profile ~/.ff'
#alias sync_fanetbook="sudo -u git /root/scripts/manual_sync.sh fanetbook all"
#alias sync_external_hdd="sudo /root/scripts/manual_sync.sh rescue all"
#alias detach_hdd="sudo /etc/udev/rules.d/rescue_mount.sh sud" # sync-umount-detach

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
		cat <<EOF
Usage: isinrepo $HOME/…/<filename>

EOF
		return
	}
	local found
	[ "`dotgit ls-files "$1"`" -ef "$1" ] \
		&& echo Found in dotfiles. && found=t
	[ "`gengit ls-files "$1"`" -ef "$1" ] \
		&& echo Found in general. && found=t
	[ -v found ] || {
		echo Not found.
		return 3
	}
}

#
 #  watch.sh block
#

# For me, it’s easier to see new changes on a local setup.
[ "${MANPATH//*watch.sh*/}" ] \
	&& export MANPATH="$HOME/.watch.sh/:$MANPATH"
# Enabling bash-completion for my functions
. /usr/share/bash-completion/completions/watchsh
complete -F _watchsh wa-a wa-f wa-s wap-a wap-f wap-s wa-alias

wa() {
	# clb6x10 is installed separately, see the man page for details.
	#   man -P "less -p '^.*Using a custom'" watch.sh
	~/bin/watch.sh \
		--no-hints -e -m "--fs --save-position-on-quit --profile=$HOSTNAME" \
		--last-ep --last-ep-command "figlet -t -f $HOME/.fonts/clb6x10 -c" \
		--last-item-mark '.' \
		--remember-sub-and-audio-delay \
		-s "season %keyword disk disc cd part pt dvd" \
		-S /home/picts/screens/ \
		--screenshot-dir-skel="macro,misc" "$@"
}
wa-a() { wa -d /home/video/anime "$@"; }
# alias wa-alias='wa -d /home/video/anime' ## Redo with aliases? Why did I stick to functions?
wa-f() { wa -d /home/video/films "$@"; }
wa-s() { wa -d /home/video/serials "$@"; }
wa-m() { wa -d /home/video/мультипликация "$@"; }

# Output on the plasma. See also ~/.i3/config.template for workspace bindings.
wap() {
	local variant=$1; shift
	xrandr --output $SLAVE_OUTPUT_0 --auto --right-of $PRIMARY_OUTPUT
	wa-$variant -m "--x11-name big_screen --profile=hdmi" $@ # --ionice-opts        ## Maybe because of this?
    xrandr --output $SLAVE_OUTPUT_0 --off
	# Switch back from the workspace bound to the output with plasma
	# i3-msg workspace 0:Main
}
alias wap-a="wap a"
alias wap-f="wap f"
alias wap-s="wap s"
alias wap-m="wap m"

alias vivaldi="vivaldi --flag-switches-begin --debug-packed-apps --silent-debugger-extension-api --flag-switches-end"

#
 #  QEMU block
#

# SPICE keys
#     Shift + F11 — fullscreen/windowed
#     Shift + F12 — release mouse
# QEMU keys
#     C-M-1 — VM window # Not F1, 1!
#     C-M-2 — VM console
#     from virt-X to virt-TTY: ‘sendkey ctrl-alt-f1’ in the VM console
#     from virt-TTY to virt-X: ‘chvt 7’ in the VM window
#
# To connect to a vm running spice-vdagent:
#     $ spicec -h 127.0.0.1 -p 5900
# Default bridged network connection
#     … -netdev user,id=vmnic,hostname=vmdebean -device virtio-net,netdev=vmnic
# While no qxl driver for Xorg and spice-vdagent installed, -sdl may be used.
#alias spicec="spicec --hotkeys 'toggle-fullscreen=shift+f11,release-cursor=shift+f12'"
# ~/bin/qemu-shell/qmp-shell
# (QEMU) change ide0-cd ~/path/to/iso.iso
alias qemu-graphic="qemu-system-x86_64 -daemonize -enable-kvm \
	-cpu host \
	-boot order=dc " # -no-frame -no-quit -sdl # All three together

alias qemu-nographic="qemu-system-x86_64  -enable-kvm \
	-cpu host \
	-smp 1,cores=1,threads=1 \
	-boot order=dc \
	-m 1024"
#-vga qxl -spice addr=127.0.0.1,port=5900,disable-ticketing
alias vm-i="qemu-nographic -serial stdio \
	-name 'initramfs,process=initramfs' \
	-kernel \`ls -t /boot/vm* | head -n1\` \
-append \"root=/dev/ram0 console=ttyAMA0 console=ttyS0\" \
	-initrd \`ls -t /boot/in* | head -n1\` \
	/dev/zero "
#\
#	&& spicec -h 127.0.0.1 -p 5900 -t 'QEMU_initramfs' \
#	; pkill -9 -f qemu

# spice += seamless_migration?
alias vm-d="qemu-graphic	-smp 1,cores=1,threads=1 -m 1024 \
	-vga qxl -spice addr=127.0.0.1,port=5901,disable-ticketing \
	-qmp unix:$HOME/qmp-sock-vmdebean,server,nowait \
	-name 'Debean,process=vm-debean' \
	-drive file=$HOME/vm_debean.img,if=virtio \
	-netdev vde,id=taputapu,sock=/tmp/vde.ctl \
		-device virtio-net-pci,netdev=taputapu,mac=DE:BE:AD:EB:EA:DE"
alias vm-dc='spicec -h 127.0.0.1 -p 5901 -t QEMU_Debean'
alias vm-dq='~/bin/qemu-shell/qmp-shell ~/qmp-sock-vmdebean'

alias vm-f="qemu-graphic	-smp 1,cores=1,threads=1 -m 1024 \
	-vga qxl -spice addr=127.0.0.1,port=5902,disable-ticketing \
	-qmp unix:$HOME/qmp-sock-vmfeedawra,server,nowait \
	-name 'Feedawra,process=vm-feedawra' \
	-drive file=$HOME/vm_feedawra.img,if=virtio \
	-netdev vde,id=taputapu,sock=/tmp/vde.ctl \
		-device virtio-net-pci,netdev=taputapu,mac=FE:ED:AF:EE:DA:FE"
alias vm-fc='spicec -h 127.0.0.1 -p 5902 -t QEMU_Feedawra'
alias vm-fq='~/bin/qemu-shell/qmp-shell ~/qmp-sock-vmfeedawra'

alias vm-almafi='spicec -h 127.0.0.1 -p 7001 -t Almafi'
alias vm-sat='spicec -h 127.0.0.1 -p 7002 -t Sat'
alias vm-streamer='spicec -h 127.0.0.1 -p 7003 -t Streamer'

# ,if=virtio
#-drive file=$HOME/fake.qcow2,if=virtio \
#-drive file=/home/soft_win/virtio-win-0.1-81.iso,media=cdrom,index=1 \
alias vm-w="qemu-graphic	-smp 1,cores=2,threads=1 -m 1512 -drive file=/home/$ME/desktop/virtio-win-0.1.102.iso,media=cdrom,index=1 \
	-vga qxl -spice addr=192.168.0.1,port=5903,disable-ticketing \
	-qmp unix:$HOME/qmp-sock-shindaws,server,nowait \
	-name 'Win_XP,process=vm-winxp' -rtc base=localtime -usbdevice tablet \
	-drive file=$HOME/vm_winxp.img,if=ide \
	-netdev vde,id=mynet,sock=/tmp/vde.ctl \
		-device virtio-net-pci,netdev=mynet"

## VDE switch
## + VM is a true part of local network.
## + VM uses LAN samba server with as many shares as you want.
#	-netdev vde,id=taputapu,sock=/tmp/vde.ctl \
#		-device virtio-net-pci,netdev=taputapu,mac=FE:ED:DF:EE:DA:FE"

## User networking (SLIRP)
## samba share is accessible via \\10.0.2.4\qemu
#    -netdev user,id=mynet0,smb=/home/$ME/desktop,smbserver=10.0.2.4 \
#        -device virtio-net,netdev=mynet0"

alias vm-wc='spicec -h 192.168.0.1 -p 5903 -t QEMU_WinXP____Shift_F11'
alias vm-wq='~/bin/qemu-shell/qmp-shell ~/qmp-sock-shindaws'

#
 #  Various funstions making life easier. Kind of an addition to ~/bin.
#

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
	[ "$*" ] || {
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
	local cur_pl='current' dest="/run/media/$ME/PHONE_CARD/Sounds/Music/" \
		  pl_dir pl library_path got_a_sane_reply
	pl_dir=`sed -nr 's/^\s*playlist_directory\s+"(.+)"\s*$/\1/p' ~/.mpd/mpd.conf`
	[ "$pl_dir" ] || err 'mpd.conf doesn’t have playlist_directory?' 3
	library_path=`sed -nr 's/^\s*music_directory\s+"(.+)"\s*$/\1/p' ~/.mpd/mpd.conf`
	library_path="${library_path/#\~/$HOME}"
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

fpic() { find ~/picts -iname "*$@*"; }
