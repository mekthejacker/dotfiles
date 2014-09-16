#should be sourced

# preload.sh
# This script is intended to be a common part of ~/.xinitrc and ~/.xsession.
# It starts deamons needed to be started before the window manager.
# ~/.bashrc runs this script for ssh clients.

set -x
exec &>~/preload.log
date

# Starting zenity progress window to be aware when lags come from
#   if they appear.
pipe=/tmp/x_preloading_pipe
# It’d be suspicious that it does exist when it shouldn’t.
[ -p $pipe ] && rm -f $pipe
mkfifo $pipe
exec {pipe_fd}<>$pipe
zenity --progress --percentage=0 --text="X preloading started!" <$pipe &

echo -e "5\n# Getting output information" >$pipe
n=0; while read outp; do
	[ $((n++)) -eq 0 ] && export PRIMARY_OUTPUT=$outp \
		|| eval export SLAVE_OUTPUT_$((n-1))=$outp
done < <(xrandr --current | sed -nr 's/^(\S+) connected.*/\1/p')
# This assumes the first screen listed is the main in use.
read WIDTH HEIGHT  <<< `xrandr | \
	sed -nr 's/^\s+([0-9]+)x([0-9]+).*\*.*/\1\n\2/p;T;Q1' && echo -e '800\n600'`
export WIDTH HEIGHT # often being used in my own scripts later
xte "mousemove $(( WIDTH/2 ))  $(( HEIGHT/2 ))"
xte 'mouseclick 1' # making leftmost monitor active
# Attempt to set multimonitor
#xrandr --output VGA1 --mode `xrandr | \
#  sed -nr '/VGA1 c/{N;s/.*\n\s+(\S+)\s+.*/\1/p}'`

# Autofs is slow.
sudo /bin/umount $HOME/phone_card
rm -rf ~/phone_card
mkdir -m700 ~/phone_card
c=0; until grep -q $HOME/phone_card /proc/mounts || {
	disk=`sudo /sbin/findfs LABEL=PHONE_CARD` \
	    && sudo /bin/mount -t vfat -o user,rw,fmask=0111,dmask=0000,\
codepage=866,utf8,noexec $disk ~/phone_card; }; do
	echo -e "10\n# Waiting for ~/phone_card to appear: $((c++)) sec" >$pipe
	sleep 1
	pgrep -af 'zenity --progress --percentage=0 --text=X preloading started!' \
		|| { NO_KEYS=t; break; }
done

[ -v NO_KEYS ] || {
	echo -e "20\n# Creating /tmp/decrypted" >$pipe
	# This directory will be a temporary storage for decrypted files.
	# /tmp shall be mounted as tmpfs.
	rm -rf /tmp/decrypted &>/dev/null
	mkdir -m 700 /tmp/decrypted

	echo -e "30\n# Copying GNUPG and SSH keys to tmpfs" >$pipe
	cp -R ~/phone_card/.gnupg /tmp/decrypted/
	cp -R ~/phone_card/.ssh /tmp/decrypted/
	chmod -R go-rwx /tmp/decrypted
}

echo -e "40\n# Setting keyboard" >$pipe
# Keyboard setting need to be set before pinentry windows will appear asking
#   for passphrases (this is not needed for SSH sessions)
[ -v DISPLAY ] && ~/.i3/set_keyboard.sh

[ -v NO_KEYS ] || {
	echo -e "50\n# Checking gpg-agent" >$pipe
	# This file’s only purpose is to be sourced in ~/.bashrc if SSH_CLIENT
	#   is set i.e. for remote logins via SSH. All shells running in currently
	#   started X session will be satisfied by exporting these variables
	#   right here in this file.
	touch $HOME/.gnupg/agent-info
	pgrep -u $UID gpg-agent || {
		echo -e "55\n# Starting gpg-agent" >$pipe
		gpg-agent --daemon \
			--enable-ssh-support --write-env-file $HOME/.gnupg/agent-info
	}
	# NB export. Output of write-env-file doesn’t produce that command.
	export `< $HOME/.gnupg/agent-info`
	export GPG_TTY=`tty`

	# echo -e "60\n# Loading SSH keys" >$pipe
	# Loading SSH keys.
	# After I found _very strange_ behaviour of gpg-agent I decided to refuse of
	#   using it in relation to keeping ssh keys. Even without the agent all
	#   authentications will still work as they should, if the keys are bound
	#   to appropriate hosts in ~/.ssh/config.
	# However, having passphrases in keys along with the need to use gpg-agent
	#   may bring some troubles. Mine keys don’t have passphrases.
	#
	#for ssh_key in `grep -l 'PRIVATE KEY' ~/.ssh/*`; do
	# W! Strange bug: after proper key fails to authenticate(!) due to
	#   error: RSA_public_decrypt failed: error:0407006A:lib(4):func(112):reason(106)
	#   dwarf_fortress_regions.zip ebug1: ssh_rsa_verify: signature incorrect
	# gpg-agent may try any other killsteam.sh ey.
	# ssh-add "$ssh_key" </dev/null
	#done
	#unset ssh_key

	echo -e "70\n# Decrypting user name" >$pipe
	eval export `gpg -qd ~/.env/private_data.sh.gpg 2>/dev/null | grep -E '^ME'`

	echo -e "80\n# Decrypting Box account information" >$pipe
	gpg -qd --output /tmp/decrypted/secrets.`date +%s` ~/.davfs2/secrets.gpg
	# http://box.com
	{ ping -c3 8.8.8.8 &>/dev/null && sudo /root/scripts/mount_box.sh $USER \
		&& export BOX_MOUNTED=t; } &
}

echo -e "90\n# Exporting custom ~/bin into PATH" >$pipe
# In order to have some applications that store data open for everyone
#   who can boot your PC, there are substitution scripts that decrypt data
#   from repository and delete them after application is closed.
export PATH="$HOME/bin:$PATH"

echo -e "91\n# Launching SCIM" >$pipe
LANG='en_US.utf-8' scim -d
export XMODIFIERS=@im=SCIM
export GTK_IM_MODULE=scim
export QT_IM_MODULE=scim

echo -e "92\n# Making symlinks for config files" >$pipe
ln -sf ~/.config/htop/htoprc.$HOSTNAME ~/.config/htop/htoprc

echo -e "93\n# Loading ~/.Xresources to Xorg" >$pipe
xrdb ~/.Xresources
echo -e "94\n# Helping X server to find localized Terminus" >$pipe
xset +fp /usr/share/fonts/terminus && xset fp rehash
echo -e "95\n# Disabling screensaver" >$pipe
xset s off
echo -e "96\n# Setting primary and slave outputs"
sed -r "s/PRIMARY_OUTPUT/$PRIMARY_OUTPUT/g" ~/.i3/config.template > ~/.i3/config
for ((i=1; i<n; i++)); do
	eval sed -ri "s/SLAVE_OUTPUT_$i/\$SLAVE_OUTPUT_$i/g" ~/.i3/config
	eval xrandr --output "\$SLAVE_OUTPUT_$i" --off
done

pkill -9 zenity
exec {pipe_fd}<&-
rm $pipe
