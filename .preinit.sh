#xrandr --output VGA1 --mode `xrandr | \
#  sed -nr '/VGA1 c/{N;s/.*\n\s+(\S+)\s+.*/\1/p}'`

LANG='en_US.utf-8' scim -d
export XMODIFIERS=@im=SCIM
export GTK_IM_MODULE=scim
export QT_IM_MODULE=scim

cat ~/.mpd/mpd.conf.common > ~/.mpd/mpd.conf
[ -e ~/.mpd/mpd.conf.$HOSTNAME ] && cat ~/.mpd/mpd.conf.$HOSTNAME \
  >> ~/.mpd/mpd.conf

ln -sf ~/.config/htop/htoprc.$HOSTNAME ~/.config/htop/htoprc 

xrdb ~/.Xresources
xset +fp /usr/share/fonts/terminus && xset fp rehash
