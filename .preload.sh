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

 # PRELOAD_SH is set on the time of running preload.sh, this file.
#  This is for the helper files to see this variable in the environment
#    and understand, that we’re on the startup stage. The variable is
#    unexported at the end of this file.
#  PRELOAD_SH affects files only in ~/.env and ~/bin.
#
export PRELOAD_SH=t \
       WIDTH=800 HEIGHT=600 \
       DPI=`xdpyinfo | sed -rn '/screen #0/ {n;n; s/\s*resolution:\s*([0-9]+)x.*/\1/p}'` \
       PRIMARY_OUTPUT \
	   PATH \
	   XMODIFIERS \
	   GTK_IM_MODULE QT_IM_MODULE \
	   ME

# Starting Xdialog progress window to be aware,
# when lags come from if they appear.
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
~/bin/set_wallpaper.sh
Xdialog --gauge 'X preloading started!' 630x100 <$pipe &

# I. Initial preparations
push_the_bar "Cleaning `du -hsx ~/.local/share/gvfs-metadata | cut -f1` in ~/…/gvfs-metadata"
rm -rf ~/.local/share/gvfs-metadata
push_the_bar "Cleaning `du -hsx ~/.maildir/new | cut -f1` in ~/.maildir/new"
find ~/.maildir/new -type f -print0 | xargs -0 -I {} rm -f {}

push_the_bar "Cleaning /tmp"
find  /tmp -type d \( -iname ".com.vivaldi*" -o -iname ".org.chromium*" -o -iname "i3-$USER*" -o -iname "clipboardcache*" \) -print0 | xargs -0 -I {} rm -f {}
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
# Another way of getting DPI.
#xdpyinfo | sed -rn '/screen #0/ {n;n; s/\s*resolution:\s*([0-9]+)x.*/\1/p}'
[ ${#OUTPUTS} -gt 0 ] && {
	push_the_bar 'Making sure that we operate on the first monitor'
	xte "mousemove $(( WIDTH/2 ))  $(( HEIGHT/2 ))"
	xte 'mouseclick 1'
}
sed -ri "s/\s*Xft.dpi:.*/Xft.dpi: $DPI/" ~/.Xresources


# II. Setting account information
push_the_bar 'Loading keyboard settings' 33
# Keyboard setting need to be set before pinentry windows will appear asking
#   for passphrases (this is not needed for SSH sessions)
[ -v DISPLAY ] && ~/.env/set_keyboard.sh

eval `grep -E '^ME=' ~/.env/private_data.sh`  # see export in the beginning

# III. Setting the rest of X environment.

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
push_the_bar 'Helping X server to find localised Terminus'
xset +fp /usr/share/fonts/terminus && xset fp rehash
push_the_bar 'Disabling screensaver'
xset s off
push_the_bar 'Setting standby and off time'
# Go to standby after 3 hours and off nine minutes later
xset dpms $((60*60*3)) 0 $((60*63*3))
xdg-settings  set default-web-browser  firefox.desktop

echo "101" >$pipe
exec {pipe_fd}<&-
rm $pipe
pkill -9 -f Xdialog
export -n PRELOAD_SH
