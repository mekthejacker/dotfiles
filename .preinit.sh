#should be sourced

# preinit.sh
# This script is intended to be a common part of ~/.xinitrc and ~/.xsession.
# It starts deamons needed to be started before the window manager.
# ~/.bashrc runs this script for ssh clients.

# Getting screen dimensions.
# This assumes the first screen listed is the main in use.
read WIDTH HEIGHT  <<< `xrandr | \
	sed -nr 's/^\s+([0-9]+)x([0-9]+).*\*.*/\1\n\2/p;T;Q1' && echo -e '800\n600'`
export WIDTH HEIGHT

# Attempt to set multimonitor
#xrandr --output VGA1 --mode `xrandr | \
#  sed -nr '/VGA1 c/{N;s/.*\n\s+(\S+)\s+.*/\1/p}'`

#set -x 
#exec &>~/preinitlog
#date

# This directory will be a temporary storage for decrypted files.
# /tmp shall be mounted as tmpfs.
rm -rf /tmp/decrypted &>/dev/null 
mkdir -m 700 /tmp/decrypted
c=10; until touch ~/phone_card/touchme; do
	zenity --info --text="Looking for keys… $c" &
	sleep 1 && killall zenity
	[ $((c--)) -eq 0 ] && {
		zenity --question \
			--text="No keys were found." \
			--ok-label="Retry" \
			--cancel-label="Start w/o keys" && c=10 || break
	}
done
cp -R ~/phone_card/.gnupg /tmp/decrypted/
cp -R ~/phone_card/.ssh /tmp/decrypted/
chmod -R go-rwx /tmp/decrypted

# Keyboard setting need to be set before pinentry windows will appear asking
#   for passphrases.
[ -v DISPLAY ] && ~/.i3/set_keyboard.sh 

# This file’s only purpose is to be sourced in ~/.bashrc if SSH_CLIENT is set,
#   i.e. for remote logins via SSH. All shells running in currently started
#   X session will be satisfied by exporting these variables right here 
#   in this file.
touch $HOME/.gnupg/agent-info
pgrep -u $UID gpg-agent || gpg-agent --daemon \
	--enable-ssh-support --write-env-file $HOME/.gnupg/agent-info
# NB export. Output of write-env-file doesn’t produce that command.
export `< $HOME/.gnupg/agent-info`
export GPG_TTY=`tty`

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
	#   debug1: ssh_rsa_verify: signature incorrect
	# gpg-agent may try any other key.
	# ssh-add "$ssh_key" </dev/null
#done
#unset ssh_key

eval export `gpg -qd ~/.env/private_data.sh.gpg 2>/dev/null | grep -E '^ME'`

gpg -qd --output /tmp/decrypted/secrets.`date +%s` ~/.davfs2/secrets.gpg
# http://box.com
{ ping -c3 8.8.8.8 &>/dev/null && sudo /root/scripts/mount_box.sh $USER \
	&& BOX_MOUNTED=t; } &


# In order to have some applications that store data open for everyone
#   who can boot your PC, there are substitution scripts that decrypt data
#   from repository and delete them after application is closed.
PATH="$HOME/bin:$PATH" 

LANG='en_US.utf-8' scim -d
export XMODIFIERS=@im=SCIM
export GTK_IM_MODULE=scim
export QT_IM_MODULE=scim

ln -sf ~/.config/htop/htoprc.$HOSTNAME ~/.config/htop/htoprc 

xrdb ~/.Xresources
# This is needed for X server to find localized part of Terminus font
xset +fp /usr/share/fonts/terminus && xset fp rehash
xset s off # disable screensaver
