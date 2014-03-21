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

LANG='en_US.utf-8' scim -d
export XMODIFIERS=@im=SCIM
export GTK_IM_MODULE=scim
export QT_IM_MODULE=scim

ln -sf ~/.config/htop/htoprc.$HOSTNAME ~/.config/htop/htoprc 

xrdb ~/.Xresources
# This is needed for X server to find localized part of Terminus font
xset +fp /usr/share/fonts/terminus && xset fp rehash
xset s off # disable screensaver
