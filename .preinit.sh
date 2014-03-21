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
