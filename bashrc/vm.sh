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
