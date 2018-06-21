## sourced from ~/.bashrc

. common.sh
. gen_prompt.sh
. iforgot.sh
. wine-aliases.sh
. vm.sh
[ -e jobu.sh ] && . jobu.sh


 #  Managing two git repos for ~/, dotfiles is public.
#
alias dotgit="`which git` --work-tree $HOME --git-dir $HOME/dotfiles.git"
alias gengit="`which git` --work-tree $HOME --git-dir $HOME/general.git"
#
 # Checks, if a file in $HOME is in dotfiles of general repo,
#  $1 — file path under $HOME
#
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

# Watering plants and sending water meter data.
# See "schedule" block in ~/.i3/generate_json_for_i3bar.sh
wtr() { touch ~/watered; }
snt() { touch ~/sent; }
okiru() { rm /tmp/okiru; }
# rtorrent
rt() {
	urxvtc -title rtorrent \
	       -hold \
	       -e /bin/bash -c 'chmod o+rw `tty` \
	                        && sudo -u rtorrent \
	                                -H tmux \
	                                -u \
	                                -S /home/rtorrent/.tmux/socket attach' &
}
tld-typofix() {
	pushd ~/bin/typofix/
	./typofix.sh Russian_col4.csv
	popd
}

wacom-enable() { wacom-devcontrol enable; }
wacom-disable() { wacom-devcontrol disable; }
 # Disables or enables wacom devices
#    $1 – <enable|disable>
wacom-devcontrol() {
	# echo DISPLAY=$DISPLAY
	local dev
	while read dev; do
		[ "$1" = enable ] \
			&& echo "Enabling ‘$dev’." \
			|| echo "Disabling ‘$dev’"
		xinput --$1 "$dev"
	done < <(xinput --list --name-only | grep Wacom)
}

# Strike the earth!
d() { dwarf-fortress; }
dt() { dwarftherapist; }
dk() { pkill -9f '(Dwarf_Fortress|DwarfTherapist)';}

#
 #  watch.sh block
#

# For me, it’s easier to see new changes on a local setup.
[ "${MANPATH//*watch.sh*/}" ] \
	&& export MANPATH="$HOME/.watch.sh/:$MANPATH"
# Enabling bash-completion for my functions
. /usr/share/bash-completion/completions/watchsh
complete -F _watchsh wa-a wa-f wa-s wa-c wap-a wap-f wap-s wa-alias

wa() {
	# clb6x10 is installed separately, see the man page for details.
	#   man -P "less -p '^.*Using a custom'" watch.sh
	~/bin/watch.sh \
		--no-hints -e -m "--fs --save-position-on-quit --profile=$HOSTNAME \
		                  --input-ipc-server=/tmp/mpv-watchsh-socket" \
		--last-ep --last-ep-command "figlet -t -f $HOME/.fonts/clb6x10 -c" \
		--last-item-mark '.' \
		--remember-sub-and-audio-delay \
		-s "season %keyword disk disc cd part pt dvd" \
		"$@"
}
wa-a() {
	wa -d /home/video/anime \
	   -S /home/picts/screenshots/animu \
	   --screenshot-dir-skel="subs,art,misc" \
	   "$@"
}
wa-f() {
	wa -d /home/video/films \
	   -S /home/picts/screenshots/films \
	   --screenshot-dir-skel="subs,art,misc" \
	   "$@"
}
wa-s() {
	wa -d /home/video/serials \
	   -S /home/picts/screenshots/serials \
	   --screenshot-dir-skel="subs,art,misc" \
	   "$@"
}
wa-c() {
	wa -d /home/video/cartoons \
	   -S /home/picts/screenshots/cartoons \
	   --screenshot-dir-skel="subs,art,misc" \
	   "$@"
}

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

mpv-tv() {
	mkfifo /tmp/mpv-tv.fifo 2>/dev/null
	xrandr --output $SLAVE_OUTPUT_0 --auto --right-of $PRIMARY_OUTPUT
	mpv --profile=tv ~/.mpd/playlists/iptv-local.m3u
	xrandr --output $SLAVE_OUTPUT_0 --off
}

alias vivaldi="vivaldi --flag-switches-begin --debug-packed-apps --silent-debugger-extension-api --flag-switches-end"
alias vivcp="cp -v ~/.config/vivaldi/custom.css  /opt/vivaldi/resources/vivaldi/style/"

yt-pl-music() {
	yt_pl_download.sh \
		~/music/yt-playlist \
		'https://www.youtube.com/playlist?list=PLj9N785l66Hbxm8QRgH_p2ZBjYY7RAuPz'
}
yt-pl-jap-music() {
	yt_pl_download.sh \
		~/music/Japanese/yt-playlist \
		'https://www.youtube.com/playlist?list=PLj9N785l66HYQA4iNwPVebka0jFuNuWWb'
}
yt-pl-sov-music() {
	yt_pl_download.sh \
		~/music/Old/yt-playlist \
		'https://www.youtube.com/playlist?list=PLj9N785l66HaJGSGeq608HgASjFthz4k1'
}

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
#     $ spicy -h 127.0.0.1 -p 5900
# Default bridged network connection
#     … -netdev user,id=vmnic,hostname=vmdebean -device virtio-net,netdev=vmnic
# While no qxl driver for Xorg and spice-vdagent installed, -sdl may be used.
#alias spicy="spicy --hotkeys 'toggle-fullscreen=shift+f11,release-cursor=shift+f12'"
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
#	&& spicy -h 127.0.0.1 -p 5900 -t 'QEMU_initramfs' \
#	; pkill -9 -f qemu

# spice += seamless_migration?
alias vm-d="qemu-graphic	-smp 1,cores=1,threads=1 -m 1024 \
	-vga qxl -spice addr=127.0.0.1,port=5901,disable-ticketing \
	-qmp unix:$HOME/qmp-sock-vmdebean,server,nowait \
	-name 'Debean,process=vm-debean' \
	-drive file=$HOME/vm_debean.img,if=virtio \
	-netdev vde,id=taputapu,sock=/tmp/vde.ctl \
		-device virtio-net-pci,netdev=taputapu,mac=DE:BE:AD:EB:EA:DE"
alias vm-dc='spicy -h 127.0.0.1 -p 5901 --title=QEMU_Debean'
alias vm-dq='~/bin/qemu-shell/qmp-shell ~/qmp-sock-vmdebean'

# alias vm-almafi='spicy -h 127.0.0.1 -p 7001 -t Almafi'
# alias vm-sat='spicy -h 127.0.0.1 -p 7002 -t Sat'
# alias vm-streamer='spicy -h 127.0.0.1 -p 7003 -t Streamer'

# ,if=virtio
#-drive file=$HOME/fake.qcow2,if=virtio \
#-drive file=/home/soft_win/virtio-win-0.1-81.iso,media=cdrom,index=1 \
#-drive file=/home/$ME/desktop/virtio-win-0.1.102.iso,media=cdrom,index=1
alias vm-w="qemu-graphic	-smp 1,cores=1,threads=1 -m 1512  \
	-vga qxl -spice addr=192.168.5.1,port=5903,disable-ticketing \
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

alias vm-wc='spicy -h 192.168.5.1 -p 5903 --title=QEMU_WinXP____Shift_F11'
alias vm-wq='~/bin/qemu-shell/qmp-shell ~/qmp-sock-shindaws'

vm-ts-mother-setup() {
	[ -r "$1" ] \
		&& file="$1" \
		|| file=`ls ~/work/lifestream/minimal-sysrcd/sysrcd-*.iso | tail -n1`
	[ -f "$file" ] || {
		echo "No such file: ‘$file’." >&2
		return 3
	}
	qemu-system-x86_64  -enable-kvm \
	                  -cpu host \
                      -smp 1,cores=1,threads=1 \
                      -boot order=dc \
                      -m 1024 \
                      -name 'vm-ts-mother-setup,process=vm-ts-mother-setup' \
                      -drive "file=$file,media=cdrom,index=0" \
                      -netdev vde,id=pxelan,sock=/tmp/vde.ctl \
                      -device virtio-net-pci,netdev=pxelan,mac=BA:C1:47:BA:C1:47 \
                      -serial stdio
# -vga qxl -spice addr=192.168.5.1,port=7000,disable-ticketing \
# -nographic console=/dev/ttyS0
	# -serial stdio

}
alias vm-pxe-client-setup="qemu-system-x86_64  -enable-kvm \
	-cpu host \
	-smp 1,cores=1,threads=1 \
	-boot order=n \
	-m 1024 -serial stdio \
	-name 'vm-pxe-clinet-setup,process=vm-pxe-client-setup' \
	-netdev vde,id=pxelan,sock=/tmp/vde.ctl \
		-device virtio-net-pci,netdev=pxelan,mac=BA:C1:47:2B:4C:14"


alias vm-u="qemu-graphic	-smp 2,cores=2,threads=1 -m 1512  \
	-vga qxl -spice addr=192.168.5.1,port=5904,disable-ticketing \
	-qmp unix:$HOME/qmp-sock-uboo-server,server,nowait \
	-name 'Uboo-serv,process=vm-uboo-serv' -rtc base=localtime -usbdevice tablet \
	-drive file=$HOME/desktop/eltex.raw.img,format=raw,if=ide \
	-drive file=/home/soft_lin/ubuntu-14.04.5-server-amd64.iso,media=cdrom,index=1 \
	-netdev vde,id=mynet,sock=/tmp/vde.ctl \
		-device virtio-net-pci,netdev=mynet"
alias vm-uc="spicy -h 192.168.5.1 -p 5904 --title=QEMU_Uboo-serv____Shift_F11"



 # Hugo
#
alias hugo-future="hugo --cleanDestinationDir \
	                    --ignoreCache \
	                    --buildDrafts -buildFuture --buildExpired \
	                    --verboseLog --logFile hugo.log \
	                    -s ~/repos/goen \
	                    -c ~/repos/goen/content \
	                    -d ~/repos/goen/future \
	                    && hugo server --buildDrafts -ws ~/repos/goen -d ~/repos/goen/future"
alias hugo-public="hugo --cleanDestinationDir \
	                    --ignoreCache \
	                    -s ~/repos/goen \
	                    -c ~/repos/goen/content \
	                    -d ~/repos/goen/public"

fonts-for-vm() {
	vm_fonts_dir="$HOME/.fonts-for-vm/"
	mkdir "$vm_fonts_dir" 2>/dev/null
	local c=0 bad_fonts=() fileoutp_maxlength=$((`tput cols`-10))
	while read -r -d $'\n'; do
		[ -r "$REPLY" ] && {
			cp "$REPLY" "$vm_fonts_dir"
			echo -en "\r\e[KCopying: ${REPLY:0:$fileoutp_maxlength}"
			let c++
			:
		}||{
			bad_fonts+=("$REPLY")
		}
	done < <( fc-list | sed -rn 's/([^:]+[TtOo][Tt][Ff]):.*/\1/p' )
	echo -en "\r\e[K$c fonts copied. "
	[ ${#bad_fonts[@]} -gt 0 ] && for bad_font in "${bad_fonts[@]}"; do
		echo "$bad_font failed to read."
	done
	echo
}

inet-off() { inet-on-off; }
inet-on() { inet-on-off; }
inet-on-off() {
	case "${FUNCNAME[1]}" in
		inet-on)
			ip ro add default via 77.243.108.1
			;;
		inet-off)
			ip ro del default via 77.243.108.1
			;;
		esac
}

return 0