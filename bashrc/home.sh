. iforgot.sh
. wine.sh
. vm.sh
. not4public.sh

# Watering plants and sending water meter data.
# See "schedule" block in ~/.i3/generate_json_for_i3bar.sh
alias wtr='touch ~/watered'
alias snt='touch ~/sent'
alias okiru='rm /tmp/okiru'

alias rt="urxvtc -title rtorrent -hold \
                 -e /bin/bash -c 'chmod o+rw `tty` \
                    && sudo -u rtorrent -H tmux -u -S /home/rtorrent/.tmux/socket attach' &"
alias rtstop='sudo -u rtorrent /usr/bin/pkill -STOP -xf /usr/bin/rtorrent'
alias rtcont='sudo -u rtorrent /usr/bin/pkill -CONT -xf /usr/bin/rtorrent'
alias dotgit="`which git` --work-tree $HOME --git-dir $HOME/dotfiles.git"
alias gengit="`which git` --work-tree $HOME --git-dir $HOME/general.git"

# DESCRIPTION:
#     Overriding git for $HOME to maintain configs in one public (dotiles)
#     and one private (general) repo.
git() {
	[ $PWD = $HOME ] && {
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
	local found
	[ "`dotgit ls-files "$1"`" -ef "$1" ] \
		&& echo Found in dotfiles. && found=t
	[ "`gengit ls-files "$1"`" -ef "$1" ] \
		&& echo Found in general. && found=t
	[ -v found ] || {
		echo Not found.
		return 1
	}
}

# For me, it’s easier to see new changes on a local setup.
[ "${MANPATH//*watch.sh*/}" ] \
	&& export MANPATH="$HOME/.watch.sh/:$MANPATH"
# Enabling bash-completion for my aliases
complete -F _watchsh wa-a wa-f wa-s wap-a wap-f wap-s
#
wa() {
	# clb6x10 is installed separately, see the man page
	#   man -P "less -p '^.*Using a custom'" watch.sh
	# for details.
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
wa-f() { wa -d /home/video/films "$@"; }
wa-s() { wa -d /home/video/serials "$@"; }
wa-m() { wa -d /home/video/vekmnabkmvs "$@"; }

# For output on plasma tv, see also ~/.i3/config.template
wap() {
	local variant=$1; shift
	xrandr --output HDMI-0 --mode 1920x1080 --right-of DVI-I-0
	wa-$variant -m "--x11-name big_screen --profile=hdmi" $@ # --ionice-opts 
    xrandr --output HDMI-0 --off
	# Switch back from the workspace bound to the output with plasma
	i3-msg workspace 0:Main
}
alias wap-a="wap a"
alias wap-f="wap f"
alias wap-s="wap s"
alias wap-m="wap m"


alias imgur="~/bin/imgur_upload.sh"
alias renpy="RENPY_EDIT_PY=~/.renpy/emacs.edit.r.py  renpy"
# Viruses writers don’t expect that.
alias firefox='firefox --profile ~/.ff'

alias sync_fanetbook="sudo -u git /root/scripts/manual_sync.sh fanetbook all"
alias sync_external_hdd="sudo /root/scripts/manual_sync.sh rescue all"
alias detach_hdd="sudo /etc/udev/rules.d/rescue_mount.sh sud" # sync-umount-detach


# C-M-1 — VM window # Not F1, 1!
# C-M-2 — VM console
# from virt-X to virt-TTY: ‘sendkey ctrl-alt-f1’ in the VM console
# from virt-TTY to virt-X: ‘chvt 7’ in the VM window
# To connect to a vm running spice-vdagent:
#   $ spicec -h 127.0.0.1 -p 5900
# Default bridged network connection
#	… -netdev user,id=vmnic,hostname=vmdebean -device virtio-net,netdev=vmnic
# While no qxl driver for Xorg and spice-vdagent installed, -sdl may be used.
#alias spicec="spicec --hotkeys 'toggle-fullscreen=shift+f11,release-cursor=shift+f12'"
# ~/bin/qemu-shell/qmp-shell
# (QEMU) change ide0-cd ~/path/to/iso.iso
alias qemu-graphic="qemu-system-x86_64 -daemonize -enable-kvm \
	-cpu host \
	-boot order=dc \
	-no-frame -no-quit " # -sdl

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

# ,if=virtio
#-drive file=$HOME/fake.qcow2,if=virtio \
#-drive file=/home/soft_win/virtio-win-0.1-81.iso,media=cdrom,index=1 \
alias vm-w="qemu-graphic	-smp 1,cores=1,threads=1 -m 1024 \
	-vga qxl -spice addr=192.168.0.1,port=5903,disable-ticketing \
	-qmp unix:$HOME/qmp-sock-shindaws,server,nowait \
	-name 'Win_XP,process=vm-winxp' -rtc base=localtime -usbdevice tablet \
	-drive file=$HOME/vm_winxp.img,if=ide \
-net nic,model=virtio -net user "

#-netdev user,id=network0 -device e1000,netdev=network0"
## -netdev user,id=mynet0 \
## -device virtio-net,netdev=mynet0"
	# -netdev vde,id=taputapu,sock=/tmp/vde.ctl \
	# 	-device virtio-net-pci,netdev=taputapu,mac=11:11:11:11:11:11"
#-net vde,vlan=0 -net nic,vlan=0,macaddr=52:54:00:00:EE:02
alias vm-wc='spicec -h 192.168.0.1 -p 5903 -t QEMU_WinXP'
alias vm-wq='~/bin/qemu-shell/qmp-shell ~/qmp-sock-shindaws'


at-msg() {
	read -p "Examples: ‘+10 mins’, ‘19:30’."$'\n'"When? > " when
	read -p "Text message: > " msg
	date --date="$when" +"%H:%M" >/dev/null || return 4

	at "`date --date="$when" +"%H:%M"`" <<<"DISPLAY=$DISPLAY Xdialog --msgbox \"\n   $msg   \n\" 200x100"
}

# DESCRIPTION:
#     Takes a magnet link and places a .torrent file made of it to a directory.
#     USeful for rtorrent
# TAKES:
#   $1 — magnet link
#   $2 — path to resulting .torrent file
magnet-to-torrent() {
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
# $1 — where to copy
copy-playlist() {
	err() { echo "$1" >&2; echo $2; }  # $1 — message; $2 — return code
	local dest="$1" cur_pl='current.m3u' pl_dir pl library_path got_a_sane_reply
	pl_dir=`sed -nr 's/^\s*playlist_directory\s+"(.+)"\s*$/\1/p' ~/.mpd/mpd.conf`
	library_path=`sed -nr 's/^\s*music_directory\s+"(.+)"\s*$/\1/p' ~/.mpd/mpd.conf`
	eval [ -d "$pl_dir" ] \
		|| return `err 'Playlist directory is indeterminable.' 3`
	eval [ -d "$library_path" ] \
		|| return `err 'Path to music library is indeterminable.' 4`
	pl="$pl_dir/$cur_pl"
	mpc save "$cur_pl"  # MPD_HOST must be set in the environment
	[ -f "$pl" ] || return `err 'Playlist wasn’t saved' 5`
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
		done < "$pl"
		:
	}|| return `err "Destination dir ‘$dest’ is not writable." 6`
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
chu() { echo -n "$@" | uniname; }
