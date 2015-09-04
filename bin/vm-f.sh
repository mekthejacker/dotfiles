#! /usr/bin/env bash

exec qemu-system-x86_64 \
	-daemonize \
	-enable-kvm \
	-cpu host \
	-boot order=dc \
	-smp 1,cores=1,threads=1 \
	-m 1024 \
	-vga qxl \
	-spice addr=127.0.0.1,port=5902,disable-ticketing \
	-name 'Feedawra,process=vm-feedawra' \
	-drive file=$HOME/vm_feedawra.img,if=virtio \
	-netdev vde,id=taputapu,sock=/tmp/vde.ctl \
	-device virtio-net-pci,netdev=taputapu,mac=FE:ED:AF:EE:DA:FE
