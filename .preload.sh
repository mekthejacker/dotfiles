#should be sourced

# .preload.sh
# This script is intended to be a common part of ~/.xinitrc and ~/.xsession.
# It starts deamons needed to be started before the window manager.
# ~/.bashrc runs this script for ssh clients.

[ "$HOSTNAME" = paskapuukko ] && xbacklight -set 55

[ "${ENV_DEBUG/*p*/}" ] || {
	exec &>/tmp/envlogs/preload
	date
	echo My UID is $UID # shouldn’t be 0.
	set -x
}

export STARTUP=t WIDTH=800 HEIGHT=600 DPI=96 PRIMARY_OUTPUT \
	   GNUPGHOME GPG_TTY PATH XMODIFIERS GTK_IM_MODULE QT_IM_MODULE

# There’s actually no need in this, since in _my_ case I load SCIM after I do
#   first decrypting operations with GPG, so SCIM won’t interfere with
#   pinentry in any way. But there is this bug when you can’t input anything
#   in pinentry if SCIM is active, I may forget something, change the order
#   of actions or you may stumble upon this makeing your own ~/.preload.sh,
#   so just let it be here and use $gpg, not gpg.
#gpg="GTK_IM_MODULE= QT_IM_MODULE= gpg" # This doesn’t work for some reason.
# Starting zenity progress window to be aware when lags come from
#   if they appear.
pipe=/tmp/x_preloading_pipe
# It’d be suspicious that it does exist when it shouldn’t.
[ -p $pipe ] && rm -f $pipe
mkfifo $pipe
exec {pipe_fd}<>$pipe

bar_percentage=0
pre='XXX\n'; post='\nXXX'
#  $1  — message to output in progress dialog.
# [$2] — percentage to set the progressbar to.
#        If omitted, then add +5.
#        If consist only of '-' sign, keep current percentage.
push_the_bar() {
	[ "$2" ] && {
		[ $2 = '-' ] || {
			bar_percentage=$2
			echo "$bar_percentage" >$pipe
		} # no [ 1 -eq 1 ] needed because ||.
	}|| let bar_percentage+=5
	# That’s more for you than for me.
	[ $bar_percentage -gt 100 ] && {
		[ -v bar_index_exceeded ] || {
			Xdialog --msgbox "The index has just exceeded 100.
Looks like it’s time to reconsider addition policy." 480x95
			bar_index_exceeded=t
		}
		bar_percentage=100
	}
	echo $bar_percentage >$pipe
	echo -e "$pre $1 $post" >$pipe
}
Xdialog --gauge 'X preloading started!' 630x100 <$pipe &

# I. Initial preparations
push_the_bar "Cleaning `du -hsx ~/.local/share/gvfs-metadata` gvfs-metadata"
rm -rf ~/.local/share/gvfs-metadata

push_the_bar 'Retrieving output information'
n=0; while read outp; do
	[ -v PRIMARY_OUTPUT ] && eval export SLAVE_OUTPUT_$((n++))=$outp \
		|| PRIMARY_OUTPUT=$outp
done < <(xrandr --screen 0 | sed -nr 's/^(\S+) connected.*/\1/p')

# Disabling all other outputs except the main one BEFORE
#   gpg spawns pinentry window and autorun messes the workspace
#   with huge screen spread onto two monitors.
~/.i3/update_config.sh

push_the_bar 'Determining width, height and dpi of the primary output'
# These vars often used in the scripts later, e.g. in ~/bashrc/wine
# 211.6 is the width in mm of a display with dpi=96 and screen width equal to 800 px,
#   i.e. to get the default 96 dpi even if sed couldn’t parse xrandr output.
# Better look for a ‘connected primary’ display… or not?
#read WIDTH HEIGHT width_mm < <(xrandr | sed -rn 's/connected.*primary ([0-9]+)x([0-9]+).* ([0-9]+)mm x [0-9]+mm.*/\1 \2 \3/p; T; Q1' && echo '800 600 211.6')
#                                                                     ^ NB the whitespace
read WIDTH HEIGHT width_mm < <(xrandr | sed -rn 's/^.* connected.* ([0-9]+)x([0-9]+).* ([0-9]+)mm x [0-9]+mm.*$/\1 \2 \3/p; T; Q1' && echo '800 600 211.6')
DPI=`echo "scale=2; dpi=$WIDTH/$width_mm*25.4; scale=0; dpi /= 1; print dpi" | bc -q`
[ ${#OUTPUTS} -gt 0 ] && {
	push_the_bar 'Making sure that we operate on the first monitor'
	xte "mousemove $(( WIDTH/2 ))  $(( HEIGHT/2 ))"
	xte 'mouseclick 1'
}

# Autofs is laggy and slow.
grep -qF "$HOME/phone_card" /proc/mounts && sudo /bin/umount $HOME/phone_card
rm -f $HOME/phone_card
mkdir -m700 $HOME/phone_card &>/dev/null
c=0; until grep -q $HOME/phone_card /proc/mounts || {
	#[ "$HOSTNAME" = paskapuukko ] && break
	unset found mounted
    # mount with rw,nosuid,nodev,relatime,uid=1000,gid=1000,fmask=0022,dmask=0077,codepage=866,iocharset=iso8859-5,shortname=mixed,showexec,utf8,flush,errors=remount-ro and leav eit as is?
	disk=`sudo /sbin/findfs LABEL=PHONE_CARD`
	found_res=$?
	[ $found_res -eq 0 ] && found=t
	[ -v found ] && sudo /bin/mount -t vfat -o users,fmask=0111,dmask=0000,rw,codepage=866,iocharset=iso8859-5,utf8 $disk $HOME/phone_card && mounted=t
	}; do
	days=$((c/60/60/24))
	[ $days -eq 0 ] && days=
	hours=$((c/60/60))
	[ $hours -eq 0 ] && hours=
	mins=$((c/60))
	[ $mins -eq 0 ] && mins=
	secs=$((c++%60))
	push_the_bar "Waiting for ~/phone_card to appear ${days:+$days days }${hours:+$hours hours }${mins:+$mins minutes and }$secs seconds${found:+\nFound }${mounted:+ Mounted}" -
	sleep 1
	pgrep -af 'Xdialog --gauge X preloading started! 630x100' \
		||{ NO_KEYS=t; break; }
done

[ -v NO_KEYS ] || {
	push_the_bar 'Creating /tmp/decrypted'
	# This directory will be a temporary storage for decrypted files.
	# /tmp shall be mounted as tmpfs.
	rm -rf /tmp/decrypted &>/dev/null
	mkdir -m 700 /tmp/decrypted

	push_the_bar 'Copying GNUPG and SSH keys to the tmpfs'
	cp -R ~/phone_card/.gnupg /tmp/decrypted/
	cp -R ~/phone_card/.ssh /tmp/decrypted/
	chmod -R a-rwx,u=rwX /tmp/decrypted
	push_the_bar 'Unmounting flash card'
	sudo /bin/umount $HOME/phone_card && rmdir ~/phone_card
}

# II. Setting account information
push_the_bar 'Loading keyboard settings' 33
# Keyboard setting need to be set before pinentry windows will appear asking
#   for passphrases (this is not needed for SSH sessions)
[ -v DISPLAY ] && ~/.i3/set_keyboard.sh

[ -v NO_KEYS ] || {
	push_the_bar 'Checking gpg-agent'
	GNUPGHOME=/tmp/decrypted/.gnupg
	pgrep -u $UID gpg-agent || {
		push_the_bar 'Starting gpg-agent'
		eval $(gpg-agent --daemon --use-standard-socket )
	}
	push_the_bar 'Exporting gpg-agent data'
	GPG_TTY=`tty`

	## Loading SSH keys.
	## After I found _very strange_ behaviour of gpg-agent I decided to refuse of
	##   using it in relation to keeping ssh keys. Even without the agent all
	##   authentications will still work as they should, if the keys are bound
	##   to appropriate hosts in ~/.ssh/config.
	## However, having passphrases in keys along with the need to use gpg-agent
	##   may bring some troubles. Mine keys don’t have passphrases.
	##
	# push_the_bar 'Loading SSH keys.'
	# for ssh_key in `grep -l 'PRIVATE KEY' ~/.ssh/*`; do
	## W! Strange bug: after proper key fails to authenticate(!) due to
	##   error: RSA_public_decrypt failed: error:0407006A:lib(4):func(112):reason(106)
	##   dwarf_fortress_regions.zip ebug1: ssh_rsa_verify: signature incorrect
	# gpg-agent may try any other killsteam.sh key.
	# ssh-add "$ssh_key" </dev/null
	# done
	# unset ssh_key

	push_the_bar 'Decrypting user name'
	eval export `gpg -qd ~/.env/private_data.sh.gpg 2>/dev/null | grep -E '^ME(_FOR_GPG)*\b'`

#	push_the_bar 'Decrypting Box account information'  # http://box.com
#	gpg -qd --output /tmp/decrypted/secrets.`date +%s` ~/.davfs2/secrets.gpg
#	{ ping -c3 8.8.8.8 &>/dev/null \
#		&& sudo /root/scripts/mount_box.sh $USER \
#		&& export BOX_MOUNTED=t; } &
}

# III. Setting the rest of X environment.
push_the_bar 'Exporting custom ~/bin into PATH' 66
# In order to have some applications that store data open for everyone
#   who can boot your PC, there are substitution scripts that decrypt data
#   from repository and delete them after application is closed.
PATH="$HOME/bin:$PATH"

push_the_bar 'Launching SCIM'
LANG='en_US.utf-8' scim -d
XMODIFIERS=@im=SCIM
GTK_IM_MODULE=scim
QT_IM_MODULE=scim

push_the_bar 'Making symlinks for config files'
ln -sf ~/.config/htop/htoprc.$HOSTNAME ~/.config/htop/htoprc

push_the_bar 'Loading ~/.Xresources to Xorg'
xrdb ~/.Xresources
push_the_bar 'Helping X server to find localized Terminus'
xset +fp /usr/share/fonts/terminus && xset fp rehash
push_the_bar 'Disabling screensaver'
xset s off

echo "101" >$pipe
exec {pipe_fd}<&-
rm $pipe
pkill -9 -f Xdialog
export -n STARTUP
