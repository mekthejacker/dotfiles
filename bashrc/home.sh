. iforgot.sh
. mplayer.sh
. ffmpeg.sh
. ssh.sh
. wine.sh
. vm.sh

# Watering plants and sending water meter data.
# See "schedule" block in ~/.i3/generate_json_for_i3bar.sh
alias wtr='touch ~/watered'
alias snt='touch ~/sent'

alias rt="urxvtc -title rtorrent -hold \
                 -e /bin/bash -c 'chmod o+rw `tty` \
                    && sudo -u rtorrent -H tmux -u -S /home/rtorrent/.tmux/socket attach' &"
alias rtstop='sudo -u rtorrent /usr/bin/pkill -STOP -xf /usr/bin/rtorrent'
alias rtcont='sudo -u rtorrent /usr/bin/pkill -CONT -xf /usr/bin/rtorrent'

# For me, it’s easier to see new changes on a local setup.
[ "${MANPATH//*watch.sh*/}" ] \
	&& export MANPATH="$HOME/.watch.sh/:$MANPATH"
# Enabling bash-completion for my aliases
complete -F _watchsh wa-a wa-f wa-s wap-a wap-f wap-s
#
wa() {
	~/scripts/watch.sh \
		--no-hints -e -m "--fs --save-position-on-quit --profile=$HOSTNAME" \
		--last-ep --last-item-mark '.' \
		--remember-sub-and-audio-delay \
		-s "season %keyword disk disc cd part pt dvd" \
		-S /home/picts/screens/ \
		--screenshot-dir-skel="macro,misc" "$@"
}
wa-a() { wa -d /home/video/anime "$@"; }
wa-f() { wa -d /home/video/films "$@"; }
wa-s() { wa -d /home/video/serials "$@"; }

# For output on plasma tv, see also ~/.i3/config.template
wap() {
	local variant=$1; shift
	xrandr --output HDMI-0 --mode 1920x1080 --right-of DVI-I-0
	wa-$variant -m "--x11-name big_screen --ionice-opts --profile=hdmi" $@
    xrandr --output HDMI-0 --off
	# Switch back from the workspace bound to the output with plasma
	i3-msg workspace 0:Main
}
alias wap-a="wap a"
alias wap-f="wap f"
alias wap-s="wap s"


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
alias vm-w="qemu-graphic	-smp 1,cores=2,threads=1 -m 3072 \
	-vga qxl -spice addr=192.168.0.1,port=5903,disable-ticketing \
	-qmp unix:$HOME/qmp-sock-shindaws,server,nowait \
	-name 'Win_XP,process=vm-winxp' -rtc base=localtime -usbdevice tablet \
	-drive file=$HOME/vm_winxp.img,if=ide,boot=on \
-drive file=$HOME/fake.qcow2,if=virtio \
-drive file=/home/soft_win/virtio-win-0.1-81.iso,media=cdrom,index=1 \
	-netdev vde,id=taputapu,sock=/tmp/vde.ctl \
		-device virtio-net-pci,netdev=taputapu,mac=11:11:11:11:11:11"
alias vm-wc='spicec -h 192.168.0.1 -p 5903 -t QEMU_WinXP'
alias vm-wq='~/bin/qemu-shell/qmp-shell ~/qmp-sock-shindaws'
