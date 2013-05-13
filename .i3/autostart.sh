#!/bin/bash

## This script is called from ~/.i3/config with
##     exec ~/.i3/autstart.sh

~/.i3/set_keyboard.sh

## i3 cannot set wallpaper by itself
hsetroot -fill ~/.env/wallpaper.png

## Load my ssh identities
. ~/scripts/ssh-load.sh

pointer_control() {
	[ -v pointer_devices ] || pointer_devices=$(xinput --list |\
	sed -nr '/Virtual\score.*pointer/ !s/.*id=([0-9]+)\s+\[slave\s+pointer.*/\1/p')
	for dev in $pointer_devices; do xinput --$1 $dev; done
}

wait_for_program () {
	n=0
	while true; do
		# Waiting for the last sent to background command create a window
		if xdotool search --onlyvisible --pid $!; then
			break
		else
			# 20 seconds timeout
			if [ $((n++)) -eq 20 ]; then
				i3-nagbar -m "Error on executing $0 script"
				break
			else
				sleep 1
			fi
		fi
    done
}

urxvtd -q -o -f
pointer_control disable
case $HOSTNAME in
	fanetbook)
		urxvtc -hold -name 'htop' -title "htop" -e htop
		urxvtc -hold -name 'Das Terminal'
		urxvtc -hold -name 'Das zweite Terminal'

		# Getting screen dimensions.
		# This assumes the first screen listed is the main in use.
		read width height  <<< `xrandr | \
		  sed -nr 's/^\s+([0-9]+)x([0-9]+).*\*.*/\1\n\2/p;T;Q0'`

		xte "mousemove $(( $width/2 ))  36" 
		xte 'mouseclick 1'
		i3-msg layout tabbed

		startup_apps="thunar mpd"
		pgrep mpdscribble >/dev/null || \
			mpdscribble --conf ~/.mpd/mpdscribble.conf
		pgrep ncmpcpp >/dev/null || urxvtc -name ncmpcpp -e ncmpcpp
		;;
	*)
		urxvtc -hold -name 'Das Terminal'
		urxvtc -hold -name 'Das zweite Terminal'
		# Now we have two terminals |_|_|

		# Getting screen dimensions.
		# This assumes the first screen listed is the main in use.
		read width height  <<< `xrandr | \
		  sed -nr 's/^\s+([0-9]+)x([0-9]+).*\*.*/\1\n\2/p;T;Q0'`
		xte "mousemove $(( $width/4 ))  $(( $height/2 ))"
		# Now, if focus follows mouse as it is by default in i3, cursor points
		#   at the center of left terminal and focused it.
		i3-msg split h
		gnome-system-monitor &
		wait_for_program
		i3-msg layout tabbed
		i3-msg move left
		# Assume that height of the bar is about 25px, 
		#   and it is placed at the top.
		xte "mousemove $(( 3*$width/8 ))  36" 
		xte 'mouseclick 1'
		i3-msg split v
		urxvtc -hold -name 'htop' -title "htop" -e htop

		xte "mousemove $(( $width/4 ))  $(( $height/4 ))" 
		xte 'mouseclick 1'
		i3-msg focus child
		i3-msg resize grow height 20 px or 20 ppt

		xte "mousemove $(( 7*$width/8 )) $(( $height/2 ))"
		i3-msg split h
		urxvtc -hold -name 'Das Root Terminal'
		urxvtc
		xte 'mouseclick 1' 
		xte 'str su' 
		xte 'key Return' 
		i3-msg layout tabbed

		startup_apps="firefox thunar mpd pidgin"
		pgrep mpdscribble >/dev/null || \
			mpdscribble --conf ~/.mpd/mpdscribble.conf
		pgrep ncmpcpp >/dev/null || urxvtc -name ncmpcpp -e ncmpcpp
		killall -HUP emacsclient && emacsclient -c &
		;;
esac
pointer_control enable

for app in $startup_apps; do
	pgrep "\<$app\>" >/dev/null || (nohup $app & ) &
done
exit 0
