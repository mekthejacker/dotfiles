# iforgot.sh
# This bash source file is for functions showing you
# samples of code that you always forget.

# <<EOF expands heredoc, <<"EOF" leaves it as is.

# DESCRIPTION
#     Shows…
# TAKES
#     $@
iforgot() {
	local keywords="$@" k func_list top_list
	[ "$keywords" ] || {
		read -p 'What have you forgot, darling? > '
		local keywords="$REPLY"
		echo "Thanks, also you can use parameters to this function, like"
		echo -e "\tiforgot  <word A>  <word B>"
	}
	func_list=(`declare -F | sed -nr 's/^declare -fx (iforgot-.*)/\1/p'`)
	echo
	for k in $keywords; do
		for func in ${func_list[@]}; do
			[[ "$func" =~ ^.*$k.*$ ]] && top_list+=($func)
		done
		[ ${#top_list[@]} -ne 0 ] && {
			echo -e "Functions that contain ‘$k’ in their names:\n"
			for func in ${top_list[@]}; do
				echo $func | grep -E "(|$k)"
			done
			echo
		}
		echo -e "Functions that contain ‘$k’ in their bodies:\n"
		for func in ${func_list[*]}; do
			type $func \
				| sed -rn '1d
				           /^iforgot.*'$k'/,/}/d
				           2H
				           /'$k'/H
				           ${ g
				              s/'$k'/'$k'/; t good; Q
				              :good  s/\s+/ /g
				              s/\(\)/\n/g
				              s/\n\s/\n/g
				              p
				           }' \
				| grep -v ^$ \
				| fold  -s -w $((`tput cols`-8)) \
				| sed '/^ iforgot/ !s/.*/\t&/g; s/^ //g' \
				| grep -E "(|$k)"
		done
	done
	return 0
}

iforgot-restart-daemons-from-the-runlevel-i-am-in() {
	cat <<-"EOF"
	USE CAREFULLY.
	for i in `rc-update | sed -rn 's/[ ]+([^ ]+) \| '"runlevel"'.*/\1/p'`; do
		/etc/init.d/$i restart
	done
	EOF
}

iforgot-make-etags-for-emacs() {
	cat <<-"EOF"
	find . -name '*.c' -exec etags -a {} \;
	EOF
}

iforgot-htmlize-my-code() {
	echo man code2html
}

iforgot-mount-options-for-my-flash-stick() {
	echo mount -t vfat -o user,rw,fmask=0111,dmask=0000,codepage=866,nls=iso8859-5,utf8,noexec
}

iforgot-uname-opts() {
	for i in a s n r v m p i o; do
		echo -e "\t-$i\t`uname -$i`"
	done
}

iforgot-check-gcc-options() {
	set -x
	gcc -Q -march=atom --help=target | grep fpmath
	gcc -Q --help=optimizers | grep enable
	set +x
}

iforgot-xkb-opts() {
	set -x
	less /usr/share/X11/xkb/rules/evdev.lst
	set +x
}

iforgot-load-all-possible-sensors-modules() {
	cat <<-"EOF"
	for i in `modprobe -l | sed -rn 's|.*/hwmon/([^/]+)$|\1|p'`; do
		modprobe $i
	done
	EOF
}

iforgot-fsck-force-check() {
	echo -e \\t touch /forcefsck
}

iforgot-make-a-debug-build() {
	cat <<-"EOF"
	FEATURES="ccache nostrip" \
	USE="debug" \
	CFLAGS="$CFLAGS -ggdb" \
	CXXFLAGS="$CFLAGS" \
	emerge $package
	OR
	gdb --pid <pid>
	thread apply all bt
	EOF
}

iforgot-bash-read-via-x0() {
	cat <<-"EOF"
	while IFS= read -r -d $'\0'; do
		echo "$REPLY"
	done <  <(find -type f -print0)

	(-d '' also works since \0 is an ‘end of the string’ marker.)
	EOF
}

iforgot-bash-where-is-my-completion() {
	cat <<-"EOF"
	eselect bashcomp list --global
	eselect bashcomp enable --global base
	eselect bashcomp enable --global man
	eselect bashcomp enable --global gentoo
	env-update && . /etc/profile
	EOF
}

iforgot-what-is-that-window-class() {
	echo -e \\txprop
}

iforgot-what-to-do-if-something-messed-the-fonts() {
	cat <<-"EOF"
	xset +fp /usr/share/fonts/terminus && xset fp rehash
	EOF
}

iforgot-extended-regex-purpose() {
	set -x
	shopt -s extglob && abc='000123' && echo ${abc##+(0)}
	set +x
}

iforgot-how-to-trace-and-debug() {
	cat <<-EOF
	Trace library and system calls:
	strace -p PID
	ltrace -p PID

	Look for opened files of process with pid PID
	ls -l /proc/PID/fd/*

	Kill a process to see its core
	kill -11 PID
	EOF
}

iforgot-bookmarks-in-manpages() {
	cat <<-"EOF"
	man -P 'less -p \"^\s+Colors\"' eix
	EOF
}

iforgot-git-new-repo() {
	cat <<-"EOF"
	git init
	git remote add origin git@example.com:project_team.git
	ssh://git@example.com:port/reponame.git
	git add .
	git commit -m "fgsfds"
	git push origin refs/heads/master:refs/heads/master
	EOF
}

iforgot-select-figlet-font-for-me() {
	cat <<-"EOF"
	echo '' > ~/cool_fonts
	for i in `ls /usr/share/figlet/*flf`; do
		clear
		echo $i
		figlet -f $i -c 12345
		figlet -f $i -c 67890
		read -n1
		[ $REPLY = 'y' ] && echo $i>>~/cool_fonts
	done
	cat ~/cool_fonts
	EOF
}

iforgot-draw-me-cool-figlet-fonts() {
	cat <<-"EOF"
	for i in `cat ~/cool_fonts`; do
		echo $i
		figlet -f $i -c 12345
		figlet -f $i -c 67890
	done
	EOF
}

 # $1 – chroot dir
#
iforgot-chroot-procedure() {
	[ "$1" -a -d "$1" ] \
		&& chroot_dir="$1" \
		|| {
			read -p 'What directory is your chroot? > '
			chroot_dir="$REPLY"
		}
	chroot_dir=${chroot_dir%/}
	cat <<-EOF
	# Systemerde requires more!
	mount -t proc none $chroot_dir/proc
	mount --rbind /sys $chroot_dir/sys
	mount --rbind /dev $chroot_dir/dev
	[linux32] chroot $chroot_dir /bin/bash

	env-update && source /etc/profile
	export PS1="(chroot) \$PS1"
	# mount /boot /usr etc.
	…
	exit

	umount -l $chroot_dir/dev{/shm,/pts,}
	umount $chroot_dir/{boot,proc}
	umount -l $chroot_dir{/sys,}
	EOF
}

iforgot-ordinary-user-groups() {
	echo -e "\tuseradd -m -G audio,cdrom,games,plugdev,cdrw,floppy,portage,usb,video,wheel -s /bin/bash username"
}

# SMART
iforgot-smart-immediate-check() {
	cat <<-EOF
	smartctl -H /dev/sdX
	EOF
}

iforgot-smart-selftest-do-short-now() {
	cat <<-EOF
	smartctl -t short /dev/sdX
	EOF
}

iforgot-smart-selftest-do-long-now() {
	cat <<-EOF
	smartctl -t long /dev/sdX
	EOF
}

iforgot-smart-selftest-schedule-long() {
	cat <<-EOF
	smartctl -t long -s L/../.././23
	EOF
}

iforgot-smart-selftest-scheduling-syntax() {
	cat <<-EOF
	man -P "less -p'^\s+-s REGEXP'" smartd.conf
	EOF
}

iforgot-bad-blocks() {
	cat <<-"EOF"
	tl;dr
	    Realloc_sector_ct – how much sectors drive noticed to be failing
	                        to read and remapped them.
	    Realloc_event_ct  – how much times drive spotted one or a bunch
	                        of sectors to be failing to read.
	    Pending_sector    – sectors, which the drive fails to read, and
	                        cannot remap because of that. Requires it
	                        to either become readable again, or rewritten
	                       (Rewrite with zeroes by LBA or the whole drive
	                        to get rid of them).
	    Offline_uncorrectable – number of failing sectors, which the drive
	                        couldn’t fix during an Offline test.
	/tl;dr

	If situation looks like this:

	    # smartctl -a /dev/sda
	    SMART Attributes Data Structure revision number: 10
	    Vendor Specific SMART Attributes with Thresholds:
	    ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
	    …
	    5   Reallocated_Sector_Ct   0x0033   099   099   036    Pre-fail  Always       -       61
	    …
	    197 Current_Pending_Sector  0x0012   100   100   000    Old_age   Always       -       1
	    198 Offline_Uncorrectable   0x0010   100   100   000    Old_age   Offline      -       1
	    …
	    SMART Self-test log structure revision number 1
	    Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
	    # 1  Extended offline    Completed: read failure       20%     22638         1670581106

	Then seeking for a badblock will look like this:

	    # badblocks -vs -b512 /dev/sda 1670581106 1670581106

	-v – verbose, -s shows progress, -b is block size, 512 since 1670581106
	is LBA, i.e. sector address and sectors are usually 512 bytes long.
	First address is the end of the range where badblocks seeks, and the
	last one points at the start of the range. Also there are useful -n
	and -w options which mutually exclude themselves – -n safely rewrites
	block’s contents, -w rewrites it with binary patterns and causes a data
	loss. By default badblocks does only read-only check.

	If it confirms that the sector is bad, then you need to know
	- the address (a number, in blocks) where it resides on your partition;
	- the offset
	and pass it as the number of the block in the filesystem format,
	usually it is multiple of 512, e.g. 4096.

	    # fdisk /dev/sda

	    Device Boot      Start         End      Blocks   Id  System
	    /dev/sda1   *          63       80324       40131   83  Linux
	    /dev/sda2           80325   104952644    52436160   83  Linux
	    /dev/sda3       104952645   109161674     2104515   83  Linux
	    /dev/sda4       109162496  1953525167   922181336   83  Linux

	So, the problem LBA belongs to /dev/sda4, now get the offset on that
	partition.

	    # echo 'scale=3;(1690581106-109162496)/8' | bc
	    195177326.25

	Fractional part (.25) means that it’s the second sector of eight in that block.
	(Since one block of 4096 bytes contains 8*512 bytes sectors, 1/8 is	0.125
	and 2/8 is 0.25)
	The formula is
	    Bad_LBA − Start_LBA_on_that_partition / (FS_block_size / Sector_size)
	So, make the list

	    # echo '(1690581106-109162496)/8' | bc > /tmp/bb_list

	And call e2fsck

	    # umount /<mountpoint of the partiton with bad LBA>
	    # e2fsck -l /tmp/bb_list /dev/sdX

	Use -L in place of -l to rewrite the filesystem internal badblock list.
	You can check that list with

	    # dumpe2fs -b /dev/sda4

	EOF
}

# Wi-Fi
iforgot-wifi-check-link() {
	cat <<-EOF
	iwconfig
	iw dev wlan0 link
	EOF
}

iforgot-wifi-connect() {
	cat <<-"EOF"
	cat <<"EOF" >/etc/wpa_supplicant.conf
	network={
		ssid="wpatest"
		scan_ssid=1
		key_mgmt=WPA-PSK
		psk=""
	}
	EOF
	pkill wpa_supplicant
	ifconfig wlan0 down
	ifconfig wlan0 up
	iwconfig wlan0 essid "wpatest"  # channel 7
	wpa_supplicant -B -Dnl80211 -iwlan0 -c/etc/wpa_supplicant.conf  # -D wext
	busybox udhcpc -x hostname iamhere -i wlan0  # dhcpcd
	EOF
	# iwconfig has ‘sens’ parameter to send roaming agressiveness. How to do that
	#   with wpa_supplicant?
	# From https://www.pantz.org/software/wpa_supplicant/wirelesswpa2andlinux.html
}

iforgot-wifi-scan() {
	echo -e "\tiwlist wlan0 scanning"
}

iforgot-tee-usage() {
	cat <<-"EOF"
	wget -O - http://example.com/dvd.iso \
	| tee dvd.iso | sha1sum > dvd.sha1

	wget -O - http://example.com/dvd.iso \
	| tee >(sha1sum > dvd.sha1) \
	>(md5sum > dvd.md5) \
	> dvd.iso

	tardir=your-pkg-M.N
	tar chof - "$tardir" \
	| tee >(gzip -9 -c > your-pkg-M.N.tar.gz) \
	| bzip2 -9 -c > your-pkg-M.N.tar.bz2
	EOF
}

iforgot-kaomozi-drawing() {
	cat <<-"EOF"
	▽△　▲▼    sankaku
	☆★＊      hoshi
	〆        shime
	米※       kome
	益        yaku
	✨        sparkles

	(⚈益⚈)    (⌕…⌕)    ( °ヮ°)    (´Д ` )    ╭(＾▽＾)╯

	/(⌃ o ⌃)\    ╰(^◊^)╮    ◜(◙д◙)◝    (ʘ‿ʘ)    (≖‿≖)

	´ ▽ ` )ﾉ    (・∀・ )    (ΘεΘ;)    ╮(─▽─)╭    (≧ω≦)

	(´ヘ｀ ;)    (╯3╰)     (⊙_◎)    (¬▂¬)    ¬_¬

	´ ▽ ` )ﾉ  ôヮô  ŎםŎ   ಥ﹏ಥ   ᕙ(⇀‸↼‶)ᕗ   ≧ヮ≦

	☜(ﾟヮﾟ☜)    ヽ(´ｰ｀ )ﾉ    (¬‿¬)

	(•̀ᴗ•́)و    (⁄ ⁄•⁄ω⁄•⁄ ⁄)    (　-᷄ ω -᷅ )     ¯\_(ツ)_/¯

	⊙﹏⊙    (•⊙ω⊙•)    (๑•̀ㅂ•́)و✧        ٩(๑òωó๑)۶

	(ง •̀ω•́)ง✧        (๑¯﹀¯๑)えへん！         (´▽`ʃƪ)♡


	(つд⊂)    ( ^▽^)σ)~O~)

	キタ━━━(゜∀゜)━━━!!!!!

	( ˙灬˙ )   (・∀・)~mO     m9(・∀・) 	ヽ(°Д°)ﾉ    (╬♉益♉)ﾉ

	Ԍ──┤ﾕ(#◣д◢)    (☞ﾟヮﾟ)☞    ( `-´)>    (*ﾟﾉOﾟ)<ｵｵｵｵｫｫｫｫｫｫｫｰｰｰｰｰｲ!

	Σ(゜д゜;)    (*´Д`)ﾊｧﾊｧ    (ﾟДﾟ;≡;ﾟДﾟ)

	( ﾟ∀ﾟ)ｱﾊﾊ八 八 ﾉヽ ﾉヽ ﾉヽ ﾉ ＼  / ＼ / ＼

	（･∀･)つ⑩     щ(ﾟДﾟщ)(屮ﾟДﾟ)屮

	（・Ａ・)    (*⌒▽⌒*)    ＼| ￣ヘ￣|／＿＿＿＿＿＿＿θ☆( *o*)/

	(l'o'l)     (╯°ロ°）╯  ┻━━┻        ┬──┬ ﻿ノ( ゜-゜ノ)

	Mahjong tile (chun): 🀄


	EOF
}

iforgot-sed-newline-simple-removal() {
	cat <<-"EOF"
	echo -e '1\n2\n3\n4\n5' | sed -rn '1h; 2,$ H; ${x;s/\n/---/g;p}'
	EOF
}

iforgot-diff-patch() {
	echo -e "\tdiff -u file1 file2"
}

iforgot-gpg-privkey() {
	cat <<-"EOF"
	Very good! Now, like I said above, using this is pretty much like using a “regular” GPG keypair; the only exception is when signing other people’s keys, or add or revoking subordinate keys. For this you build a command pointing to the two locations. For example,

	gpg --homedir /media/Secure/dotgnupg/ \
	--keyring ~/.gnupg/pubring.gpg \
	--secret-keyring ~/.gnupg/secring.gpg \
	--trustdb-name ~/.gnupg/trustdb.gpg \
	--edit-key MYKEYID

	should allow you to add or revoke subordinate keypairs, or do any other operation that requires the private master key. You should keep in mind though, that changes to keys other than your own will be done on your “everyday” GPG folder (~/.gnupg), but changes to your own key—adding a new subkey, for example—will be done on the secure location (/media/Secure/dotgnupg). After doing such a change, you must export your key (in the example to the file aux.asc), and re-import it to the everyday GPG folder:

	gpg --homedir /media/Secure/dotgnupg/ \
	--output aux.asc \
	--armor \
	--export MYKEYID
	gpg --import aux.asc
	rm aux.asc
	EOF
}

iforgot-io-monitoring() {
	echo iotop
}

iforgot-bash-last-argument-from-previous-command() {
	echo 'echo !$'
}

iforgot-qemu-create-image() {
	cat <<-EOF
	qemu-img create -f qcow2 -o
	compat=1.1,
	cluster_size=512,
	preallocation=metadata,
	lazy_refcounts=on
	<filename> <size>
	EOF
}

iforgot-du-sort() {
	echo -e '\tdu -hsx * | sort -h'
}

iforgot-font-list() {
	echo -e '\tfc-list'
}

iforgot-fsck-with-progressbar() {
	cat <<-EOF
	fsck -C -l /dev/sdb3 -- -c -f -y
	       \  \    \          \  \  \_ autoyes
	        \  \    \          \  \_ check even if fs looks clean
	         \  \    \          \_ check for bad blocks
	          \  \    \_ partition with filesystem
	           \  \_ lock the whole-disk device by an exclusive flock(2)
	            \_ use progressbar/completion for checkers that support it
	              (generally ext2/3/4)
	EOF
}

iforgot-completion-keys() {
	cat <<-"EOF"
	"\e@": complete-hostname
	"\e{": complete-into-braces
	"\e~": complete-username
	"\e$": complete-variable
	EOF
}

iforgot-iptables() {
	cat <<-"EOF"
	Destination NAT means, we translate the destination address of a packet to make it go somewhere else instead of where it was originally addressed.

	# iptables -t nat -A  PREROUTING        -d 10.10.10.99/32                  -j DNAT --to-destination 192.168.1.101:22 --comment "It’s for the fun of it."
	                                 -p tcp                    --dport 22022

	Source NAT. We want to do SNAT to translate the from address of our reply packets to make them look like they’re coming from 10.10.10.99 instead of 192.168.1.101.

	# iptables -t nat -A POSTROUTING -s 192.168.1.101/32 -j SNAT --to-source 10.10.10.99 --comment "It’s for the fun of it."

	Sometimes SNAT doesn’t suit the task, if the --to-source IP address is dynamic. Iptables can dynamically get the address, if you use MASQUERADE, but it is slower.

	# iptables -t nat -A POSTROUTING -s 10.0.0.0/24 --sport 123[:789] \
	           -d 10.1.0.0/24 --dport 456[:654] \
	           -o OUT_IFACE -j MASQUERADE

	To delete a rule, get its number first:

	# iptables -L -t nat --line-number

	Then delete:

	# iptables -t nat -D POSTROUTING <number>

	From https://thewiringcloset.wordpress.com/2013/03/27/linux-iptable-snat-dnat/
	http://www.karlrupp.net/en/computer/nat_tutorial
	EOF
}

iforgot-iptables-multicast-forward() {
	cat <<-EOF | sed -r 's/^\s*//g'
	    cat <<-EOF >/etc/igmpproxy/igmpproxy.conf
	    quickleave
        phyint vlan102 upstream  ratelimit 0  threshold 1
	    altnet 192.168.12.0/24
	    #        altnet 10.0.0.0/8
	    #        altnet 192.168.0.0/24
	    phyint eth2 downstream  ratelimit 0  threshold 1
	    ##ip link show | sed -rn 's/^[0-9]+:\s([^:@]+)@?\S*:.*/phyint \1 disabled/p' >>/etc/igmpproxy/igmpproxy.conf
	    phyint lo disabled
	    phyint eth0 disabled
	    phyint eth1 disabled
	    EOF

	iptables -t filter -A INPUT -d 224.0.0.0/240.0.0.0 -i eth0 -j ACCEPT
	iptables -t filter -A INPUT -s 224.0.0.0/240.0.0.0 -i eth0 -j ACCEPT
	iptables -t filter -A FORWARD -d 224.0.0.0/240.0.0.0 -j ACCEPT
	iptables -t filter -A FORWARD -s 224.0.0.0/240.0.0.0 -j ACCEPT
	# Increase TTL because without it packets most probably won’t live long enough to pass the router.
	modprobe ipt_TTL
	iptables -t mangle -A PREROUTING -d 224.0.0.0/240.0.0.0 -p udp -j TTL --ttl-inc 1

	# Port forwarding
	iptables -A PREROUTING -t nat -s 1.1.1.1 -i eth0 -p tcp --dport 80 -j DNAT --to 2.2.2.2:8080
	iptables -A FORWARD -p tcp -d 2.2.2.2 --dport 8080 -j ACCEPT
	EOF
}

iforgot-shell-colours(){
	cat <<-EOF
	There are only 8 colors in general. From man terminfo:
	Color     #define         Value   RGB
	black     COLOR_BLACK       0     0, 0, 0
	red       COLOR_RED         1     max,0,0
	green     COLOR_GREEN       2     0,max,0
	yellow    COLOR_YELLOW      3     max,max,0
	blue      COLOR_BLUE        4     0,0,max
	magenta   COLOR_MAGENTA     5     max,0,max
	cyan      COLOR_CYAN        6     0,max,max
	white     COLOR_WHITE       7     max,max,max

	Escape sequence to set a color is \e[00;3xm, where x is 0–7.
	Some interesting capabilities:
	EOF
	echo -e '	- \e[0;1mbold:\e[00m \\e[0;1m (in normal terminals bold replaced\n	  with bright version of a color);'
	echo -e '	- \e[0;4munderline:\e[00m \\e[0;4m (don’t expect that the line will be\n	  of same color as the char above it);'
	echo -e '	- \e[07;36mreverse:\e[00m \\e[0;7m (background and foreground);'
	echo -e '	- stop: \\e[00m.\n'
	echo -e '	Example of \\e[01;32m\e[01;32mbold green text\e[00m\\e[00m.'

	cat <<-EOF

	As far as I know, there’s no way to query the colors of the terminal
	emulator. You can change them with \e]4;NUMBER;#RRGGBB\a (where NUMBER is
	the terminal color number (0–7 for light colors, 8–15 for bright colors)
	and #RRGGBB is a hexadecimal RGB color value) if your terminal supports
	that sequence (reference: ctlseqs). —http://unix.stackexchange.com/a/1772/10075
	See also http://misc.flogisoft.com/bash/tip_colors_and_formatting
	EOF
}

iforgot-clean-gentoo() {
	cat <<-EOF
	# Remove unnecessary packages
	1. emerge -av --depclean
	# …distfiles except matching by exact installed version
	and those downloaded earlier than two days ago.
	2w [eeks] 3m [onth] also accepted.
	2. eclean-dist -d -t2d
	# Remove binary packages
	3. eclean packages
	EOF
}

iforgot-cut-video-with-ffmpeg() {
	cat <<-EOF
	ffmpeg -y -threads 8 -i in.webm -ss 00:00:01 -t 00:02:22 -async 1 -b:v 500k out.webm

	+crop
	-filter:v "crop=WIDTH:HEIGHT:X_OFFSET:Y_OFFSET"

	Webm issues: it ignores -b:v -minrate -maxrate and -crf. Use -qmin and -qmax.
	ffmpeg -y -threads 8 -async 1 \
	-i /home/video/anime/\[ReinForce\]\ Ergo\ Proxy\ \(BDRip\ 1920x1080\ x264\ FLAC\)/\[ReinForce\]\ Ergo\ Proxy\ -\ 11\ \(BDRip\ 1920x1080\ x264\ FLAC\).mkv  -ss 00:00:00 \
	-t 00:00:15.849 -b:v 12M -crf 4 -minrate 12M -maxrate 12M -qmin 0 -qmax 0 -vf scale=1280:720 /tmp/out.webm
	EOF
}

iforgot-catenate-video-with-ffmpeg() {
	cat <<-EOF
	find . -iname "part*.webm" | sort >files
	ffmpeg -y -threads 8 -f concat -i files -c copy -async 1 out.webm
	EOF
}

iforgot-record-my-desktop() {
	cat <<-"EOF"
	General:

	ffmpeg -y -hide_banner \
	       -framerate 25  -f x11grab  -s 1920x1080  -i :0.0+0,0  \
	       -vcodec libx264 -g 50 -keyint_min 25 -r 25  \
	           -b:v 0  -crf 0  -pix_fmt yuv420p  \
	           -preset medium  -tune film  \
	           -threads 4  \
	           -strict normal -bufsize 4500k -movflags +faststart  \
	       ~/desktop/tld_eng.mp4

	+Audio:  -f alsa -ac 2 -i hw:0 -async 1 -acodec pcm_s16le
	−Audio:  -an

	+Crop: -i :0.0+0,25

	P.S. mpv’s -vo must be switched to gpu profile=hq
	     for ffmpeg to be able to catch its output.
	EOF
}

iforgot-check-own-process-memory() {
	cat <<-EOF
	pmap from procps.
	# pmap -d `pidof X`
	Writeable — this is it.
	EOF
}

iforgot-commie-check-whats-up() {
	echo -e "\t.blame <what>"
}

iforgot-firefox-settings() {
	cat <<-EOF
	See ~/.mozilla/profile.default/user.js
	To check:
	about:cache
	about:cache?device=memory

	In case of troubles with SWF
	echo 'application/x-shockwave-flash       swf swfl' > .mime.types
	EOF
}


iforgot-mpv-crunchyroll-streaming() {
	# requires ffmpeg to be compiled with networking and rtmp
	echo 'mpv --ytdl http://www.crunchyroll.com/parasyte-the-maxim-/episode-1-metamorphosis-662583'
}


iforgot-ffmpeg-audio-recording() {
	cat <<-EOF
	Record:
	arecord -f cd -t wav s.wav

	Conversion to MP3 VBR
	ffmpeg -i s.wav -codec:a libmp3lame -qscale:a 0 `date`.mp3
	^
	fine quality

	lame    Avg    b/rate range  ffmpeg
	option  kbit/s     kbit/s     option

	-b 320   320      320 CBR     -b:a 320k (non VBR. NB this is 32KB/s, or its max)
	-V 0     245      220-260     -q:a 0 (NB this is VBR from 22 to 26 KB/s)
	-V 1     225      190-250     -q:a 1
	-V 2     190      170-210     -q:a 2
	-V 3     175      150-195     -q:a 3
	-V 4     165      140-185     -q:a 4
	-V 5     130      120-150     -q:a 5
	-V 6     115      100-130     -q:a 6
	-V 7     100       80-120     -q:a 7
	-V 8      85       70-105     -q:a 8
	-V 9      65        45-85     -q:a 9
	EOF
}

iforgot-wcpe-station-time-zone-difference() {
	echo -8
}

iforgot-lowriter-images() {
	cat <<-EOF
	When an image is inserted in a libreoffice writer document, lowriter uses 90 dpi (not desktop resolution) by default. Thus, while importing an SVG file in GIMP it’s necesary to set corresponding dpi and count appropriate width according to that. GIMP advises 1000px width by default, but that gives 282.24 mm of width after import to libreoffice. ESPD doc width excluding fields is 180 mm. After import to lowriter, in the document body image will look awry even if you guess the 100 % scale right. But it only seems like it, after the export to PDF with lossless image compression it’ll look as it should.
	EOF
}

iforgot-libreoffice-pdf-export() {
	take off flag  embedding ODT when sending to potential employer.
	set flag for PDF/A-1a, that format is for docs to be stored for a long term. Fonts are embedded.
}

iforgot-pdf-split() {
	echo -e '\t$ gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER -dFirstPage=1
	-dLastPage=4 -sOutputFile=outputT4.pdf T4.pdf'
}

iforgot-pdf-grep() {
	cat <<-"EOF"
	find /path -name '*.pdf' -exec sh -c 'pdftotext "{}" - | grep --with-filename --label="{}" --color "your pattern"' \;
	EOF
}

iforgot-voip-via-netcat() {
	cat <<-"EOF"
	(read; echo; rec --buffer 17 -q -w -s -r 48000 -c 1 -t raw -)|netcat -u -l -p 8888|(read; play -w -s -r 48000 --buffer 17 -t raw -)
	(echo; rec --buffer 17 -q -w -s -r 48000 -c 1 -t raw -)|netcat -u 192.168.1.1 8888|(read; play -w -s -r 48000 --buffer 17 -t raw -)
	EOF
}

#removes *.desktop files
iforgot-wine-clean-desktop() {
	rm /home/sszb/.wine/drive_c/users/sszb/#msgctxt#directory#Desktop/*
}

iforgot-wget-mirror-site() {
	cat <<-"EOF"
	wget --mirror --convert-links --adjust-extension --page-requisites --no-parent http://example.org'
	or shorter:
	wget -mkEpnp http://example.org
	EOF
}

iforgot-wifi-why-it-doesnt-work() {
	cat <<-"EOF"
	card is requiring CONFIG_CFG802011_WEXT=y
	card is hw/soft bloced: rfkill list
	card is in wrong CRDA region: iw reg get/set <AA>
	EOF
}

iforgot-audio-conversion() {
	echo -e '\tffmpeg -i input.wav -vn -ar 44100 -ac 2 -ab 192k -f mp3 output.mp3'
}

iforgot-keyboard-print-map() {
	cat <<-"EOF"
	Test print

	setxkbmap -model latitude -print \
	| xkbcomp -xkm - - \
	| xkbprint -label symbols -color -eps - - \
	| ps2pdf - > xkblayout.pdf; zathura xkblayout.pdf

	Current keyboard clean image (can be openen in inkscape with postscript support enabled)

	xkbprint -label none -color -eps :0 -o kbmap.eps
	EOF
}

iforgot-grub-update() {
	cat <<-"EOF"
	grub --no-floppy </dev/sdX>
	grub > root (hdM,N)            ← where M is number of disk sdX (start with 0),
	and N is partition with grub files (usually 0 or 1)
	grub > setup (hdM)
	grub > quit
	Also
	grub-install --no-floppy /dev/sdX
	EOF
}

iforgot-git-update-submodule-each-and-every-one() {
	echo 'git submodule foreach git pull origin master'
}

iforgot-check-unicode-symbol() {
	cat <<-EOF
	echo -n 'ß' | uniname
	echo -n $'\'' | uniname
	EOF
}

iforgot-clean-git-repo-totally() {
	cat <<-EOF
	Removing the origin just to make sure no reference is kept.

	$ git remote rm origin
	$ echo $(git log --reverse --format=%H | head -n1) > .git/info/grafts
	$ git filter-branch -- --all
	Rewrite 4352ea1fb4b0dfa5d28ad26ce6b9e042b126bd60 (8/8)
	Ref 'refs/heads/master' was rewritten
	$ rm .git/info/grafts
	$ du -sh .git
	121M    .git

	However, the repository size is quite big, still. It's basically the same as in the beginning. Git doesn't just delete old files that don't have a reference anymore (you have to actually tell it to do that). There are mechanisms to keep your repository clean (automatic git gc after a while, but still we want a clean repository, now).

	To actually remove all references to old git objects, you need to do quite a few things:
	- Remove the filter-branch backup.
	- Expire the reflog.
	- Garbage collect everything.
	If you forget just one thing you might end up with the old repository size, because if the reference remains, `git gc` is unable to remove the old objects.

	$ git update-ref -d refs/original/refs/heads/master
	$ git reflog expire --expire=now --all
	$ git gc --prune=now --aggressive
	$ du -sh .git
	164K    .git

	Source: http://jedidjah.ch/code/2014/8/28/purge_old_git_history/ 28.08.2014
	EOF
}

iforgot-audio-mixing() {
	cat <<-EOF
	First, you need snd_aloop module from the kernel

	Symbol: SND_ALOOP [=y]
	Prompt: Generic loopback driver (PCM)
	Location:
	-> Device Drivers
	-> Sound card support (SOUND [=y])
	-> Advanced Linux Sound Architecture (SND [=y])
	-> Generic sound devices (SND_DRIVERS [=y])

	Then, you’ll need to create a virtual card for it. See ~/.asoundrc.
	But after activating it, dumb ALSA will probably make the Loopback
	device the first and the default card, so you’ll have to alter
	module options, adding
	snd_aloop.index=2
	or something to the kernel
	command line. No, altering with ~/.asloftrc won’t help. Dunno, why.
	You can check with
	mpv --audio-device=help — the sound should be gone
	unless they finally fixed it.
	And finally, you can use the device for recording with a command like

	arecord -D "hw:2,1" -f cd -t wav /tmp/s.wav
	EOF
}

iforgot-cd-back() { echo -e '\tcd -'; }

iforgot-hex-to-dec-conversion() {
	cat <<-"EOF"
	From hex to dec:
	$ echo $(( 16#FF ))
	255
	$ echo "ibase=16; FFF" | bc  # NB the upper case
	4095
	$ printf "%d\n" 0xA  # NB 0x
	10

	From dec to hex:
	$ echo "obase=16; 10" | bc
	A
	$ printf "%x\n" 11
	b

	Pad the number, that must be 5 digit long with zeroes:
	$ printf "%05x\n" 91
	0005b

	For printf use ‘x’ to print abcdef and ‘X’ for ABCDEF.
	EOF
	# bc and printf examples are taken from here:
	# http://www.cyberciti.biz/faq/linux-unix-convert-hex-to-decimal-number/
}

iforgot-nested-xorg-xephyr() {
cat <<"EOF"
	At 1500–1800 dpi Xephyr window refuses to take its actual size,
	but scrot still works. Though a horisontal part that’s out of the visible
	view, may appear white. If that happens, scroll the browser window.
	­
	 # Fun options
	#  -resizeable  to make the window resizeable
	#  -listen tcp  to listen on tcp port from the network
	#  -ac          lift restictions on Xauth (Xephyr has troubles sometimes)
	#
	$ Xephyr :108 -dpi 300 -screen 3413x1920 &
	­
	Alternative.
	­
	$ Xephyr :108 -dpi 1800 -screen 20480x11520
	DISPLAY=:108 /usr/bin/vivaldi &>/dev/null &
	­
	Firefox has problems
	DISPLAY=:108 /usr/bin/firefox --profile ~/.mozilla/firefox/highdpi.profile &>/dev/null &
	xbrc="$HOME/.mozilla/firefox/highdpi.profile/.xbindkeys.rc"
	cat <<-"EOF" >$xbrc
	; bind shift + vertical scroll to horizontal scroll events
	(xbindkey '(shift "b:4") "xte 'mouseclick 6'")
	(xbindkey '(shift "b:5") "xte 'mouseclick 7'")
	EOF
	­
	DISPLAY=:108 xbindkeys -f $xbrc
	DISPLAY=:108
	DISPLAY=:108 scrot
EOF
}

iforgot-eix() {
	cat <<-EOF
	Show what’s installed from an overlay
	$ eix --only-names --installed-from-overlay <overlay>
	Also helpful
	$ equery has repository sunrise
	Find a package by [category/]name
	$ eix -A [category/]name
	Find packages by description
	$ eix -S "viewer"
	Find pacakges by description in a particular category
	$ eix -S "viewer" -C app-text


	-c   compact view


	EOF
}

iforgot-mkfs-ext4-options() {
	cat <<-EOF
	For /boot:
	# 40–50 MiB should be enough.

	For /:
	# 1. 350K inodes is a minimum for a root FS without /home and ccache.
	#    Ccache would take 250k inodes for 3.6 Gigs of memory.
	# 2. If you plan deploying chroots, consider adding another 350K per chroot, better 400K
	mkfs.ext4 -j -L "root" -b1024 -O extent,dir_index -N 350000 /dev/sda2

	For /home:
	# For home, the number of inodes is around 500K per TB.
	mkfs.ext4 -j -L "home" -m0 -O extent,dir_index,sparse_super -N 500000  /dev/sda3

	Latest creating a new / (no /home, ccache=4G):
	1. After compiling
	   @system twice
	# df -h /
	Filesystem      Size  Used Avail Use% Mounted on
	/dev/sdc4        40G  3.5G   35G  10% /

	# df -hi /
	Filesystem     Inodes IUsed IFree IUse% Mounted on
	/dev/sdc4        480K  315K  166K   66% /

	2. After compiling
	   ~one third of the @world
	# df -h /
	Filesystem      Size  Used Avail Use% Mounted on
	/dev/sdc4        40G  9.1G   29G  24% /

	# df -hi /
	Filesystem     Inodes IUsed IFree IUse% Mounted on
	/dev/sdc4        480K  479K  2.0K  100% /

	3. After compiling almost everything of the @world expect ~20 packages,
	   that depend on ffmpeg. Also yad, scim-anthy.
	# df -h /
	Filesystem      Size  Used Avail Use% Mounted on
	/dev/sdc4        40G   19G   20G  49% /

	# df -hi /
	Filesystem     Inodes IUsed IFree IUse% Mounted on
	/dev/sdc4        960K  752K  209K   79% /

	# CCACHE_DIR="/var/tmp/ccache" ccache -s
	cache hit (direct)                 44410
	cache hit (preprocessed)           52245
	cache miss                        240467
	cache hit rate                     28.67 %
	multiple source files                 44
	compile failed                     12289
	ccache internal error                  7
	preprocessor error                  7169
	can't use precompiled header          82
	bad compiler arguments              6740
	unsupported source language           70
	autoconf compile/link              75586
	unsupported compiler option         3125
	unsupported code directive             6
	output to stdout                      14
	no input file                      22942
	cleanups performed                   103
	files in cache                    243541
	cache size                           3.6 GB
	max cache size                       5.0 GB

	After compiling firefox with pgo
	# df -hi /
	Filesystem     Inodes IUsed IFree IUse% Mounted on
	/dev/sdc4        1.5M  1.1M  420K   72% /
	While…
	#  CCACHE_DIR="/var/tmp/ccache" ccache -s
	files in cache                     72649
	cache size                           3.6 GB

	After cleaning /var/tmp/portage on the dirty firefox-55 +pgo build
	# df -hi /
	Filesystem     Inodes IUsed IFree IUse% Mounted on
	/dev/sdc4        1.5M  652K  829K   45% /

	Firefox + pgo needs 409 000 inodes

	# df -h /
	Filesystem      Size  Used Avail Use% Mounted on
	/dev/sdc4        40G   21G   18G  54% /
	# df -hi /
	Filesystem     Inodes IUsed IFree IUse% Mounted on
	/dev/sdc4        1.5M  633K  848K   43% /

	emerge -cav
	eclean-dist -df
	eclean-pkg -dn
	rm -rf /var/tmp/portage/*
	CCACHE_DIR="/var/tmp/ccache" ccache -C

	# df -h /
	Filesystem      Size  Used Avail Use% Mounted on
	/dev/sdc4        40G   15G   23G  40% /

	# df -hi /
	Filesystem     Inodes IUsed IFree IUse% Mounted on
	/dev/sdc4        1.5M  553K  928K   38% /


	EOF
}

iforgot-nmap-scan() {
	cat <<-EOF
	# nmap [-A] -Pn -T4 -sS -p 22,8087 127.0.0.1
	-A  add traceroute and version info
	-Pn ping type: none — skip host discovery
	-PR ping type: ARP — check hosts in LAN
	-PU ping type: UDP
	-PA ping type: TCP ACK
	-PS ping type: TCP SYN
	-T4 timing template (↑ is faster)
	-sS port scan: TCP SYN scan method — most versatile
	-sn port scan: no
	EOF
}

iforgot-hierarchy-of-linux-fs() { echo -e '\tman hier'; }

iforgot-ssh-jump-through-gateway() {
	cat <<-EOF
	1. Tunneling
	ssh -f gate_user@gate_ip -L [localhost:]<big_port>:<host_behind_gw>:<sshd_port_on_that_host> -N && ssh -p<big_port> <user_at_host_behind>@localhost
	alias pass-me-through="ssh -p4444 -f tunnel@randomfucks.com -L 20000:192.168.1.15:22 -N && ssh -p20000 me@localhost"
	scp -P <any_port> localhost:REMOTEPATH LOCALPATH
	scp -P <any_port> LOCALPATH localhost:REMOTEPATH

	2. Proxying
	Host gw
	Hostname II.PP.II.PP

	Host behind
	HostName PP.II.PP.II
	ProxyCommand  ssh -qW %h:%p gw
	EOF
}

iforgot-ssh-forward-80-port() {
	cat <<-EOF
	Say we have imgur.com blocked in our network. But there is a server which can access it.
	ssh -N -L 9000:imgur.com:80 user@server
	Then open localhost:9000 in your browser.
	EOF
}

iforgot-ssh-multiple-port-forward() {
	cat <<-EOF
	Supermicro
	root # ssh -f GATE -L 9000:IP_BEHIND_NAT:80 -L 443:IP_BEHIND_NAT:443 -L 623:IP_BEHIND_NAT:623 -L 5900:IP_BEHIND_NAT:5900 -N
	iLO
	root # ssh -f GATE -L 9000:IP_BEHIND_NAT:80 -L 443:IP_BEHIND_NAT:443 -L 17988:IP_BEHIND_NAT:17988 -L 17990:IP_BEHIND_NAT:17990 -N
	EOF
}

iforgot-ssh-clear-known-hosts-from-a-host() {
	echo 'ssh-keygen -f ~/.ssh/known_hosts -R <host with invalid key>'
}

iforgot-qemu-system-or-user() {
	cat <<-EOF
	THe difference between qemu-system-* and qemu-user-* is that…
	> qemu-system-xxx, which is an emulated machine for architecture xxx (System Emulation). When it resets, the starting point will be the reset vector of that architecture. While xxx-linux-user, compiles qemu-xxx, which allows you to run user application in xxx architecture (User-mode Emulation). Which will seek the user applications' main function, and start execution from there.
	http://stackoverflow.com/a/32435507
	In order to launch a Linux process, QEMU needs the process executable itself and all the target (x86) dynamic libraries used by it. On x86, you can just try to launch any process by using the native libraries:
	$ qemu-i386 -L / /bin/ls
	qemu is used to run a whole system: from kernel to a UI, which includes many process working as an operating system qemu-softmmu is a accelerator for mapping memory and IO, so it cannot work alone, it need a master. so I guess it is a part of qemu indeed. So a qemua-user can run a single program of a (different) type of OS without emulating a whole living OS.
	https://forums.gentoo.org/viewtopic-p-6270729.html?sid=0038823980fbcef5643128181d129bc1#6270729
	EOF
}

iforgot-tcpdump-check-multicast() {
	cat <<-EOF
	Specific host:
	tcpdump -tni eth0 -s0 -vv host 239.255.255.250
	All multicast:
	tcpdump -tni eth0 -s0 -vv net 224.0.0.0/4

	Don’t forget to check smcroute join/leave.
	EOF
}

iforgot-lsof-fuser() {
	cat <<-EOF
	fuser -m <filesystem>
	lsof | grep <filesystem>
	vmtouch <file>
	EOF
}

iforgot-tcpdump-usage() {
	# http://www.rationallyparanoid.com/articles/tcpdump.html
	cat <<-EOF
	See the list of interfaces on which tcpdump can listen:
	tcpdump -D
	Be verbose:
	tcpdump -v
	tcpdump -vv
	tcpdump -vvv
	…and print the data of each packet in both hex and ASCII, excluding the link level header:
	tcpdump -v -X
	…but including the link level header:
	tcpdump -v -XX

	Be quiet while capturing packets:
	tcpdump -q
	Limit the capture to 100 packets:
	tcpdump -c 100
	Record the packet capture to a file called capture.cap:
	tcpdump -w capture.cap
	…but display on-screen how many packets have been captured in real-time:
	tcpdump -v -w capture.cap

	Listen
	…on interface eth0:
	tcpdump -i eth0
	…on any available interface (cannot be done in promiscuous mode. Requires Linux kernel 2.2 or greater):
	tcpdump -i any

	Display
	IP addresses and port numbers (try -nn)
	tcpdump -n
	The packets of a file called capture.cap:
	tcpdump -r capture.cap
	The packets using maximum detail of a file called capture.cap:
	tcpdump -vvv -r capture.cap

	Timestamps
       17:16:13.258263
	-t  <no timestamp>
	-tt  in raw numbers
	-ttt  Δ between current and previous frame
	-tttt  = default+date
	-ttttt  Δ between current and first frame.

	Capture
	By host:
	tcpdump -n host 192.168.1.1
	tcpdump -n dst host 192.168.1.1
	tcpdump -n src host 192.168.1.1
	By network:
	tcpdump -n net 192.168.1.0/24
	tcpdump -n dst net 192.168.1.0/24
	tcpdump -n src net 192.168.1.0/24
	By destination port:
	tcpdump -n dst port 23
	tcpdump -n dst portrange 1-1023
	…also filter by protocol:
	tcpdump -n tcp dst portrange 1-1023
	tcpdump -n udp dst portrange 1-1023
	By destination IP and destination port:
	tcpdump -n "dst host 192.168.1.1 and dst port 23"
	tcpdump -n "dst host 192.168.1.1 and (dst port 80 or dst port 443)"
	By protocol
	tcpdump -v icmp
	tcpdump -v arp
	tcpdump -v "icmp or arp"
	Broadcast or multicast:
	tcpdump -n "broadcast or multicast"
	500 bytes of data for each packet rather than the default of 68 bytes:
	tcpdump -s 500
	All bytes of data within the packet:
	tcpdump -s 0


	 # DEEP SCAN
	#
	Filter to match DHCP packets including a specific client MAC address:
	tcpdump -i br0 -vvv -s 1500 '((port 67 or port 68) and (udp[38:4] = 0x3e0ccf08))'
	Filter to capture packets sent by the client (DISCOVER, REQUEST, INFORM):
	tcpdump -i br0 -vvv -s 1500 '((port 67 or port 68) and (udp[8:1] = 0x1))'

	Show Ethernet header:
	tcpdump -e
	EOF
}

iforgot-git-amend() {
	cat <<-"EOF"
	If you haven’t pushed changes upstream, ‘git commit --amend’ should be enough.
	If you did, you have to rebase the current HEAD.
	git rebase -i HEAD~2
	will print the last commit, and you should delete the last of two lines,
	then do
	git push origin +master
	EOF
}

iforgot-tail-print-from-nth-line() {
	cat <<-EOF
	Remove all but the last filename.
	ls -r | tail -n+2 | xargs rm
	EOF
}

iforgot-convert-combine-images-together() {
	cat <<-EOF
	Use convert from imagemagick.
	convert  img1.png  img2.png img3.png -append out.png

	-append → from top to bottom
	+append → from left to right
	EOF
}

iforgot-google-search() {
	cat <<-"EOF"
	+word — Doesn’t work unless you search for G+ things or blood type.
	-excludethis
	"exact phrase"
	a * saved is a * earned
	100..200

	token:example.com
	site:       anything from this site
	related:    …or the sites related to it
	info:       information about the web address
	cache:      pages from the google cache

	this OR that

	From https://support.google.com/websearch/answer/2466433
	EOF
}

iforgot-screen-commands() {
	cat <<-"EOF"
	Ctrl+a c    new window
	Ctrl+a n    next window
	Ctrl+a p    previous window
	Ctrl+a "    select window from list
	Ctrl+a Ctrl+a    previous window viewed
	Ctrl+a :fit    fit screen size to new terminal size.
	Ctrl+a F is the same. Do after resizing xterm.
	Ctrl+a d    detach screen from terminal.
	            Start screen with -r option to reattach
	Ctrl+a A    set window title
	Ctrl+a x    lock sessiion, enter user password to unlock.
	Ctrl+a [    enter scrollback/copy mode. Enter to start
	            and end copy region. Ctrl+a ] to leave this mode.
	Ctrl+a ]    paste buffer. Supports pasting between windows.
	Ctrl+a >    write paste buffer to file,
	            useful for copying between screens
	Ctrl+a <    read paste buffer from file,
	            useful for pasting between screens
	Ctrl+a ?    show key bindings/command names.
	Note unbound commands only in man page.
	Ctrl+a :    goto screen command prompt up shows last command entered
	EOF
}

# Keybindings below aren’t the default ones.
iforgot-tmux() {
	cat <<-"EOF"
	Starting tmux:
	1. tmux -uL <socket name> new -ds <session name>
	         ^^                    ^^
	         ||                    |└─  name new session
	         ||                    └─  detach immediately
	         |└─  create custom socket
	         └─  enable unicode support
	2. tmux -L username new

	Check available sessions:
	    tmux -L root list-sessions

	Attach to an existing session from the outside
	or switch between client sessions inside:
	    tmux -L root attach [-t <session name>]

	Keys
	C-a c    Create new window
	d        Detach client
	j        Prev window
	l        Next window
	Space    Last window
	r        Respawn window
	R        Reload ~/.tmux.conf
	w        Choose window interactively
	x        Close pane/window
	2        Split horizontally
	3        Split vertically
	o        Move between panes in a split window
	4        Rename window
	$        Rename session
	?        List-keys
	:lsk     — » —
	:list-keys    — » —
	:monitor-activity <on|off>    Enable/disable activity
	                              monitoring
	:monitor-content <string>     The same, but for the
	                              specified string.
	EOF
}

iforgot-find-newer-older() {
	cat <<-"EOF"
	Find those that have been modified in the last two days
	i.e. newer than 2 days:
	find -mtime -2

	Find the files older than 2 days:
	find -mtime +2
	EOF
}

iforgot-find-exclude() {
	cat <<-"EOF"
	Prune
	find -mtime -2

	Find the files older than 2 days:
	find -mtime +2
	EOF
}

iforgot-trace-there-and-back() {
	cat <<-EOF
	ping -R -c1 XX.XX.XX.XX
	NB: 9 hops max!
	EOF
}

iforgot-easyrsa-procedure() {
	cat <<-EOF
	Copy to another place
	    cp -a /usr/share/easy-rsa /root/easy-rsa-example
	    cd !$

	Edit ‘vars.example’ and save it as ‘vars’
	    nano vars.example

	Prepare directories
	    easyrsa init-pki

	Create CA certificate and key. That passphrase must be common for our company.
	    easyrsa build-ca

	Create parameters for the Diffie–Hellman exchange
	    easyrsa gen-dh

	Generate crl.pem
	    easyrsa gen-crl

	Generate TLS authentication key
	    openvpn --genkey --secret pki/private/ta.key

	Build server certificate and key.
	    easyrsa build-server-full SERVERNAME

	Generate a passphrase for its client
	    openssl rand -base64 6

	… and build client’s certificate and key.
	    easyrsa build-client-full CLIENTNAME

	To decrypt a key in order to avoid entering passphrase every time
	    cd pki/private
	    cp NAME.key NAME.key NAME.key.org
	    openssl rsa -in ./NAME.key.org -out ./NAME.key

	For the OpenVPN server you will need:
	./pki/crl.pem
	./pki/private/SERVERNAME.key
	./pki/private/ta.key
	./pki/issued/SERVERNAME.crt
	./pki/dh.pem
	./pki/ca.crt

	For its client you’ll need:
	./pki/ca.crt
	./pki/private/ta.key
	./pki/private/CLIENTNAME.key
	./pki/issued/CLIENTNAME.crt

	EOF
	iforgot-vpn-nb
}

iforgot-vpn-nb() {
	cat <<-EOF
	NB  TUN is a L2 device and TAP is L3. They are incompatible,
	and the device setting must match on server and client.
	In the config use just "tun" or "tap", to make openvpn
	dynamically create a device.

	And finally, to let us into the other network…
	    iptables -A INPUT -i tun+ -j ACCEPT
	    iptables -A FORWARD -i tun+ -j ACCEPT
	    see also SNAT/MASQUERADE above
	EOF
}

iforgot-ssh-rsh-copy-dir-with-tar() {
	cat <<-EOF
	rsh kumquat mkdir /work/bkup/jane
	tar cf - . | rsh kumquat 'cd /work/bkup/jane && tar xBf -'
	EOF
}

iforgot-tar() {
	cat <<-"EOF"
	Create an archive
	    tar -a -c -v -p -f archive.tar.xz /some/directory
	          \  \  \  \  \
	           \  \  \  \  \_ file name
	            \  \  \  \_ preserve attributes
	             \  \  \_ verbose output
	              \  \_ create (or compress)
	               \_ automaticallly detect the compressor from the extension

	Decompress
	    tar -a -x [-v] -f archive.tar.xz -C /cd/here/before/extraction
	            \
	             \_ eXtract

	List
	    tar -t -a -f archive.tar.xz  "look me up"
	          \
	           \_ list files
	EOF
}

iforgot-ssh-close-hanging-session() {
	cat <<-EOF
	~.

	~ is the default escape character (can be altered with -e <escape_char>).
	Escape character + dot closes the hanging session.
	EOF
}

iforgot-seconds-to-hms() {
	cat <<-EOF
	date -d@36 -u +%H:%M:%S
	00:00:36

	secs=100000
	printf '%dd:%02dh:%02dm:%02ds\n' $((secs/86400)) $(($secs/3600)) $(($secs%3600/60)) $(($secs%60))
	EOF
	# From http://stackoverflow.com/a/28451379/685107
}

iforgot-find-broken-links() {
	cat <<-EOF
	find -xtype l rm {} \+
	EOF
}

iforgot-xdg-dirs() {
	cat <<-EOF
	Show:
	xdg-user-dir DESKTOP
	Set:
	grep ^[^#] ~/.config/user-dirs.dirs
	EOF
}

iforgot-framebuffer-with-utf8() {
	echo jfbterm
}

iforgot-bash-output-in-lines() {
	cat <<-EOF
	fmt — reformat lines to width.
	fold – simple version of the above.
	column – autoformat columns.
	colrm — remove columns.
	paste – merge lines from "file1" "file_2" or <(some) <(commands)
	pr – should be a columnizer and indenter, but broken.
	EOF
}

iforgot-nginx-generate-a-hashed-password() { echo -e '\topenssl passwd -apr1'; }

iforgot-bash-fast-replace() {
	cat <<-"EOF"
	!!:gs/pattern/replacement/
	EOF
}

iforgot-wifi-check-link() {
	cat <<-EOF
	iw dev wlan0 link
	EOF
}

iforgot-git-merge-resolve-conflicts() {
	cat <<-"EOF"
	git reset --hard
	git rebase --skip
	After resolving conflicts, merge with
	git add $conflicting_file
	git rebase --continue
	EOF
}

iforgot-deleted-files-that-hold-space() {
	cat <<-"EOF"
	A deleted file continues to hold space, while there is a process,
	  that still uses it.
	To find such files and processes that use them:

	  - try to show the files, that have <1 links to the filesystem:
	    $ lsof +L1

	  - eeeeeh…
	    $ lsof -nP +L1 /tmp

	  - on a specific filesystem
	    $ lsof +aL1 /var/log/

	There may also be real files that hold space up
	  - find directories with the largest number of files
	    $ find /home -xdev -printf '%h\n' | sort | uniq -c | sort -k 1 -n
	It is usually thumbnails, gvfs-metadata and broken mail, which I prefer
	to clean before I log in, see ~/.preload.sh.

	EOF
}

iforgot-ssh-pass-a-command() {
	cat <<-"EOF"
	Use
	    $ ssh myhost <<<"ls foo; cd bar"
	or heredoc
	    $ ssh myhost <<EOF
	    ls foo
	    cd bar
	    EOF
	since
	$ ssh myhost "ls foo; cd bar"
	won’t work as expected as well as
	$ ssh myhost /bin/bash -c 'ls foo; cd bar'
	leaving the only way to pass multiple commands by using herestring or heredoc.

	Remember to use "EOF" to prevent early expansion, and <<-EOF to strip tabs, if necessary.
	EOF
}

iforgot-ssh-nohup-fork-to-background() {
	cat <<-"EOF"
	If
	$ ssh myhost <<<"cd bar; (nohup ./a_daemon.sh) &"
	. . . .
	hangs, and -f (fork to background) doesn’t work because stdin is not
	a terminal, specify stdin and stdout for nohup:
	$ ssh myhost <<<"cd bar; (nohup ./a_daemon.sh </dev/null &>/dev/null) &"
	$
	EOF
}

iforgot-wget() {
	cat <<-EOF
	-S
	--server-response
	Print the headers sent by HTTP servers and responses sent by FTP servers.

	-nc
	--no-clobber
	If a file is downloaded more than once in the same directory, Wget's behavior depends on a few
	options, including -nc.  In certain cases, the local file will be clobbered, or overwritten,
	upon repeated download.  In other cases it will be preserved.

	When running Wget without -N, -nc, -r, or -p, downloading the same file in the same directory
	will result in the original copy of file being preserved and the second copy being named
	file.1.  If that file is downloaded yet again, the third copy will be named file.2, and so on.
	(This is also the behavior with -nd, even if -r or -p are in effect.)  When -nc is specified,
	this behavior is suppressed, and Wget will refuse to download newer copies of file.  Therefore,
	""no-clobber"" is actually a misnomer in this mode---it's not clobbering that's prevented (as
	the numeric suffixes were already preventing clobbering), but rather the multiple version
	saving that's prevented.

	When running Wget with -r or -p, but without -N, -nd, or -nc, re-downloading a file will result
	in the new copy simply overwriting the old.  Adding -nc will prevent this behavior, instead
	causing the original version to be preserved and any newer copies on the server to be ignored.

	When running Wget with -N, with or without -r or -p, the decision as to whether or not to
	download a newer copy of a file depends on the local and remote timestamp and size of the file.
	-nc may not be specified at the same time as -N.
	-t number
	--tries=number
	Set number of tries to number. Specify 0 or inf for infinite retrying.  The default is to retry
	20 times, with the exception of fatal errors like "connection refused" or "not found" (404),
	which are not retried.
	--save-headers
	Save the headers sent by the HTTP server to the file, preceding the actual contents, with an
	empty line as the separator.
	--post-data=string
	--post-file=file
	Use POST as the method for all HTTP requests and send the specified data in the request body.
	--post-data sends string as data, whereas --post-file sends the contents of file.  Other than
	that, they work in exactly the same way. In particular, they both expect content of the form
	"key1=value1&key2=value2", with percent-encoding for special characters; the only difference is
	that one expects its content as a command-line parameter and the other accepts its content from
	a file. In particular, --post-file is not for transmitting files as form attachments: those
	must appear as "key=value" data (with appropriate percent-coding) just like everything else.
	Wget does not currently support "multipart/form-data" for transmitting POST data; only
	"application/x-www-form-urlencoded". Only one of --post-data and --post-file should be
	specified.

	Please note that wget does not require the content to be of the form "key1=value1&key2=value2",
	and neither does it test for it. Wget will simply transmit whatever data is provided to it.
	Most servers however expect the POST data to be in the above format when processing HTML Forms.

	Please be aware that Wget needs to know the size of the POST data in advance.  Therefore the
	argument to "--post-file" must be a regular file; specifying a FIFO or something like
	/dev/stdin won't work.  It's not quite clear how to work around this limitation inherent in
	HTTP/1.0.  Although HTTP/1.1 introduces chunked transfer that doesn't require knowing the
	request length in advance, a client can't use chunked unless it knows it's talking to an
	HTTP/1.1 server.  And it can't know that until it receives a response, which in turn requires
	the request to have been completed -- a chicken-and-egg problem.

	Note: As of version 1.15 if Wget is redirected after the POST request is completed, its
	behaviour will depend on the response code returned by the server.  In case of a 301 Moved
	Permanently, 302 Moved Temporarily or 307 Temporary Redirect, Wget will, in accordance with
	RFC2616, continue to send a POST request.  In case a server wants the client to change the
	Request method upon redirection, it should send a 303 See Other response code.

	This example shows how to log in to a server using POST and then proceed to download the
	desired pages, presumably only accessible to authorized users:

	# Log in to the server.  This can be done only once.
	wget --save-cookies cookies.txt \
	--post-data 'user=foo&password=bar' \
	http://server.com/auth.php

	# Now grab the page or pages we care about.
	wget --load-cookies cookies.txt \
	-p http://server.com/interesting/article.php

	If the server is using session cookies to track user authentication, the above will not work
	because --save-cookies will not save them (and neither will browsers) and the cookies.txt file
	will be empty.  In that case use --keep-session-cookies along with --save-cookies to force
	saving of session cookies.
	--method=HTTP-Method
	For the purpose of RESTful scripting, Wget allows sending of other HTTP Methods without the
	need to explicitly set them using --header=Header-Line.  Wget will use whatever string is
	passed to it after --method as the HTTP Method to the server.

	-c
	--continue
	Continue getting a partially-downloaded file.  This is useful when you want to finish up a
	download started by a previous instance of Wget, or by another program.  For instance:

	wget -c ftp://sunsite.doc.ic.ac.uk/ls-lR.Z

	If there is a file named ls-lR.Z in the current directory, Wget will assume that it is the
	first portion of the remote file, and will ask the server to continue the retrieval from an
	offset equal to the length of the local file.

	Note that you don't need to specify this option if you just want the current invocation of Wget
	to retry downloading a file should the connection be lost midway through.  This is the default
	behavior.  -c only affects resumption of downloads started prior to this invocation of Wget,
	and whose local files are still sitting around.

	Without -c, the previous example would just download the remote file to ls-lR.Z.1, leaving the
	truncated ls-lR.Z file alone.

	-w seconds
	--wait=seconds
	Wait the specified number of seconds between the retrievals.  Use of this option is
	recommended, as it lightens the server load by making the requests less frequent.  Instead of
	in seconds, the time can be specified in minutes using the "m" suffix, in hours using "h"
	suffix, or in days using "d" suffix.

	Specifying a large value for this option is useful if the network or the destination host is
	down, so that Wget can wait long enough to reasonably expect the network error to be fixed
	before the retry.  The waiting interval specified by this function is influenced by
	"--random-wait", which see.

	--waitretry=seconds
	If you don't want Wget to wait between every retrieval, but only between retries of failed
	downloads, you can use this option.  Wget will use linear backoff, waiting 1 second after the
	first failure on a given file, then waiting 2 seconds after the second failure on that file, up
	to the maximum number of seconds you specify.

	By default, Wget will assume a value of 10 seconds.

	--random-wait
	Some web sites may perform log analysis to identify retrieval programs such as Wget by looking
	for statistically significant similarities in the time between requests. This option causes the
	time between requests to vary between 0.5 and 1.5 * wait seconds, where wait was specified
	using the --wait option, in order to mask Wget's presence from such analysis.

	A 2001 article in a publication devoted to development on a popular consumer platform provided
	code to perform this analysis on the fly.  Its author suggested blocking at the class C address
	level to ensure automated retrieval programs were blocked despite changing DHCP-supplied
	addresses.

	The --random-wait option was inspired by this ill-advised recommendation to block many
	unrelated users from a web site due to the actions of one.
	--user=user
	--password=password
	Specify the username user and password password for both FTP and HTTP file retrieval.  These
	parameters can be overridden using the --ftp-user and --ftp-password options for FTP
	connections and the --http-user and --http-password options for HTTP connections.
	-nH
	--no-host-directories
	Disable generation of host-prefixed directories.  By default, invoking Wget with -r
	http://fly.srk.fer.hr/ will create a structure of directories beginning with fly.srk.fer.hr/.
	This option disables such behavior.
	Recursive Retrieval Options
	-r
	--recursive
	Turn on recursive retrieving.    The default maximum depth is 5.
	-l depth
	--level=depth
	Specify recursion maximum depth level depth.
	--cut-dirs=number
	No options        -> ftp.xemacs.org/pub/xemacs/
	-nH               -> pub/xemacs/
	-nH --cut-dirs=1  -> xemacs/
	-nH --cut-dirs=2  -> .

	--cut-dirs=1      -> ftp.xemacs.org/xemacs/
	...

	-k
	--convert-links
	After the download is complete, convert the links in the document to make them suitable for
	local viewing.  This affects not only the visible hyperlinks, but any part of the document that
	links to external content, such as embedded images, links to style sheets, hyperlinks to non-
	HTML content, etc.

	Each link will be changed in one of the two ways:

	·   The links to files that have been downloaded by Wget will be changed to refer to the file
	they point to as a relative link.

	Example: if the downloaded file /foo/doc.html links to /bar/img.gif, also downloaded, then
	the link in doc.html will be modified to point to ../bar/img.gif.  This kind of
	transformation works reliably for arbitrary combinations of directories.

	·   The links to files that have not been downloaded by Wget will be changed to include host
	name and absolute path of the location they point to.

	Example: if the downloaded file /foo/doc.html links to /bar/img.gif (or to ../bar/img.gif),
	then the link in doc.html will be modified to point to http://hostname/bar/img.gif.

	Because of this, local browsing works reliably: if a linked file was downloaded, the link will
	refer to its local name; if it was not downloaded, the link will refer to its full Internet
	address rather than presenting a broken link.  The fact that the former links are converted to
	relative links ensures that you can move the downloaded hierarchy to another directory.

	Note that only at the end of the download can Wget know which links have been downloaded.
	Because of that, the work done by -k will be performed at the end of all the downloads.
	-m
	--mirror
	Turn on options suitable for mirroring.  This option turns on recursion and time-stamping, sets
	infinite recursion depth and keeps FTP directory listings.  It is currently equivalent to -r -N
	-l inf --no-remove-listing.

	EOF
}

iforgot-ntp () {
	cat <<-EOF
	Check a specific server:
	    # ntpdate -q 10.10.10.10
	Offset must be <1 sec

	Print currently used servers
	    # ntpq -p
	remote: peers speficified in the ntp.conf file
	* = current time source
	# = source selected, distance exceeds maximum value
	o = source selected, Pulse Per Second (PPS) used
	+ = source selected, included in final set
	x = source false ticker
	. = source selected from end of candidate list
	– = source discarded by cluster algorithm
	blank = source discarded high stratum, failed sanity

	refid: remote source’s synchronization source

	stratum: stratum level of the source

	t: types available
	l = local (such as a GPS, WWVB)
	u = unicast (most common)
	m = multicast
	b = broadcast
	– = netaddr

	when: number of seconds passed since last response

	poll: polling interval, in seconds, for source

	reach: indicates success/failure to reach source, 377 all attempts successful

	delay: indicates the roundtrip time, in milliseconds, to receive a reply

	offset: indicates the time difference, in milliseconds, between the client server and source

	disp/jitter: indicates the difference, in milliseconds, between two samples
	EOF
	# From http://tech.kulish.com/2007/10/30/ntp-ntpq-output-explained/
}

iforgot-xrandr-external-display() {
	cat <<-EOF
	If LVDS1 is the laptop display with resolution of 1366x768 and VGA1 is external 1080p.
	NB the order of options
	$ xrandr --output VGA1 --mode 1920x1080 --primary --same-as LVDS1 \
	--output LVDS1 --mode 1366x768 --fb 1920x1080 --panning 1920x1080
	EOF
}

iforgot-imgur-dl-album() {
	cat <<-EOF
	Add /zip to the URL.
	EOF
}


iforgot-logrotate() {
	cat <<-"EOF"
	Check logrotate scripts
	    $ logrotate -d

	Force logrotate on a specific file
	    $ logrotate -dvf /etc/logrotate.d/file

	Logrotate has a status file, where it writes every file’s state.
	  It is a potential source of weird error messages, if some wrong
	  files got there, i.e. messages-20001122.xz-20001122.xz.
	Find the file with
	    $ man -P "less -p 'logrotate\.status'" logrotate


	minsize    rotates only when the file has reached an appropriate size and the set time
	           period has passed.
	maxsize    will rotate when the log reaches a set size or the appropriate time
	           has passed.
	size       will rotate when the log > size.
	           Regardless of whether hourly/daily/weekly/monthly is specified.

	Default config
	weekly
	rotate 7
	create
	dateext
	compress
	maxsize ????M
	compresscmd /usr/bin/xz
	compressoptions "-9 --threads=0 --quiet --memlimit=1250MiB"
	compressext .xz
	uncompresscmd /usr/bin/unxz
	notifempty
	nomail
	noolddir
	include /etc/logrotate.d

	Example nginx log config
	/var/log/nginx/*_log {
		hourly
		maxsize 100M
		rotate 10
		missingok
		sharedscripts
		postrotate
		nginx -s reopen
		endscript
	}

	Use ‘copytruncate’ for generic logs like messages/dmesg/syslog!

	/var/lib/logrotate.status   ← what and when was rotated

	The difference between
	EOF
}

iforgot-git-commit-ranges() { iforgot-git-ref-names; }
iforgot-git-ref-names() {
	cat <<-EOF
	<sha1>, e.g. dae86e1950b1277e545cee180551750029cfe735, dae86e
	<describeOutput>, e.g. v1.7.4.2-679-g3bee7fb
	<refname>, e.g. master, heads/master, refs/heads/master
	@ alone is a shortcut for HEAD
	<refname>@{<date>}, e.g. master@{yesterday}, HEAD@{5 minutes ago}
	<refname>@{<n>}, e.g. master@{1} an ordinal specification enclosed in a brace pair (e.g.  {1}, {15}) specifies the n-th prior value of that ref.
	@{<n>}, e.g. @{1}
	You can use the @ construct with an empty ref part to get at a reflog
	entry of the current branch. For example, if you are on branch blabla
	then @{1} means the same as blabla@{1}.
	@{-<n>}, e.g. @{-1}
	The construct @{-<n>} means the <n>th branch/commit checked out before
	the current one.
	<rev>^, e.g. HEAD^, v1.5.1^0
	A suffix ^ to a revision parameter means the first parent of that
	commit object.  ^<n> means the <n>th parent (i.e.  <rev>^ is
	equivalent to <rev>^1). As a special rule, <rev>^0 means the commit
	itself and is used when <rev> is the object name of a tag object that
	refers to a commit object.
	<rev>~<n>, e.g. master~3
	A suffix ~<n> to a revision parameter means the commit object that is
	the <n>th generation ancestor of the named commit object, following
	only the first parents. I.e.  <rev>~3 is equivalent to <rev>^^^ which
	is equivalent to <rev>^1^1^1. See below for an illustration of the
	usage of this form.
	<rev>^{/<text>}, e.g. HEAD^{/fix nasty bug}
	A suffix ^ to a revision parameter, followed by a brace pair that
	contains a text led by a slash, is the same as the :/fix nasty bug
	syntax below except that it returns the youngest matching commit which
	is reachable from the <rev> before ^.

	:/<text>, e.g. :/fix nasty bug
	A colon, followed by a slash, followed by a text, names a commit whose
	commit message matches the specified regular expression. This name
	returns the youngest matching commit which is reachable from any ref.
	If the commit message starts with a !  you have to repeat that; the
	special sequence :/!, followed by something else than !, is reserved
	for now.
	EOF
}

iforgot-send-mail() {
	cat <<-EOF
	sendmail -f from@me.org -t you@suck.org
	Subject: EHLO
	OHAYOU!
	EOF
}

iforgot-firefox-basic-auth() {
	cat <<-EOF
	You will probably also want to open File → New private window
	http://user:pass@example.com
	EOF
	# From http://superuser.com/a/458577/191754
}

iforgot-screen() {
	cat <<-"EOF"
	screen -ls                      – list sessions.
	screen -r 12345.pts-6.hostname  — attach to a particular session.
	EOF
}


iforgot-remote-desktop-with-x11vnc() {
	cat <<-EOF
	Package names:
	    x11vnc — server for X11
	    tightvnc — probably a better implementation of a server

	On the remote host:
	1. Create hashed password
	    x11vnc -storepasswd YourPasswordHere /tmp/vncpass
	2. Start VNC server, it must write PORT=XXXX in the output.
	    x11vnc -display :0 -auth /tmp/kde-kdm/xauth-106-_0 -noxdamage -forever -rfbauth /tmp/vncpass
	             \           \                               \          \        \ 
	              \           \                               \          \        \_ password
	               \           \                               \          \_ don’t quit after client disconnects
	                \           \                               \_ remove glitches
	                 \           \_ auth file is necessary for xdm/gdm/kdm
	                  \_ :0 is the default and may be omitted

	  Also for cross-platform connections:
		-xkb -nomodtweak to solve Shift/layout bugs.

	On the local host:
	    remmina
	or poorer choice,
	    vncviewer remote-hostname:XXXX

	Starting with ssh:
	    ssh -t -L 5900:localhost:5900 far-host 'x11vnc -localhost -display :0'

	Interesting options
	    -shared
	    -forever
	EOF
}

iforgot-openssl-key-remove-password() {
	cat <<-EOF
	mv a.key a.key.env
	openssl rsa  <a.key.enc  >a.key
	EOF
}

iforgot-sublime-log-commands() {
	cat <<-EOF
	sublime.log_commands(True)
	EOF
}

iforgot-ffmpeg-encoding-opts() {
	cat <<-"EOF"
	INRES="1145x975"    # input resolution
	OUTRES="1920x1080"    # output resolution
	FPS="15"    # target FPS
	GOP="30"    # i-frame interval, should be double of FPS,
	GOPMIN="15"    # min i-frame interval, should be equal to fps,
	THREADS="4"    # max 6
	CBR="1000k"    # constant bitrate (should be between 1000k - 3000k)
	QUALITY="ultrafast"    # one of the many FFMPEG preset
	AUDIO_RATE="44100"

	ffmpeg -hide_banner
	       -y
	       -threads $THREADS
	Input
	       -i "$audio_track"
	       -loop 1
	       -i "$(crop_if_needed "$image")"

	       -framerate 60   # NB not -r
	       -f x11grab
	       -s "$INRES"
	       -i :0.0+528,83

	       -f alsa
	       -i pulse
	       -f flv
	       -ac 2
	       -ar $AUDIO_RATE
	Mapping streams
	       -map 0:1 -map 0:2 -map 1:3
	            ^ ^
	            ^ ^---- stream number in input file 0
	            ^---- input file number
	        All -map directives specify which INPUT stream from which INPUT
	        file should be taken (and converted, if needed).
	        Shortcuts: 0:a,
	                   0:v,
	                   0:s.
	        Docs: https://trac.ffmpeg.org/wiki/Map
	Enc. Video
	       -c:v libx264
	       -pix_fmt yuv420p
	       -b:v 0 -crf 18

	       -g $((FPS*2))
	       -keyint_min $FPS
	       -b:v $CBR
	       -minrate $CBR
	       -maxrate $CBR
	Enc. Audio
	       -c:a aac -b:a 320k
	       -na

	Output
	       -tune stillimage
	       -strict experimental
	       -shortest
	       -movflags +faststart            Optimises mp4 for browsers, so
	                                         they could start playing ASAP.
	                                         Moves some chunk, that is usually
	                                         placed at the end of the file,
	                                         to the head.
	                                       Useless for streams.
	       -profile:v $QUALITY
	       -level 4.2                      Best settings for High profile,
	                                       that can be used.
	       -tune film                      Als o best settings on err…
	       -s $OUTRES
	       -thread_queue_size 16
	       -bufsize $CBR

	       -vf "scale=-1:1080,pad=1920:ih:(ow-iw)/2"
	Dest
	       out.mp4
		   "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"

	Constant Rate Factor:
	<<lower is better

             ┌default=23
             │
	0     17 │  28        51    63
	└─────┴──┴──┴─────────┴┄┄┄┄┄┘
	       \     \         \     \_ if libx264 compiled with 10bit
	        \     \         \_ if libs264 compiled as 8bit
	         sane range

	Most video players are crap and supportonly chroma sampling of 4:2:0
	  achieved with -pix_fmt yuv420p.

	Based on quality produced from high to low:
	    libopus > libvorbis >= libfdk_aac > aac > libmp3lame >= eac3/ac3 > libtwolame > vorbis > mp2 > wmav2/wmav1

	Shorter: libopus > libvorbis > aac > libmp3lame >= ac3

	Video encoding example (audio, no subs):
	$ ffmpeg -y -ss 0:17:46.107 -to 0:17:49.318 \
	            -i /home/video/anime/Slow\ start/\[HorribleSubs\]\ Slow\ Start\ -\ 07\ \[1080p\].mkv \
	            \
	            -c:v libx264 -b:v 0 -crf 18 -profile high -level 4.2 -tune film \
	            -c:a aac -b:a 192k \
	            /home/picts/animu/screens/slow\ start/\[HorribleSubs\]\ Slow\ Start\ -\ 07\ \[1080p\]\ 0.17.46–0.17.49.mp4
	EOF
}

iforgot-sshfs() {
	cat <<-EOF
	sshfs user@host:/some/dir /local/dir
	fusermount -u /local/dir
	EOF
}

iforgot-bonding() {
	cat <<-EOF
	cat /sys/class/net/bond0/bonding/mode

	cat /proc/net/bonding/bond0  - To get true MAC addresses of slave inter-
	                               faces without destroying the bond.
	EOF
}

iforgot-ip() {
	cat <<-EOF
	ip neigh [IPv4 address] – show ARP table or entry for a particular address
	ip maddr – add|del|sh <Multicast address> [dev <iface>] – adds a multicast
	           address for listening, or removes it.  Doesn’t subscribe to mul-
	           ticast for IGMP.
	EOF
}

iforgot-lowriter-toc-wont-stick-to-top() {
	cat <<-EOF
	EOF
}


iforgot-lowriter-settings() {
	cat <<-EOF
	# Tools → Options

	→ View
	  Enable Use GL rendireing always.
	  Enable Force GL use.

	→ LO Writer → View:
	  Enable Smooth scrolling, without smooth scrolling lowriter is hell.

	→ LO Writer → AutoCaption
	  Check ‘LibreOffice Writer Image’.
	  Enter ‘Pic.’ to the Category field.
	  Caption order = Category first.
	  Check new style ‘Pic.’ under Captions (use hierarhy view, it’s good!).

	→ LO Writer → Compatibility
	  Uncheck:
	      Use printer metrics…
	      Add spacing between paragraphs and tables (messes!)
	      Add paragraph and table spacing at tops of pages (messes! Adds
	        vertical space for headers that should stick to the top!)
	      Openoffice 1.1…
	      Do not add leading space… (uncheck so it would add it – it’s
	        space between lines, so upper and lower elements would not cross)
	      Protect form
	  Check:
	      Add paragraph and table spaces at bottom of table cells (? is that
	        really helpful or messes? I don’t remember)
	      Consider wrapping style when positioning objects.
	      Expand word space on lines… in justified paragraphs.
	EOF
}

iforgot-lowriter-how-not-to-do() {
	cat <<-EOF
	When the table of contents doesn’t stick to the top, because
	  the cursor stays at the top, like it requires a paragraph there,
	  and it cannot be deleted neither with Delete nor with Backspace,
	  Switch the ToC from read-only to editable, then remove the empty line
	  and ToC should stick to the top now. If it doesn’t, look at the
	  ToC title style, edit ToC → styles.

	Outline _numbering_ elements can’t have two different styles
	  at the same outline level. Actually, ToC itself supports
	  building levels from outline, indexes and custom-selected styles,
	  but the numbering in this case is risky. Especially in documents
	  with a heavy structure, 4–5 subsection levels and bulleted lists.
	  Because when different styles meet at some 4th level, automatic
	  numbering doesn’t work, and numbering resets. Continuing previous
	  list will continue the bulleted list, if it happens to be right before
	  the header with non-regular style.

	Attempt to apply different styles to same outline levels is destined
	  to fail. I have tried to print unready sections and subsections
	  as grey in ToC, and for that I had to reject the common Outline,
	  and make my own numbering style and calling it ‘My ToC’. Then I
	  assigned existing header styles this new numbering style and made
	  new counterparts for the header styles, ‘inactive’ versions of the
	  existing headers. They were differing only by name, and inactive
	  versions of the styles were only to assign them outline levels
	  from 6 to 10, in order to make them look in ToC identically
	  to the first five levels, except for the font colour being grey,
	  to show their unreadiness. But there were three problems:
	  1. The one this text started with. Numbering was hard to maintain,
	     sometimes I had to remove bulleted lists to restore the numbering,
	     then put them again. I already knew maintaining this would be hell.
	  2. Since the numbering was united, it was impossible to make a style
	     with outline level 6 to look like ‘1’ and not ‘1.1.1.1.1.1’.
	     Thus, the idea was already proven unsustainable.
	  3. ToC didn’t want to apply custom greyed ToC style (ToC had three
	     styles, for the title, default ToC line for outline levels 1–5
	     and greyed line for outline levels from 6 to 10). Evaluating was
	     enabled up to level 10. Though when I only started with a single
	     style to test, it worked.
	EOF
}


iforgot-dhcp-procedure() {
	cat <<-"EOF"

	Client uses UDP 68  —  Server uses UDP 67
	# Listen all DHCP traffic on a given port
	tcpdump -i br_lan -nev udp src port 67 or udp src port 68

	# Find rouge DHCP packets from machines,
	#   that act like a DHCP server, i.e. send DHCP responses
	#   MAC address here -------------------------------------⋅
	#   is the true DHCP server.                              v
	tcpdump -i br_lan -nev udp src port 67 and not ether host a8:39:44:96:fa:b8

	# Capture 100 packets and put rouge ones in /tmp/rouge.
	tcpdump -i br_lan -nev udp src port 67 and not ether host a8:39:44:96:fa:b8 -U -c 100 >>/tmp/rogue 2>&1 &
	EOF
	# http://superuser.com/a/750586/191754
}

iforgot-ssh-tunnel() {
	cat <<-EOF
	При наличии на сервере соответствющего разрешения ("PermitTunnel yes" в sshd_config) ssh позволяет делать VPN-соединение между виртуальным устройством на клиенте и на сервере.
	Как правило, на клиенте мы запускаем команду ssh не от рута, однако обычный пользователь не имеет права создавать виртуальные интерфейсы. Поэтому первым делом создадим виртуальный интерфейс tap17 для нашего текущего пользователя:
	$ sudo tunctl -u $(id -u -n) -t tap17
	Если на сервер по ssh мы идем не под рутом, то ту же самую операцию нужно проделать на сервере для того пользователя, под которым будет выполняться логин.
	Далее достаточно запустить ssh с указанием опций для построения туннеля:
	ssh -o Tunnel=ethernet -w 17:17 mylogin@myserver
	Теперь у нас на клиенте и на сервере есть устройства tap17, которые соединены друг с другом по VPN, как будто это физические интерфейсы, соединенные проводом по ethernet. Можно настраивать их с помощью ifconfig, добавлять в bridge, настраивать NAT и т.д. и т.п.
	EOF
}
#
#  If you want more, I find these sites helpful:
#
# https://www.pantz.org

iforgot-bash-check-file-size-while-process-running() {
	cat <<-"EOF"
	while [ -d /proc/34536 ]; do echo -en "\r\e[K`ls -sh /virt/lxc/CTs/portalcms.tar`" ; sleep 10; done

	(In certain cases you may use `pv` instead)
	EOF
}

iforgot-ctrl-key-in-the-term() {
	echo 'In a standard terminal, ctrl is defined to send the ASCII code of the key you press minus 64 (this is why ctrl-J (74) sends newline (10) and ctrl-I (73) sends tab (9), for example).'
}

iforgot-nginx-who-serves-this-domain() {
	cat <<-EOF
	When you suspect, that the requests are served by some other server.

	# tail -fn0 /var/log/nginx/*log | grep -F 'MY_IP_ADDRESS' -C1
	$ wget -O- --no-check-certificate  https://problem.domain.com
	EOF
}

iforgot-ftp-from-commandline() {
	echo lftp
}

iforgot-ssl-check-pem-cert() {
	cat <<-"EOF"
	echo | openssl s_client -showcerts -servername sealion.club -connect sealion.club:443 2>/dev/null | openssl x509 -inform pem -noout -text
	EOF
}

iforgot-nvidia-settings() {
	cat <<-"EOF"
	nvidia-settings -q fsaa --verbose
	nvidia-settings -q loganiso --verbose
	firefox file:///usr/share/doc/nvidia-drivers-367.27/html/openglenvvariables.html
	EOF
}

iforgot-pixz() {
	echo 'tar Oc .wine-for-indesign  |  pixz  -9 >.wine-for-indesign.tar.xz'
}

iforgot-indesign-table-caption() {
	cat <<-EOF
	1. Place a text frame.
	2. Put a caption of the ‘table caption’ style there.
	   It should already have ‘Table N’ in front.
	3. Apply ‘Table caption’ _object_ style.
	4. Object style should have anchored the text frame to the last line,
	   and thanks to the setting in the object style, namely
	   Anchored object options → Position (Inline or above)
	       Position = Above line
	           Alignment = Away from Spine
	           Space before = 0 cm (increasing will add space BEFORE the line we anchor to,
	                                making both that line and he frame with table caption
	                                separated from the previous text)
	           Space after = -1.3 cm (base paragraph has 14 pt, caption 12 pt)
	EOF
}

iforgot-hugo() {
	cat <<-"EOF"
	alias hugo-future="hugo --cleanDestinationDir \
	                        --ignoreCache \
		                    --buildDrafts -buildFuture --buildExpired \
		                    -s ~/repos/goen \
		                    -c ~/repos/goen/content \
		                    -d ~/repos/goen/future \
		                    && hugo server -ws ~/repos/goen -d ~/repos/goen/future"
	alias hugo-public="hugo --cleanDestinationDir \
		                    --ignoreCache \
		                    -s ~/repos/goen \
		                    -c ~/repos/goen/content \
		                    -d ~/repos/goen/public"

	Files:
	/layouts/                     Here are all HTML templates
	         _index.html          Main page
	         _default/
	                  baseof.html
	                  categories.html
	                  list.html
	                  single.html
	/content/
	         _index.html          Used for its Front Matter

	Test 404 page like that:
	http://localhost:1313/404.html

	Date format is peculiar and works under the following rule:
	//    Jan 2 15:04:05 2006 MST
	//      | |  |  |  |    |   |
	//      1 2  3  4  5    6  -7
	//
	// Format strings absolutely must adhere to the 1-2-3-4-5-6-7 order:
	//
	// Month must be Jan, January, 01, or 1
	// Date must be 02 or 2
	// Hour must be 03, 3, or 15
	// Minute must 04
	// Second must be 05
	// Year must be 2006
	// Timezone must be MST or -7

	EOF
}

iforgot-sublime-maxpane() {
	echo -e '\tC-S-t'
}

iforgot-sublime-autoload() {
	cat <<-"EOF"
	/home/dtr/.config/sublime-text-3/Packages/Max_pane_autoload/Max_pane_autoload.py
	http://sublimetexttips.com/execute-a-command-every-time-sublime-launches/
	EOF
}

iforgot-netstat() {
	cat <<-"EOF"
	netstat -l    Show only listening sockets. (These are omitted by default.)
	        -a    Show both listening and non-listening sockets.

	        -p    Show the PID and name of the program to which each socket belongs.
	        -c    Update info every second
	        -r    Same as ‘route -n’, useful when ‘route’ is not present.
	        -g    Show multicast groups that the host is subscribed to.
	        -M    Display msqueraded connections

	EOF
}

iforgot-dig() {
	cat <<-"EOF"
	dig  [A]  example.com  @dns-server.com
	      \
	       \_Record type: A, MX…

	dig MX google.co.uk @ns1.google.com
	    ;; ANSWER SECTION:
	    google.co.uk.  10800  IN  MX  10
	          \          \     \   \   \
	           \          \     \   \   \_ Priority
	            \          \     \   \_Record type
	             \          \     \_Record class: IN(ternet) or CH(aos)
	              \          \_TTL
	               \_Domain name in question

	EOF
	# Source: http://droptips.com/using-dig-to-query-a-specific-dns-server-name-server-directly-linux-bsd-osx
}

iforgot-rename() {
	cat <<-"EOF"
	perl-rename

	-n  dry run
	-v  verbose

	It works like mv + sed.
	That means pattern you parse and the resulting name will have exactly
	  the same type of path (may be absolute!).

	./Иванов, ген.-м., нач. штаба 6-й Армии Киев.-го. особ. воен. округа (Ю.-З. фронта)/17 tild3665-3930-4161-b137-646365326663__3_6__011219410_1517861244130_1.jpg
	    ->
	./Иванов, ген.-м., нач. штаба 6-й Армии Киев.-го. особ. воен. округа (Ю.-З. фронта)/Иванов - 17.jpg
	find . -type f -print0 | xargs -0 -I{} \
	                         perl-rename -vn 's/\.\/(\S+)(,.*[^\/])\/([0-9]+)\s.*(\.[jJ][pP][eE]?[gG])$/.\/$1$2\/$1 - $3$4/' {}

	EOF
}

 # Checks if passed certificate matches passed private key
#  $1 – certificate
#  $2 – private key
#
iforgot-ssl-check-if-cert-and-pk-match() {
	[ ! -r "$1" -o ! -r "$2" ] && {
		echo "Check that certificate matches private key"
		echo "${FUNCNAME[0]} <certificate> <private_key>"
		return
	}
	CERT_NAME="$1"
	PRIV_NAME="$2"

	# Create the Server Key, CSR, and Certificate
	echo "*** Generating Server Key, CSR, and Certificate with password"
	CERT_MODULUS=$(openssl x509 -noout -text -in ${CERT_NAME} -modulus | grep "Modulus=")
	PRIV_MODULUS=$(openssl rsa -noout -text -in ${PRIV_NAME} -modulus | grep "Modulus=")

	#echo ${CERT_MODULUS}
	#echo ${PRIV_MODULUS}
	[ ${CERT_MODULUS} = ${PRIV_MODULUS} ] \
		&& echo "Certificate match private key" \
		|| echo "Certificate and private key differ"
}

iforgot-gentoo-upgrade() {
	cat <<-"EOF"
	Backup firefox profile
	$ backup-firefox-profile.sh

	# cp -a /var/lib/portage/world /mnt/chroot//var/lib/portage/world
	# cp -ra /etc/* /mnt/chroot//etc/

	Find broken symlinks
	# find /etc/ -xtype l

	See iforgot-chroot-procedure
	Everything further is chroot

	env-update
	. /etc/profile
	emaint sync -a
	gcc-config -l
	gcc-config 2
	binutils-config -l
	binutils-config 3
	eselect profile list
	eselect profile set 4

	DO NOT update portage after this line – disable emaint cronjob!

	First compiling @toolchain
	emerge -NuDav1 @toolchain

	Second, recompiling @toolchain (glibc, binutils, gcc, linux-headers)
	  with the new @toolchain to get rid of incompatibilities during the
	  compilation and to gain maximum features. Also we build
	  binary packages here for:
	  - it will save time on merging @world with -D later;
	  - binary packages will save time in a case, if something goes wrong
	    either during the build time or after depclean.

	emerge -NuDbav1 @toolchain

	Some rush rebuilding @system instead of @toolchain, but that often fails.

	Rebuilding the world.
	emerge -NuDkav @world

	Rebuilding the perl packages and the packages linked against libperl.
	perl-update --all
	(if something goes wrong, --reallyall)

	IN CASE YOU RUN INTO A DEPHELL
	    1) if build.log comlains about perl,
	       run perl-update --all/--reallyall;
	    2) try to add -e to emerge.

	Post-cleaning
	rm -rf /var/tmp/portage/*
	ccache -C

	emerge -av1 @preserved-rebuild

	ARE YOU NOT GOING BACK?
	Check, that every program works, you’re about to clean old binpackages.

	Every program works on its current version?
	$ sed -rn '/#  regular programs/,$ s/.*\/(\S+) .*/\1/p' /etc/portage/package.env

	If OK, then

	# eclean distfiles --package-names --deep --fetch-restricted
	eclean-dist -n -d -f

	# eclean packages --package-names --deep
	eclean-pkg -n -d

	Add -p to --pretend.

	rm -rf /var/tmp/portage/*
	EOF
}

iforgot-home-station() {
	cat <<-"EOF"
	home2 cannot boot properly when it loads in EFI mode – some services do not start properly.
	Needs a new kernel or a system update?
	EOF
}

iforgot-world-cleaning() {
	cat <<-"EOF"
	shiki-colors themes depend on gnome-colors-common package
	EOF
}

iforgot-fonts() {
	cat <<-"EOF"
	1. Build freetype without cleartype, infinality and harfbuzz.
	2. You can use in eselect fontconfig:
	   10-hinting-full.conf           (basically, any hinting or no-hinting)
	   10-scale-bitmap-fonts.conf
	   10-sub-pixel-rgb.conf          (   —»—   , any sub-pixel or no-subpixel)
	   11-lcdfilter-default.conf       (  —»—   , any lcdfilter)
	   20-unhint-small-dejavu-sans.conf
	   20-unhint-small-dejavu-sans-mono.conf
	   20-unhint-small-dejavu-serif.conf
	   20-unhint-small-vera.conf
	   30-metric-aliases.conf
	   30-urw-aliases.conf
	   33-TerminusPCFFont.conf
	   40-nonlatin.conf
	   44-wqy-zenhei.conf
	   45-latin.conf
	   49-sansserif.conf
	   50-user.conf
	   51-local.conf
	   57-dejavu-sans-mono.conf
	   60-latin.conf
	   65-fonts-persian.conf
	   65-nonlatin.conf
	   69-unifont.conf
	   80-delicious.conf
	   90-synthetic.conf
	3. In ~/.Xresources aa=1, h=1, ht=full, lf=default, rgba=yourrgb, dpi=correctdpi
	   Basically, any settings you like there.
	4. DO NOT BUILT, DO NOT ENABLE INFINALITY. BUILD WITHOUT CLEARTYPE if you want slim fonts.
	5. Nice DejaVu Sans Mono could be achieved on point size between 11 and 12, ≈11.5pt.
	6. IF YOU UPGRADE FREETYPE FIREFOX MAY HAVE MESSED UP FONTS!
	7. hinting allows to use subpixels on the display matrix, that means, that
	   the resolution ‘triples’ or at least ‘doubles’ in the way the red, green and blue
	   are laid out, usually horizontal way,

	Settings in /etc/conf.d/ seem to take preference over those in ~/.Xresources.

	Fontconfig links:
	‘2.7 chips with chitty Cleartype’
	https://www.freetype.org/freetype2/docs/subpixel-hinting.html
	(old) ‘On hinting, autohinter and stem darkening’
	https://www.freetype.org/freetype2/docs/text-rendering-general.html
	EOF
}

iforgot-bash-add-array-element-simply() {
	set -x
	unset arr
	arr=(1 2 3)
	declare -p arr
	arr[-1]=3a
	declare -p arr
	arr+=(4)
	declare -p arr
	arr+=( [77]=77 )
	declare -p arr
	set +x
	unset arr
}

iforgot-printer-doesnt-work-hp() {
	cat <<-EOF
	~/bin/hp_reload.sh
	EOF
}

iforgot-youtube-shortcuts() {
	cat <<-"EOF"
	Playback
	    ⏯		Space
	    ⏯		k		(no focus needed)
	    ⍆		,		cadre forward
	    ⍅		.		cadre back
	    ⏪		←		(5 sec)
	    ⏩		→		(5 sec)
	    ⏪⏪		j		(10 sec)
	    ⏩⏩		l		(10 sec)
	    ⏮		Home
	    ⏭		End
	    ⏵↑		>		(raise playing speed)
	    ⏴↓		<		(lower playing speed)

	Volume
	    ♬↑		↑
	    ♬↓		↓
	    ♬ₓ		m

	Playlist
	    ⏪		Ctrl + ←		(only in playlist)
	    ⏩		Ctrl + →		(only in playlist)
	    ⏪		Shift + P		previously played video
	    ⏩		Shift + N		play next video
	    						in recommendations/playlist

	Closed captions
	    On/Off	C
	    +size	+
	    −size	-

	Misc

	f – Fullscreen
	(Shift+)Tab key – Move forward in player control buttons
	Num keys 1, 2, 3… 9 – Move playhead to the respective percentage, 10%–90%
	EOF
}

iforgot-urxvt-test-font() {
	cat <<-"EOF"
	newfont="xft:Terminus:pixelsize=12,xft:Kelvinch"
	echo -e '\e]710;'${newfont}'\007'
	EOF
}

iforgot-ffprobe-help() {
	cat <<-"EOF"
	ffprobe -v error -show_format -show_streams input.mp4

	ffprobe -v error -hide_banner \
	        -show_entries format_tags \
	        -of default=noprint_wrappers=1

	ffprobe -v error -hide_banner \
	        -show_entries format=artist \
	        -of default=noprint_wrappers=1:nokey=1

	https://ffmpeg.org/ffprobe.html
	EOF
}

iforgot-gs-grab-following() {
	cat <<-"EOF"
	curl -u user:pass "https://*/api/statuses/friends.json"
	EOF
}

iforgot-gs-grab-followers() {
	cat <<-"EOF"
	curl -u user:pass "https://*/api/statuses/followers.json?count=500"

	Cap on 200 entries, use ?page=N, where N = 0, 1, 2 …
	EOF
}

iforgot-json-parser() {
	echo '	jq'
}

iforgot-hunspell-dicts() {
	cat <<-EOF
	Page: http://wordlist.aspell.net/dicts/
	README: http://wordlist.aspell.net/hunspell-readme/
	Hunspell dictionaries: https://sourceforge.net/projects/wordlist/files/speller/

	See also: ~/bin/hunspell_combine.sh
	EOF
}

iforgot-trackers-list() {
	cat <<-EOF
	udp://tracker.opentrackr.org:1337/announce
	udp://open.demonii.com:1337
	http://explodie.org:6969/announce
	http://mgtracker.org:2710/announce
	http://tracker.tfile.me/announce
	udp://9.rarbg.com:2710/announce
	udp://9.rarbg.me:2710/announce
	udp://9.rarbg.to:2710/announce
	udp://tracker.coppersurfer.tk:6969/announce
	udp://tracker.glotorrents.com:6969/announce
	udp://tracker.leechers-paradise.org:6969/announce
	udp://tracker.openbittorrent.com:80
	http://90.180.35.128:6969/annonce
	udp://90.180.35.128:6969/annonce
	udp://tracker.coppersurfer.tk:6969/announce
	udp://p4p.arenabg.com:1337/announce
	udp://tracker.internetwarriors.net:1337/announce
	udp://tracker.skyts.net:6969/announce
	udp://tracker.safe.moe:6969/announce
	udp://tracker.piratepublic.com:1337/announce
	udp://tracker.opentrackr.org:1337/announce
	udp://allesanddro.de:1337/announce
	udp://9.rarbg.to:2710/announce
	udp://tracker.open-internet.nl:6969/announce
	udp://public.popcorn-tracker.org:6969/announce
	udp://inferno.demonoid.pw:3418/announce
	udp://trackerxyz.tk:1337/announce
	udp://tracker4.itzmx.com:2710/announce
	udp://tracker2.christianbro.pw:6969/announce
	udp://tracker1.wasabii.com.tw:6969/announce
	udp://tracker.zer0day.to:1337/announce
	udp://tracker.xku.tv:6969/announce
	udp://tracker.vanitycore.co:6969/announce
	udp://tracker.mg64.net:6969/announce
	EOF
}

iforgot-pixiv-image-sequence-download() {
	cat <<-EOF
	The animation is a bunch of JPG’s inside a ZIP.
	Pixiv downloads it and shows as a slideshow.

	How to download the ZIP file:
	1) Look at the HTML source of:
	   http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46157029
	2) Search for “.zip”
	3) On this particular page, you’ll get 2 results (other animations
	   might have more links):
	   http://i2.pixiv.net/img-zip-ugoira/img/2014/09/24/03/20/14/46157029_ugoira600x600.zip
	   http://i2.pixiv.net/img-zip-ugoira/img/2014/09/24/03/20/14/46157029_ugoira1920x1080.zip
	4) The first one is scaled down to a width of 600 pixels, so you probably
	   want the second one with a width of 700 pixels.
	3) Copy the second link into a text editor, and replace every
	   \/
	   with a
	   /
	4) Result:
	   http://i2.pixiv.net/img-zip-ugoira/img/2014/09/24/03/20/14/46157029_ugoira1920x1080.zip
	5) If you try to download this file, you’ll get a “403 Forbidden” error.
	6) What you need to do is set the referrer URL in your browser to:
	   http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46157029
	   You can do this with referrer spoofing add-ons.
	   This one’s for Firefox:
	   https://addons.mozilla.org/en-US/firefox/addon/refcontrol/

	EOF
}

iforgot-wine-debug() {
	cat <<-EOF
	WINEDEBUG operates on channels, and each of them has messaage classes.

	Example
	    WINEDEBUG=fixme+all,err+all – “default behaviour”
	    WINEDEBUG=loaddll – show (equal to +loaddll)
	    WINEDEBUG=warn+all
	    WINEDEBUG=trace+dll,warn-relay –

	Channels
	    all – catches all channels.
	    loaddll – will show, how dlls actually load.
	    relay – shows calls between DLLs.
	    heap – traces heap activity and switches on integrity checks. Doing
	           a +relay,+heap trace will narrow down where it's happening.
	There are 410 channels in total.

	Classes
	    fixme – should(!) tell, what is wrong, unimplemented parts.
	    err – should(!) tell about things that shouldn’t happen.
	    warn – should(!) tell, when a function cannot deal with smth.
	    trace – detailed debugging information.
	    message – messages oriented on end-user (rarely met).

	In reality, “warn” and “err” classes contain trash info messages,
	that confuse and complicate the understanding what actually went wrong.
	For example
	> err:winediag:wined3d_dll_init Setting multithreaded command stream to 0x1.
	Tells, that CSMR _actually works_!
	> warn:ntdll:NtQueryAttributesFile L"\\??\\Z:\\…\\msi.dll" not found (c0000034)
	Tells, that the library wasn’t found on that path. That doesn’t mean,
	however, that the file wasn’t found at all: it might be found somewhere
	else, but the corresponding message is in “trace” class, which is not
	shown by default.

	Links
	    https://wiki.winehq.org/Wine_User's_Guide
	    https://wiki.winehq.org/Wine_Developer's_Guide
	    https://wiki.winehq.org/Debug_Channels
	EOF
}

iforgot-json-console-parser() { echo -e '\tjq'; }

iforgot-mime-type-add-new() {
	cat <<-EOF
	You need to create two files in the depths of ~/.local/share/mime:

	1. ~/local/share/mime/application/x-my-new-type.xml

	<?xml version="1.0" encoding="utf-8"?>
	<mime-type
	    xmlns="http://www.freedesktop.org/standards/shared-mime-info"
	    type="application/x-my-new-type">
	<comment>My new type of files</comment>
	</mime-type>


	2. ~/.local/share/mime/packages/x-my-new-type.xml

	<?xml version="1.0" encoding="utf-8"?>
	<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
	<mime-type type="application/x-my-new-type">
	<comment>My new type of files</comment>
	<glob pattern="*.mnt" />
	</mime-type>
	</mime-info>

	Once the files have been created, updaate the MIME database:
	$ update-mime-database ~/.local/share/mime

	EOF
}

iforgot-djvu-tools() {
	cat <<-EOF
	Delete page №1 from a file
	$ djvm -d filename.djvu 1

	Insert a placeholder page on the 5th page to fix the order, or if pages
	are missing
	$ djvm -i main_document.djvu placeholder_file.djvu  5

	Extract page №8, lossless:
	$ ddjvu -format=tiff -page=8  myfile.djvu myfile.tiff

	PNM can be thought of as proto-24bit-png or proto-8bit-png
	$ ddjvu -format=pnm -page=8  myfile.djvu myfile.pnm

	Extract lossy tiff:
	$ ddjvu -format=tiff -quality 96 -page=8  myfile.djvu myfile.tiff

	Create a .djvu page from a colour JPEG
	$ c44 -slice 80+20+10+10  -dpi 300  input.jpeg  output.djvu

	Create a.djvu page from a monochrome PBM
	(use imagemagick’s convert to convert to PBM beforehand)
	$ cjb2 -dpi 300  -lossless  input.pbm  output.djvu
	EOF
}

iforgot-pdf-master-pdf-editor() {
	cat <<-EOF
	                                                            Free   Paid
	Create new PDF document from scanner or existing file(s)    +      +
	Fill PDF forms                                              +      +
	Add and/or edit bookmarks in PDF files                      +      +
	Comment and annotate PDF documents                          +      +
	Split and merge PDF documents                               +      +

	Edit PDF text and images, Create PDF Form                   −      +
	Optimize PDFs                                               −      +
	"Paste to Multiple Pages" function                          −      +
	Add/Edit Document Actions                                   −      +
	Manage Document JavaScript                                  −      +
	Page Properties options                                     −      +
	Sign PDF document with digital signature                    −      +
	Add Headers and Footers to PDFs                             −      +
	Add Watermarks to PDFs                                      −      +
	Add Backgrounds to PDFs                                     −      +
	256 bit AES encryption                                      −      +

	EOF
}

iforgot-matrix-clients() {  echo -e 'riot-web, nheko, quaternion';  }

iforgot-wine-bugs() {
	cat <<-EOF

	1. vcrun20xx doesn’t install

	   a) winetricks can install only x86 version. Not 64.
	   b) msxml is broken and should be reinstalled. winetricks list-installed
	      may show it among installed packages, but it still may be broken.
	      Typically on attempt to install vcrun2012 you’d see
	          017e:warn:ntdll:NtQueryAttributesFile L"\\??\\Y:\\vcrun2012\\msxml3.dll" not found (c0000034)
	          017e:warn:module:alloc_module disabling no-exec because of L"msxml3.dll"
	          017e:err:ole:apartment_getclassobject DllGetClassObject returned error 0x80040111
	          017e:err:ole:CoGetClassObject no class object {f5078f1b-c551-11d3-89b9-0000f81fe221} could be created for context 0x1
	          This is code of msxml--------------------------^^^^^^^^ ^^^^ ^^^^ ^^^^ ^^^^^^^^^^^^
	      Run
	      $ winetricks --force msxml3
	      to reinstall it forcefully. Then install vcrun20xx you need.

	2. …
	EOF
}

iforgot-console-browser() {
	cat <<-EOF
	1. w3m
	2. links -g
	EOF
}

iforgot-build-bin-before-update() {
	cat <<-EOF
	Before an update, build binary packages:
	- firefox (and backup profile directory, too!)
	- freetype + pango + cairo (because rendering bugs)
	- nvidia-drivers (because an update may be really shitty
	                  and old version may be removed).
	- skypeforlinux (various qt/alsa/udev bugs)
	EOF
}

iforgot-emerge-marks() {
	#  Explains * % () in USE-flags
	man -P "less -p '^\s+--verbose '" emerge
}

iforgot-gentoo-avoid-compiling-these-to-save-time() {
	cat <<-EOF
	llvm
	Compiling a low-level virtual machine is not necessary for most packages.
	If you have to do it, disable LLVM

	*kde*
	phonon
	*gnome*
	libreoffice (use libreoffice-bin)
	firefox (use firefox-bin)
	EOF
}

iforgot-waifu2x() {
	cat <<-EOF
	waifu2x-converter-cpp  --disable-gpu  -m scale  --scale_ratio 2 \
	                       -i hurr.jpeg  -o hurr2.jpeg

	waifu2x-converter-cpp  --disable-gpu  -m scale  --scale_ratio 2 \
	                       -i hurr.jpeg  -o hurr2.jpeg

	EOF
}

ifrogot-wine-uninstall() {
	cat <<-EOF
	wine uninstaller
	(wrapper will pick up correctly)
	EOF
}

iforgot-isolate-process-from-network-access() {
	zgrep CONFIG_NET_NS=y /proc/config.gz \
		&& echo "CONFIG_NET_NS=y – OK" \
		|| echo "Kernel config option CONFIG_NET_NS=y is required." >&2
	cat <<-EOF
	From your own user
	$ unshare -r -n program

	Or, safer
	(because unshare no longer drops root):
	$ sudo unshare -n sudo -u "$(whoami)" -g "$(id -g -n)" sh -c \
        "sudo -K && echo 'disconnected network, spawing subprocess...' && $@"

	As another user
	$ sudo unshare -n  sudo -u sszb  ping ya.ru
	EOF
}

iforgot-wine-commands() {
	cat <<-EOF
	CONSOLE
	    wineconsole
	    wine console

	EXPLORER
	    wine explorer /desktop=NAME,1024x768 program.exe

	    For i3
	    - single window workspace: 1920x1058
	    - on workspaces with a tabbed container: 1920x1038

	TASKMGR
	    wine taskmgr

	See also
	https://wiki.winehq.org/List_of_Commands

	EOF
}

iforgot-jpeg-to-pdf() {
	cat <<-EOF
	To create
	    $ convert  *.jpg  my-new.pdf

	To extract images
	    $ pdfimages  -j  my-new.pdf  "my-new"
	-f <number> – first page
	-l <number> – last page
	-j | -png | -tiff | -jp2 – write images as this format
	-all – write images as they are

	To compare
	    $ ssim.sh  0001.jpg  my-new-0001.jpg
	    …
	    ssim=1 dssim=0
	EOF
}

iforgot-bash-undo() {
	cat <<-EOF
	Press C-_ to undo something mistyped on the command line.
	(before you run it)
	EOF
}

iforgot-lxd-usage() {
	cat <<-EOF
	Create new container
	    $ lxc launch images:gentoo ctname

	Delete container
	    $ lxc delete ctname

	List containers
	    $ lxc list

	When it ain’t start
	    $ lxc info --show-log ctname

	Start container
	    $ lxc start ctname

	Get info
	    $ lxc info ctname

	Attach to container
	    $ lxc attach ctname
	    (use <C-a q> to quit
	  also
	    $ lxc exec test bash
	  better set up ssh

	Stop container
	    $ lxc stop ctname

	Mount a directory to a container
	    $ lxc config device add CTNAME SHARENAME disk source=/usr path=/usr

	Provide access to the X server access on the host for the container
	    $ lxc config device add CTNAME X0 disk path=/tmp/.X11-unix/X0 source=/tmp/.X11-unix/X0
	    $ lxc config device add CTNAME Xauthority disk path=/home/MY_USE_NAME/.Xauthority source=$XAUTHORITY

	Add host’s graphic card
	    $ lxc config device add CTNAME MYGPU gpu
	    $ lxc config device set CTNAME MYGPU uid 1000
	    $ lxc config device set CTNAME MYGPU gid 1000

	To be able to forward X apps to host’s X server:
	  On the host:
	    <launch Xorg WITHOUT -nolisten tcp (or pass -listen tcp)>
	    <make sure that you close port 6000 + $DISPLAY with iptables from WAN>
	    $ xhost +ctname
	  On the container
	    # eselect opengl list
	    # eselect opengl set <choose host’s opengl provider>
	    $ export DISPLAY=MAIN_HOST_NAME_OR_ADDRESS:0
	    $ LIBGL_DEBUG=verbose glxgears

	Make sure to build mesa without llvm, or you may see
	    $ LIBGL_DEBUG=verbose glxgears
	    libGL: OpenDriver: trying /usr/lib64/dri/tls/swrast_dri.so
	    libGL: OpenDriver: trying /usr/lib64/dri/swrast_dri.so
	    libGL: dlopen /usr/lib64/dri/swrast_dri.so failed (libLLVMX86Disassembler.so.6: cannot open shared object file: No such file or directory)
	    libGL error: unable to load driver: swrast_dri.so
	    libGL error: failed to load driver: swrast


	EOF
}

iforgot-nv-nvidia-nouveau() {
	cat <<-EOF
	To use nvidia driver:
	    1. Change config suffix to .nvidia
	    2. Add nomodeset nouveau.nomodeset drm.nomodeset to kernel cmdline.
	    3. Reinstall the driver to bring back udev rules

	To use nouveau driver:
	    1. Change config suffix to .nouveau
	    2. Remove any “nomodeset” from kernel cmdline
	    3. rm /lib/udev/rules.d/99-nvidia.rules

	EOF
}

iforgot-bib-record(){
	cat <<-EOF
	Scott. R. Book title / Tran. from German by C. Curie. — L.: Astonishing
	Press, 2018. — 223 p.
	EOF
}

iforgot-github-allowed-tags-html() {
	cat <<-EOF
    a p q br hr h1 h2 h3 h4 h5 h6 h7 h8 img div blockquote
        ol ul li
        dl dt dd
        table thead tbody tfoot caption tr td th
        figure figcaption
        details summary
        ruby rt rp
    b i var strong em pre samp code tt kbd sup sub s strike
    ins del

	https://github.com/jch/html-pipeline/blob/master/lib/html/pipeline/sanitization_filter.rb#L44-L106
	EOF
}

iforgot-dialog-programs() {
	cat <<-EOF
	Console
	  - dialog
	  - whiptail (package called newt)

	GUI
	  - zenity – shit.
	  - Xdialog – more capable, than zenity, but less than yad.
	  - yad – more capable, than zenity, but still shit.
	EOF
}

iforgot-theme-choosers() {
	cat <<-EOF
	GTK+2.x
	  - lxappearance

	QT4
	  - qtconfig -qt4

	QT5
	  - use the same “qtconfig -qt4”, then instal qtstyleplugins and export
	    QT_QPA_PLATFORMTHEME=gtk2
	EOF
}