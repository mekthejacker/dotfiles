. iforgot.sh
. mplayer.sh
. ffmpeg.sh
. ssh.sh
. wine.sh

# Watering plants and sending water meter data.
# See "schedule" block in ~/.i3/generate_json_for_i3bar.sh
alias wtr='touch ~/watered'
alias snt='touch ~/sent'

alias rt="urxvtc -title rtorrent -hold \
                 -e /bin/bash -c 'chmod o+rw `tty` && \
                    sudo -u rtorrent -H tmux -u -S /home/rtorrent/.tmux/socket attach' &"

[ "${MANPATH//*watch.sh*/}" ] \
	&& export MANPATH="$HOME/.watch.sh/:$MANPATH"
alias wa-a='~/scripts/watch.sh \
            -A -e -m "--fs" \
            --bashrc=$HOME/bashrc/mplayer.sh \
            --last-ep \
            -d /home/video/anime/ \
            -s "season - disk disc cd part pt dvd" \
            -S /home/picts/watched/ \
            --screenshot-dir-skel="macro,misc"'
#            -d /old_home/video/anime/ \

# For output on plasma tv, see also ~/.i3/config.template
function wa-ap() {
	xrandr --output HDMI-0 --mode 1920x1080 --right-of DVI-I-0
    ~/scripts/watch.sh \
        -A -e -m "--x11-name big_screen --profile=hdmi" \
        --bashrc=$HOME/bashrc/mplayer.sh \
        --last-ep \
        -d /home/video/anime/ \
        -s "season - disk disc cd part pt dvd" \
        -S /home/picts/watched/ \
        --screenshot-dir-skel="macro,misc" $@
    xrandr --output HDMI-0 --off
}

alias wa-f='~/scripts/watch.sh \
            -A -e -m "--fs" \
            --bashrc=$HOME/bashrc/mplayer.sh \
            --last-ep \
            -d /home/video/films/ \
            -s "season - disk disc cd part pt dvd" \
            -S /home/picts/watched/ \
            --screenshot-dir-skel="macro,misc"'

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
alias qemu-graphic="qemu-kvm -daemonize -enable-kvm \
	-cpu host \
	-boot order=dc \
	-no-frame -no-quit "

alias qemu-nographic="qemu-kvm  -enable-kvm \
	-cpu host \
	-smp 1,cores=1,threads=1 \
	-boot order=dc \
	-m 1024 \
	-no-frame"
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

alias vm-d="qemu-graphic	-smp 1,cores=1,threads=1 -m 1024 \
	-vga qxl -spice addr=127.0.0.1,port=5901,disable-ticketing \
	-name 'Debean,process=vm-debean' \
	-drive file=$HOME/vm_debean.img,if=virtio \
	-netdev vde,id=taputapu,sock=/tmp/vde.ctl \
		-device virtio-net-pci,netdev=taputapu,mac=DE:BE:AD:EB:EA:DE"
alias vm-dc='spicec -h 127.0.0.1 -p 5901 -t QEMU_Debean'

alias vm-f="qemu-graphic	-smp 1,cores=1,threads=1 -m 1024 \
	-vga qxl -spice addr=127.0.0.1,port=5902,disable-ticketing \
	-name 'Feedawra,process=vm-feedawra' \
	-drive file=$HOME/vm_feedawra.img,if=virtio \
	-netdev vde,id=taputapu,sock=/tmp/vde.ctl \
		-device virtio-net-pci,netdev=taputapu,mac=FE:ED:AF:EE:DA:FE"
alias vm-fc='spicec -h 127.0.0.1 -p 5902 -t QEMU_Feedawra'

# ,if=virtio
alias vm-w="qemu-graphic	-smp 1,cores=2,threads=1 -m 3072 \
	-vga qxl -spice addr=192.168.0.1,port=5903,disable-ticketing \
	-qmp unix:./qmp-sock,server,nowait \
	-name 'Win_XP,process=vm-winxp' -rtc base=localtime -usbdevice tablet \
	-drive file=$HOME/vm_winxp.img,if=ide,boot=on \
-drive file=$HOME/fake.qcow2,if=virtio \
-drive file=/home/soft_win/virtio-win-0.1-81.iso,media=cdrom,index=1 \
	-netdev vde,id=taputapu,sock=/tmp/vde.ctl \
		-device virtio-net-pci,netdev=taputapu,mac=11:11:11:11:11:11"
alias vm-wc='spicec -h 192.168.0.1 -p 5903 -t QEMU_WinXP'
