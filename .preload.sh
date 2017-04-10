#should be sourced

# .preload.sh
# This script is intended to be a common part of ~/.xinitrc and ~/.xsession.
# It starts deamons needed to be started before the window manager.
# ~/.bashrc runs this script for ssh clients.



[ "${ENV_DEBUG/*p*/}" ] || {
	exec &>/tmp/envlogs/preload
	date
	echo My UID is $UID # shouldn’t be 0.
	set -x
}

[ "$HOSTNAME" = paskapuukko ] && {
	xbacklight -set 55
}

echo $DISPLAY
export ME STARTUP=t WIDTH=800 HEIGHT=600 DPI=96 PRIMARY_OUTPUT \
	   PATH XMODIFIERS GTK_IM_MODULE QT_IM_MODULE

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
hsetroot -solid \#000000 -full "$HOME/.env/wallpapers/`ls -1tr ~/.env/wallpapers/ | tail -n1`" -brightness 0.13
Xdialog --gauge 'X preloading started!' 630x100 <$pipe &

# I. Initial preparations
push_the_bar "Cleaning `du -hsx ~/.local/share/gvfs-metadata | cut -f1` in ~/…/gvfs-metadata"
rm -rf ~/.local/share/gvfs-metadata
push_the_bar "Cleaning `du -hsx ~/.maildir/new | cut -f1` in ~/.maildir/new"
find ~/.maildir/new -type f -print0 | xargs -0 -I {} rm -f {}
push_the_bar "Cleaning `du -hsx ~/.cache/thumbnails | cut -f1` in ~/.cache/thumbnails"
find  ~/.cache/thumbnails -type f -print0 | xargs -0 -I {} rm -f {}
push_the_bar "Cleaning `du -hsx ~/.thumbnails | cut -f1` in ~/.thumbnails"
find  ~/.thumbnails -type f -print0 | xargs -0 -I {} rm -f {}
push_the_bar 'Retrieving output information'
n=0; while read outp; do
	[ -v PRIMARY_OUTPUT ] && eval export SLAVE_OUTPUT_$((n++))=$outp \
		|| PRIMARY_OUTPUT=$outp
done < <(xrandr --screen 0 | sed -nr 's/^(\S+) connected.*/\1/p')

# case $HOSTNAME in
# 	home)
# # Integrated card
# 		PRIMARY_OUTPUT=VGA1
# 		SLAVE_OUTPUT_0=HDMI3
# # External card
# 		PRIMARY_OUTPUT=VGA1
# 		SLAVE_OUTPUT_0=HDMI3
# 		;;
# 	paskapuukko)
# 		xrandr | grep -q 'VGA1 connected' && {
# 			PRIMARY_OUTPUT=VGA1
# 			SLAVE_OUTPUT_0=LVDS1
# 		}||{
# 			PRIMARY_OUTPUT=LVDS1
# 			SLAVE_OUTPUT_0=VGA1
# 		}
# 		;;
# esac

export ${!SLAVE_OUTPUT_*}
# Disabling all other outputs except the main one BEFORE
#   gpg spawns pinentry window and autorun messes the workspace
#   with huge screen spread onto two monitors.
~/.env/update_config.sh

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


# II. Setting account information
push_the_bar 'Loading keyboard settings' 33
# Keyboard setting need to be set before pinentry windows will appear asking
#   for passphrases (this is not needed for SSH sessions)
[ -v DISPLAY ] && ~/.env/set_keyboard.sh

eval `grep -E '^ME=' ~/.env/private_data.sh`  # see export in the beginning

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
for config in ~/.config/htop/htoprc \
              ~/.config/geeqie/geeqierc.xml \
              ~/.config/geeqie/history \
              ~/.scim/config \
			  ; do
	ln -sf $config.$HOSTNAME $config
done

push_the_bar 'Loading ~/.Xresources to Xorg'
xrdb ~/.Xresources
push_the_bar 'Helping X server to find localized Terminus'
xset +fp /usr/share/fonts/terminus && xset fp rehash
push_the_bar 'Disabling screensaver'
xset s off
push_the_bar 'Setting standby and off time'
# Go to standby after 3 hours and off nine minutes later
xset dpms $((60*60*3)) 0 $((60*63*3))

echo "101" >$pipe
exec {pipe_fd}<&-
rm $pipe
pkill -9 -f Xdialog
export -n STARTUP
