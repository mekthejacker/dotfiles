#! /usr/bin/env bash

exec qemu-system-x86_64 \
	-daemonize \
	-enable-kvm \
	-cpu host \
	-boot order=dc \
	-smp 1,cores=1,threads=1 \
	-m 1024 \
	-vga qxl \
	-spice addr=127.0.0.1,port=5901,disable-ticketing \
	-name 'Debean,process=vm-debean' \
	-drive file=$HOME/vm_debean.img,if=virtio \
	-netdev vde,id=taputapu,sock=/tmp/vde.ctl \
	-device virtio-net-pci,netdev=taputapu,mac=DE:BE:AD:EB:EA:DE
