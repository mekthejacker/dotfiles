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
		echo -e "\tiforgot <something> <also this>"
	}
	func_list=(`declare -F | sed -nr 's/^declare -f (iforgot-.*)/\1/p'`)
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
			type $func | sed -rn '1d
			                      /^iforgot.*'$k'/,/}/d
			                      2H
			                      /'$k'/H
			                      ${ g; s/'$k'/'$k'/;t good; Q
			                            :good s/\s+/ /g
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
}

iforgot-restart-daemons-from-the-runlevel-i-am-in() {
echo 'USE CAREFUL.'
cat <<"EOF"
	for i in `rc-update | sed -rn 's/[ ]+([^ ]+) \| '"runlevel"'.*/\1/p'`; do
		/etc/init.d/$i restart
	done
EOF
}

iforgot-make-etags-for-emacs() {
cat <<"EOF"
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
cat <<"EOF"
	for i in `modprobe -l | sed -rn 's|.*/hwmon/([^/]+)$|\1|p'`; do
		modprobe $i
	done
EOF
}

iforgot-fsck-force-check() {
	echo -e \\t touch /forcefsck
}

iforgot-make-a-debug-build() {
cat <<"EOF"
	FEATURES="ccache nostrip" \
		USE="debug" \
		CFLAGS="…-ggdb" \
		CXXFLAGS="<CFLAGS>" \
		emerge $package
OR
	gdb --pid <pid>
	thread apply all bt
EOF
}

iforgot-read-via-x0() {
cat <<"EOF"
	while IFS= read -r -d $'\0'; do
		echo "$REPLY"
	done <  <(find -type f -print0)

	(-d '' also works since \0 is a marker for an empty string.)
EOF
}

iforgot-where-is-my-completion() {
cat <<"EOF"
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
cat <<"EOF"
	xset +fp /usr/share/fonts/terminus && xset fp rehash
EOF
}

iforgot-extended-regex-purpose() {
	set -x
	shopt -s extglob && abc='000123' && echo ${abc##+(0)}
	set +x
}

iforgot-how-to-trace-and-debug() {
cat <<EOF
	# Trace library and system calls:
	strace -p PID
	ltrace -p PID
	# Look for opened files of process with pid PID
	ls -l /proc/PID/fd/*
	# Kill a process to see its core
	kill -11 PID
EOF
}

iforgot-bookmarks-in-manpages() {
cat <<"EOF"
	man -P 'less -p \"^\s+Colors\"' eix
EOF
}

iforgot-git-new-repo() {
cat <<"EOF"
	git init
	git remote add origin git@example.com:project_team.git
                          ssh://git@example.com:port/reponame.git
    git add .
	git commit -m "fgsfds"
	git push origin refs/heads/master:refs/heads/master
EOF
}

iforgot-select-figlet-font-for-me() {
cat <<"EOF"
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
cat <<"EOF"
	for i in `cat ~/cool_fonts`; do
		echo $i
		figlet -f $i -c 12345
		figlet -f $i -c 67890
	done
EOF
}

iforgot-chroot-procedure() {
cat <<"EOF"
	mount -t proc none /mnt/chroot/proc
	mount --rbind /sys /mnt/chroot/sys
	mount --rbind /dev /mnt/chroot/dev
	[linux32] chroot /mnt/chroot /bin/bash

		env-update && source /etc/profile
		export PS1="(chroot) $PS1"
		# mount /boot /usr etc.
		…
		exit

	umount -l /mnt/chroot/dev{/shm,/pts,}
	umount /mnt/chroot{/boot,/sys,/proc,}
EOF
}

iforgot-ordinary-user-groups() {
	echo -e "\tuseradd -m -G audio,cdrom,games,plugdev,cdrw,floppy,portage,usb,video,wheel -s /bin/bash username"
}

# SMART
iforgot-smart-immediate-check() {
	echo -e '\tsmartctl -H /dev/sdX'
}

iforgot-smart-selftest-short-now() {
	echo -e '\tsmartctl -t short /dev/sdX'
}

iforgot-smart-selftest-long-now() {
	echo -e '\tsmartctl -t long /dev/sdX'
}

iforgot-smart-selftest-long-later() {
	echo -e '\tsmartctl -t long -s L/../.././23'
}

iforgot-smart-selftest-sheduling-syntax() {
	echo -e "\t man -P\"less -p'^\s+-s REGEXP'\" smartd.conf"
}

iforgot-mark-bad-sector-with-badblocks() {
cat <<"EOF"
    If situation looks like this

# smartctl -a /dev/sda
SMART Attributes Data Structure revision number: 10
Vendor Specific SMART Attributes with Thresholds:
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
…
  5 Reallocated_Sector_Ct   0x0033   099   099   036    Pre-fail  Always       -       61
…
197 Current_Pending_Sector  0x0012   100   100   000    Old_age   Always       -       1
198 Offline_Uncorrectable   0x0010   100   100   000    Old_age   Offline      -       1

…

SMART Self-test log structure revision number 1
Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
# 1  Extended offline    Completed: read failure       20%     22638         1670581106

    Then seeking for a badblock will look like that

badblocks -vs -b512 /dev/sda 1670581106 1670581106

    -v – verbose, -s shows progress, -b is block size, 512 since 1670581106 is
  an LBA, i.e. sector address and sectors are usually are 512 bytes long.
  First address is the end of the range where badblocks seek, and the last one
  points at the start of the range. Also there are useful -n and -w options
  which mutually exclude themselves – -n safely rewrites block’s contents,
  -w rewrites it with binary patterns and causes data loss. By default
  badblocks does only read-only check (that works for me).

    If it confirms the sector is truly bad, then we need to get the address
  in blocks on your partition, the offset, an pass it as the number of block
  as your filesystem understands, usually it is multiple of 512, e.g. 4096.

fdisk /dev/sda

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *          63       80324       40131   83  Linux
/dev/sda2           80325   104952644    52436160   83  Linux
/dev/sda3       104952645   109161674     2104515   83  Linux
/dev/sda4       109162496  1953525167   922181336   83  Linux

    So, the problem LBA belongs to /dev/sda4, now get the offset on that
partition.

echo 'scale=3;(1690581106-109162496)/8' | bc
195177326.25

    Fraction part means it is the second sector of eight in that block.
   (Since one block of 4096 bytes contains 8*512 bytes sectors, 1/8 is
     0.125 and 2/8 is 0.25)
    The formula is

<bad_LBA> - <start_LBA_of_its_partition> / (<fs_block_size> / <sector_size>)

    So, produce the list

echo '(1690581106-109162496)/8' | bc > /tmp/bb_list

    And call e2fsck

umount /<mountpoint for partiton with bad LBA>
e2fsck -l /tmp/bb_list /dev/sdX

    If e2fsck called with -L option instead of -l, the passed file will rewrite
  all the list of badblocks contained in the filesystem. That list can be
  checked with

dumpe2fs -b /dev/sda4

EOF
}

# Wi-Fi
iforgot-wifi-check-link() {
cat<<EOF
    iwconfig
    iw dev wlan0 link
EOF
}

iforgot-wifi-connect() {
cat <<"EOF"
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
wpa_supplicant -B -Dnl8011 -iwlan0 -c/etc/wpa_supplicant.conf  # -D wext
busybox udhcpc -x hostname iamhere -i wlan0  # dhcpcd
EOF
# From https://www.pantz.org/software/wpa_supplicant/wirelesswpa2andlinux.html
}

iforgot-wifi-scan() {
	echo -e "\tiwlist wlan0 scanning"
}

iforgot-ffmpeg-2-pass-vbr-encoding() {
cat <<"EOF"
    ffmpeg -y -i "$input_file" -an -pass 1 -threads 3 \
           -vcodec libx264 -vpre slow_firstpass "$tmpfile"

    ffmpeg -y -i "$input-file" \
           -acodec libfaac -ar 44100 -ab 192k \
           -pass 2 -threads 3 \
           -vcodec libx264 -b 2000k -vpre slow "$tmpfile" "$output-file"
EOF
}

iforgot-ffmpeg-opts-for-encoding() {
cat <<EOF
ffmpeg_opts="-vcodec libx264 -b 1024k -s 800x480 \
             -acodec libfaac -ab 128k \
             -flags +loop+mv4 -cmp 256 \
             -partitions +parti4x4+parti8x8+partp4x4+partp8x8+partb8x8 \
             -me_method hex -me_range 16 \
             -subq 7 -trellis 1 \
             -refs 5 -bf 0 \
             -flags2 +mixed_refs \
             -coder 0 -g 250 -keyint_min 25 \
             -sc_threshold 40 \
             -i_qfactor 0.71 -qmin 10 -qmax 51 -qdiff 4"
EOF
}

iforgot-tee-usage() {
cat <<"EOF"
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

iforgot-emoji-drawing() {
cat <<"EOF"
▽△　▲▼    sankaku
☆★＊      hoshi
〆        shime
米※       kome
益        yaku

⚈д⚈ ⌕…⌕ °ヮ° ´Д` ╭(＾▽＾)╯ /(⌃ o ⌃)\ ╰(^◊^)╮ ◜(◙д◙)◝ ʘ‿ʘ  ≖‿≖

 ´ ▽ ` )ﾉ  (・∀・ )  (ΘεΘ;)  ╮(─▽─)╭  (≧ω≦)  (´ヘ｀;)  (╯3╰)  (⊙_◎)  (¬▂¬)

(つд⊂)

( ^▽^)σ)~O~)

キタ━━━(゜∀゜)━━━!!!!!   ‘It’s here’, Kitaa!, a general expression
                        of excitement that something has appeared
                        or happened or ‘I came’.
( ˙灬˙ )                Pedo hige
(・∀・)~mO               Flash of intuition
m9(・∀・)                NO U
ヽ(°Д°)ﾉ
(╬♉益♉)ﾉ
Ԍ──┤ﾕ(#◣д◢)
(☞ﾟヮﾟ)☞
( `-´)>	                Salute
(*ﾟﾉOﾟ)<ｵｵｵｵｫｫｫｫｫｫｫｰｰｰｰｰｲ!	Calling out, "Ooooi!"
Σ(゜д゜;)	            Shocked
(*´Д`)ﾊｧﾊｧ               Erotic stirring, haa haa
(ﾟДﾟ;≡;ﾟДﾟ)
( ﾟ∀ﾟ)ｱﾊﾊ八 八 ﾉヽ ﾉヽ ﾉヽ ﾉ ＼  / ＼ / ＼
（･∀･)つ⑩
щ(ﾟДﾟщ)(屮ﾟДﾟ)屮          Come on
（・Ａ・)                ‘That’s bad’
(*⌒▽⌒*)
＼| ￣ヘ￣|／＿＿＿＿＿＿＿θ☆( *o*)/	Kick
(l'o'l)	                Shocked
(╯°ロ°）╯  ┻━━┻
┬──┬ ﻿ノ( ゜-゜ノ)
EOF
}

iforgot-sed-newline-simple-removal() {
cat<<"EOF"
    echo -e '1\n2\n3\n4\n5' | sed -rn '1h; 2,$ H; ${x;s/\n/---/g;p}'
EOF
}

iforgot-set-default-wine-environment-wineprefix() {
	set-wineprefix
}

iforgot-diff-patch() {
	echo -e "\tdiff -u file1 file2"
}

iforgot-gpg-privkey() {
cat <<"EOF"
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

iforgot-last-argument-passed-to-shell() {
	echo 'echo !$'
}

iforgot-qemu-create-image() {
cat <<EOF
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
cat<<EOF
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
cat<<"EOF"
	"\e@": complete-hostname
	"\e{": complete-into-braces
	"\e~": complete-username
	"\e$": complete-variable
EOF
}

iforgot-iptables() {
	cat <<"EOF"
Destination NAT means, we translate the destination address of a packet to make it go somewhere else instead of where it was originally addressed.

    # iptables -t nat -A  PREROUTING -d 10.10.10.99/32 -j DNAT --to-destination 192.168.1.101

Source NAT. We want to do SNAT to translate the from address of our reply packets to make them look like they’re coming from 10.10.10.99 instead of 192.168.1.101.

    # iptables -t nat -A POSTROUTING -s 192.168.1.101/32 -j SNAT --to-source 10.10.10.99

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

iforgot-shell-colours(){
cat<<EOF
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

cat <<EOF

	As far as I know, there’s no way to query the colors of the terminal
emulator. You can change them with \e]4;NUMBER;#RRGGBB\a (where NUMBER is
the terminal color number (0–7 for light colors, 8–15 for bright colors)
and #RRGGBB is a hexadecimal RGB color value) if your terminal supports
that sequence (reference: ctlseqs). —http://unix.stackexchange.com/a/1772/10075
See also http://misc.flogisoft.com/bash/tip_colors_and_formatting
EOF
}

iforgot-webm-conversion() {
cat <<"EOF"
	ffmpeg -threads 4 -i input.mov \
	       -acodec libvorbis -ac 2 -b:a 192k -ar 44100 \
	       -b:v 1000k -s 640x360 output.webm
EOF
}

iforgot-x264-conversion() {
cat <<EOF
	ffmpeg -threads 4 -i input.mov \
	       -acodec libfaac -b:a 96k \
	       -vcodec libx264 -vpre slower -vpre main \
	       -level 21 -refs 2 -b:v 345k -bt 345k \
	       -threads 0 -s 640x360 output.mp4
EOF
}

iforgot-image-conversion() {
cat <<EOF
	ffmpeg  -y -threads 4 -pattern_type glob \
	        -framerate 1/5 -i "file_name_000*.png" \
	        -c:v libvpx -r 1 -pix_fmt yuv420p out.webm

https://trac.ffmpeg.org/wiki/Create%20a%20video%20slideshow%20from%20images
EOF
}

iforgot-clean-gentoo() {
cat <<EOF
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
cat <<EOF
	ffmpeg -y -threads 8 -i in.webm -ss 00:00:01 -t 00:02:22 -async 1 -b:v 500k out.webm

+crop
	-filter:v "crop=WIDTH:HEIGHT:X_OFFSET:Y_OFFSET"

Webm issues: it ifnores -b:v -minrate -maxrate and -crf. Use -qmin and -qmax.
	ffmpeg -y -threads 8 -async 1 \
		-i /home/video/anime/\[ReinForce\]\ Ergo\ Proxy\ \(BDRip\ 1920x1080\ x264\ FLAC\)/\[ReinForce\]\ Ergo\ Proxy\ -\ 11\ \(BDRip\ 1920x1080\ x264\ FLAC\).mkv  -ss 00:00:00 \
		-t 00:00:15.849 -b:v 12M -crf 4 -minrate 12M -maxrate 12M -qmin 0 -qmax 0 -vf scale=1280:720 /tmp/out.webm
EOF
}

iforgot-catenate-video-with-ffmpeg() {
cat <<EOF
	find . -iname "part*.webm" | sort >files
	ffmpeg -y -threads 8 -f concat -i files -c copy -async 1 out.webm
EOF
}

iforgot-create-video-from-image-sequence-with-ffmpeg() {
echo 'ffmpeg -y -framerate 1/5 -pattern_type glob_sequence -i "./[Commie] Psycho-Pass 2 - 08 [A844F60A]_%*.png" -c:v libvpx -b:v 500k -r 30 -pix_fmt yuv420p out.webm && mpv out.webm'

echo Actually, someday they should fix -pattern_type glob and '*.png' and '%d'
}

iforgot-record-my-desktop() {
	cat <<"EOF"
ffmpeg -y  -f x11grab -video_size 1600x875 -framerate 25 -i :0.0+0,25 -f alsa -ac 2 -i hw:0 -async 1 -b:v 1000k -vcodec libx264 -crf 0 -preset ultrafast -acodec pcm_s16le /tmp/output.mkv

P.S. Don’t forget to switch mpv’s -vo to opengl-hq or something for ffmpeg to be able to catch its output.
EOF
}

iforgot-check-own-process-memory() {
cat <<EOF
	pmap from procps.
	# pmap -d `pidof X`
	Writeable — this is it.
EOF
}

iforgot-commie-check-whats-up() {
	echo -e "\t.blame <what>"
}

iforgot-firefox-settings() {
cat <<EOF
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


iforgot-audio-recording() {
cat <<EOF
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
	-8
}

iforgot-libreoffice-writer-images() {
	cat <<EOF
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
	cat <<"EOF"
	find /path -name '*.pdf' -exec sh -c 'pdftotext "{}" - | grep --with-filename --label="{}" --color "your pattern"' \;
EOF
}

iforgot-ffmpeg-add-image-to-video() {
	cat<<"EOF"
	# Add five seconds of video
	ffmpeg -loop 1 -f image2 -i image.png -r 30 -t 5 image.webm
	# Create input file for ffmpeg
	find -iname "*.webm" -printf "file '%p'\n" | sort >inp
	# Catenating the files
	ffmpeg -f concat -i inp -codec copy output.webm
EOF
}

iforgot-voip-via-netcat() {
	cat <<"EOF"
	(read; echo; rec --buffer 17 -q -w -s -r 48000 -c 1 -t raw -)|netcat -u -l -p 8888|(read; play -w -s -r 48000 --buffer 17 -t raw -)
	(echo; rec --buffer 17 -q -w -s -r 48000 -c 1 -t raw -)|netcat -u 192.168.1.1 8888|(read; play -w -s -r 48000 --buffer 17 -t raw -)
EOF
}

#removes *.desktop files
iforgot-wine-clean-desktop() {
	rm /home/sszb/.wine/drive_c/users/sszb/#msgctxt#directory#Desktop/*
}

iforgot-wget-mirror-site() {
	cat <<"EOF"
	wget --mirror --convert-links --adjust-extension --page-requisites --no-parent http://example.org'
or shorter:
	wget -mkEpnp http://example.org
EOF
}

iforgot-wifi-why-it-doesnt-work() {
cat <<"EOF"
	card is requiring CONFIG_CFG802011_WEXT=y
	card is hw/soft bloced: rfkill list
	card is in wrong CRDA region: iw reg get/set <AA>
EOF
}

iforgot-audio-conversion() {
	echo -e '\tffmpeg -i input.wav -vn -ar 44100 -ac 2 -ab 192k -f mp3 output.mp3'
}

iforgot-keyboard-print-map() {
cat <<"EOF"
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
	cat <<"EOF"
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

iforgot-convert-audio-with-ffmpeg() {
	echo -e "\tffmpeg -i audio.ogg -acodec mp3 newfile.mp3"
}

iforgot-check-unicode-symbol() {
	cat <<EOF
	echo -n 'ß' | uniname
	echo -n $'\'' | uniname
EOF
}

iforgot-clean-git-repo-totally() {
cat <<EOF
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
cat <<EOF
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

iforgot-cd-back() { echo -e '\tcd ~-'; }

iforgot-hex-to-dec-conversion() {
cat<<"EOF"
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

iforgot-nested-x() { echo -e '\tXephyr :108 -resizeable &'; }

iforgot-eix() {
cat <<EOF
Show what’s installed from an overlay
    $ eix --only-names --in-overlay <overlay>
Also helpful
    $ equery has repository sunrise
Find a package by [category/]name
    $ eix -A [category/]name
Find packages by description
    $ eix -S "viewer"
Find pacakges by description in a particular category
    $ eix -S "viewer" -C app-text

-c
-Ac
-ec

EOF
}

iforgot-mkfs-ext4-options() {
cat<<EOF
For /boot:
	# 40–50 MiB should be enough.
For /:
	# Actually, 1 mln inodes is enough, 200% is for accidental need for a system in chroot.
	mkfs.ext4 -j -L "root" $(: -b1024) -O extent,dir_index -N 300000 /dev/sda2
For /home:
	# For home, the number of inodes is around 500K per TB.
	mkfs.ext4 -j -L "home" -m0 -O extent,dir_index,sparse_super -N 500000  /dev/sda3
EOF
}

iforgot-nmap-scan() {
cat<<EOF
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
cat<<EOF
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
cat<<EOF
Say we have imgur.com blocked in our network. But there is a server which can access it.
	ssh -N -L 9000:imgur.com:80 user@server
Then open localhost:9000 in your browser.
EOF
}

iforgot-ssh-multiple-port-forward() {
cat <<EOF
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
cat <<EOF
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
cat<<EOF
Specific host:
    tcpdump -i eth0 -s0 -vv host 239.255.255.250
All multicast:
    tcpdump -i eth0 -s0 -vv net 224.0.0.0/4

    Don’t forget to check smcroute join/leave.
EOF
}

iforgot-lsof-fuser() {
cat <<EOF
    fuser -m <filesystem>
    lsof | grep <filesystem>
    vmtouch <file>
EOF
}

iforgot-tcpdump-usage() {
# http://www.rationallyparanoid.com/articles/tcpdump.html
cat <<EOF
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

Filter to match DHCP packets including a specific client MAC address:
tcpdump -i br0 -vvv -s 1500 '((port 67 or port 68) and (udp[38:4] = 0x3e0ccf08))'
Filter to capture packets sent by the client (DISCOVER, REQUEST, INFORM):
tcpdump -i br0 -vvv -s 1500 '((port 67 or port 68) and (udp[8:1] = 0x1))'
EOF
}

iforgot-git-amend() {
	cat <<EOF
If you haven’t pushed changes upstream, ‘git commit --amend’ should be enough.
If you did, you have to rebase the current HEAD.
     git rebase -i HEAD~2
will print the last commit, and you should delete the last of two lines, then do
     git push origin +master
EOF
}

iforgot-cd-to-previous-dir() {
	echo -e '\tcd -'
}

iforgot-tail-print-from-nth-line() {
	cat <<EOF
Remove all but the last filename.
	ls -r | tail -n+2 | xargs rm
EOF
}

iforgot-combine-images-together() {
	cat <<EOF
Use convert from imagemagick.
    convert  img1.png  img2.png img3.png -append out.png

-append → from top to bottom
+append → from left to right
EOF
}

iforgot-google-search() {
cat <<"EOF"
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
cat<<"EOF"
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
cat<<"EOF"
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
    C-a c        create new window
        d        detach client
        j        prev window
        l        next window
        Space    last window
        r        respawn window
        R        reload ~/.tmux.conf
        w        choose window interactively
        x        close pane/window
        2        split horizontally
        3        split vertically
        o        move between panes in a split window
        4        rename window
        $        rename session
        ?        list-keys
        :lsk     — » —
        :list-keys    — » —
        :monitor-activity <on|off>    enable/disable activity
                                      monitoring
        :monitor-content <string>    the same, but for the
                                     specified string.
EOF
}

iforgot-find-newer-older() {
	cat <<"EOF"
Find those that have been modified in the last two days
  i.e. newer than 2 days:
    find -mtime -2

Find the files older than 2 days:
    find -mtime +2
EOF
}

iforgot-trace-there-and-back() {
	cat <<EOF
    ping -R -c1 XX.XX.XX.XX
    NB: 9 hops max!
EOF
}

iforgot-easyrsa-procedure() {
	cat <<EOF
1. Copy to another place
    # cp -a /usr/share/easy-rsa /root/easy-rsa-example
    # cd !$
2. Edit ‘vars.example’ and save it as ‘vars’
    # nano vars.example
3. Prepare directories
    # easyrsa init-pki
4. Create CA certificate and key. That passphrase must be common for our company.
    # easyrsa build-ca
5. Create parameters for the Diffie–Hellman exchange
    # easyrsa gen-dh
6. Generate crl.pem
    # easyrsa gen-crl
7. Generate TLS authentication key
    # openvpn --genkey --secret pki/private/ta.key
8. Build server certificate and key.
    # easyrsa build-server-full SERVERNAME
9 Generate a passphrase for its client
    # openssl rand -base64 6
10. … and build client’s certificate and key.
    # easyrsa build-client-full CLIENTNAME
11. To decrypt a key in order to avoid entering passphrase every time
    # cd pki/private
    # cp NAME.key NAME.key NAME.key.org
    # openssl rsa -in ./NAME.key.org -out ./NAME.key

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
	cat<<EOF
NB  TUN is a L2 device and TAP is L3. They are incompatible,
    and the device setting must match on server and client.
In the config use just "tun" or "tap", to make openvpn
dynamically create a device.

And finally, to let us into the other network…
# iptables -A INPUT -i tun+ -j ACCEPT
# iptables -A FORWARD -i tun+ -j ACCEPT
# see also SNAT/MASQUERADE above
EOF
}

iforgot-ssh-rsh-copy-dir-with-tar() {
cat<<EOF
    rsh kumquat mkdir /work/bkup/jane
    tar cf - . | rsh kumquat 'cd /work/bkup/jane && tar xBf -'
EOF
}

iforgot-tar() {
cat<<"EOF"
Create an archive

    tar -a -c -v -p -f archive.tar.xz DIRECTORY
          \  \  \  \  \
           \  \  \  \  \_ file name
            \  \  \  \_ preserve attributes
             \  \  \_ verbose output
              \  \_ create (or compress)
               \_ automaticallly detect the compressor from the extension
Decompress

    tar -a -x [-v] -f archive.tar.xz -C CD_HERE_BEFORE_EXTRACTION
             \
              \_ eXtract

EOF
}

iforgot-ssh-close-hanging-session() {
cat <<EOF
    ~.

    ~ is the default escape character (can be altered with -e <escape_char>).
    Escape character + dot closes the hanging session.
EOF
}

iforgot-seconds-to-hms() {
cat <<EOF
	date -d@36 -u +%H:%M:%S
	00:00:36

	secs=100000
	printf '%dd:%02dh:%02dm:%02ds\n' $((secs/86400)) $(($secs/3600)) $(($secs%3600/60)) $(($secs%60))
EOF
# From http://stackoverflow.com/a/28451379/685107
}

iforgot-find-broken-links() {
cat <<EOF
    find -xtype l rm {} \+
EOF
}

iforgot-xdg-dirs() {
cat<<EOF
Show:
    xdg-user-dir DESKTOP
Set:
    grep ^[^#] ~/.config/user-dirs.dirs
EOF
}

iforgot-framebuffer-with-utf8() {
	echo jfbterm
}

iforgot-bash-regexes() {
cat <<"EOF"
    man -P "less -p '^\s+\[\['" bash
EOF
}

iforgot-text-utils() {
cat <<EOF
    fmt — reformat lines to width.
    fold – simple version of the above.
    column – autoformat columns.
    colrm — remove columns.
    paste – merge lines from two files
EOF
}

iforgot-nginx-hashed-passwords() { echo -e '\topenssl passwd -apr1'; }

iforgot-bash-fast-replace() {
cat<<"EOF"
    !!:gs/pattern/replacement/
EOF
}

iforgot-git-merge-resolve-conflicts() {
cat <<"EOF"
    git reset --hard
    git rebase --skip
After resolving conflicts, merge with
    git add $conflicting_file
    git rebase --continue
EOF
}

iforgot-tmpfs-no-space-left() {
cat <<EOF
If /tmp is mounted as tmpfs, there may be such situation as ‘no space left’
while du -hsx say there’s plenty. And df -h at the same time will confirm,
that there’s no free space left. What did take that space? Old files, that
were removed. Why are they holding space? There are processes that still
hold on these files. Kill these processess, and the space will be freed.
How to find such processes?
    $ lsof | grep /tmp | grep deleted   # | while read pid; do kill -9 $pid; done
EOF
}

iforgot-ssh-multiple-commands() {
cat <<"EOF"
Since
    $ ssh myhost "ls foo; cd bar"
as well as
    $ ssh myhost /bin/bash -c 'ls foo; cd bar'
won’t work as expected, the only way to pass multiple commands is to use herestring
    $ ssh myhost <<<"ls foo; cd bar"
or heredoc
    $ ssh myhost <<EOF
          ls foo
          cd bar
      EOF

Remember to use "EOF" to prevent early expansion, and <<-EOF to strip tabs, if necessary.
EOF
}

iforgot-ssh-nohup-fork-to-background() {
cat <<"EOF"
If
    $ ssh myhost <<<"cd bar; (nohup ./a_daemon.sh) &"
    . . . .
hangs, and -f (fork to background) doesn’t work because stdin in not a terminal, specify stdin and stdout for nohup:
    $ ssh myhost <<<"cd bar; (nohup ./a_daemon.sh </dev/null &>/dev/null) &"
    $
EOF
}
#
 #  If you want more, I find these sites helpful:
#
# https://www.pantz.org
