#!/bin/bash

## This script is called from ~/.i3/config with
##     exec ~/.i3/autstart.sh
~/.i3/set_keyboard.sh

## Load my ssh identities
[ "$1" = stop_after_main_workspace ] || . ~/scripts/ssh-load.sh

# Check for two monitors and wacom.
# xsetwacom --set <ID> MapToOuput WxH+0+0
# W = 1st_screen_width/(2nd_screen_width/1st_screen_width)
# H = ———"———

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

sudo /usr/bin/killall iftop
pgrep urxvtd || urxvtd -q -o -f
tmux="tmux -u -f $HOME/.tmux/config -S $HOME/.tmux/socket"
pgrep -u $UID -f '^tmux.*$' &>/dev/null || $tmux \
	new -dn root su \; \
	set remain-on-exit on \; \
	neww -n root2 su \; \
	set remain-on-exit on \; \
	neww -n wa-a \; \
	set remain-on-exit on \; \
	select-window -t root
pointer_control disable

# Getting screen dimensions.
# This assumes the first screen listed is the main in use.
read width height  <<< `xrandr | \
	sed -nr 's/^\s+([0-9]+)x([0-9]+).*\*.*/\1\n\2/p;T;Q0'`

common_startup_apps=("thunar" "mpd")

case $HOSTNAME in
	fanetbook)
		hsetroot -fill ~/.env/wallpaper.png
		urxvtc -hold -name 'htop' -title "htop" -e htop
		xte "mousemove $(( width/2 ))  $(( height/2 ))" 
		xte 'mouseclick 1'
		i3-msg layout tabbed
		
		for iface_config in `ls ~/.iftop/$HOSTNAME.*`; do
			urxvtc -hold -title ${iface_config##*.} \
				-e sudo /usr/sbin/iftop -c "$iface_config"
		done
		urxvtc
		urxvtc
		urxvtc -hold -title tmux -e $tmux attach \; find-window -N root
		
		startup_apps=()
		;;
	*)
		pgrep -u $UID -f 'wallpaper_setter.sh' \
			&& ~/scripts/wallpaper_setter.sh -w \
			|| { ~/scripts/wallpaper_setter.sh -B -0.3 \
			   -e "i3-nagbar -m \"%m\" -b Restart \"%a\"" \
			   -d /home/picts/watched & }
		urxvtc 
		i3-msg split v
		urxvtc -hold -title 'htop' -e htop
 		# Now we have two terminals   ÷

		# Move cursor near to the center of the lower urxvtc with htop
 		xte "mousemove $(( width/2 ))  $(( 3*height/4 ))"
		# Focus it
 		xte 'mouseclick 1'
 		i3-msg split h
		iface_configs=(`ls ~/.iftop/$HOSTNAME.*`)
		[ ${#iface_configs} -gt 1 ] && iftops_need_their_own_container=t
		for ((i=0; i<${#iface_configs[@]}; i++)); do
			urxvtc -hold -title ${iface_configs[$i]##*.} \
				-e sudo /usr/sbin/iftop -c "${iface_configs[$i]}"
			[ $i -eq 0 ] && [ -v iftops_need_their_own_container ] && \
				i3-msg split h
		done
		[ -v iftops_need_their_own_container ] && {
			xte "mousemove $(( 9*width/16 )) $(( 3*height/4 ))"
			xte 'mouseclick 1'
			i3-msg layout tabbed			
		}

		# Moving cursor to the upper empty urxvtc and raise it to ≈5/6 
		#   of the height
		xte "mousemove $(( width/2 ))  $(( height/4 ))" 
		xte 'mouseclick 1'
		i3-msg resize grow height 30 px or 30 ppt
		i3-msg split h
		urxvtc
		# Now in upper hald we have two terminals, too ⋅|⋅
		# Splitting left upper urxvtc
		xte "mousemove $(( width/4 )) $(( height/2 ))"
		xte 'mouseclick 1'
		i3-msg split h
		i3-msg layout tabbed
		urxvtc

		xte "mousemove $(( 3*width/4 )) $(( height/2 ))"
		xte 'mouseclick 1'
		i3-msg split h
		i3-msg layout tabbed
		urxvtc
		urxvtc -hold -title tmux -e $tmux attach
 		xte "mousemove $(( 11*width/12 )) $(( height/2 ))"
 		xte 'mouseclick 1'

		# This is for calling via hotkey in ~/.i3/config to test without
		#   restarting WM.
		[ "$1" = stop_after_main_workspace ] && {
			pointer_control enable
			exit 0
		}

		startup_apps=("emacs --daemon" firefox pidgin "emacsclient -c")
		;;
esac
pointer_control enable

killall -HUP emacsclient
for app in "${common_startup_apps[@]}" "${startup_apps[@]}"; do
	# { $app & } becasue otherwise ‘&’ will fork to background the whole string
	#   including subshell created by the left part of ‘||’ statement.
	pgrep -u $UID -f "\<$app\>" >/dev/null || { $app & }
done

until mpc &>/dev/null; do
	sleep 1
done
pgrep -u $UID mpdscribble >/dev/null || \
	mpdscribble --conf ~/.mpd/mpdscribble.conf
pgrep -u $UID ncmpcpp >/dev/null || urxvtc -name ncmpcpp -e ncmpcpp
