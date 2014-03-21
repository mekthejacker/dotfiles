#!/bin/bash

# autostart.sh
# This script is called from ~/.i3/config with ‘exec ~/.i3/autstart.sh’

# set -x
# exec &>~/i3autostartlog

# Check for two monitors and wacom.
# xsetwacom --set <ID> MapToOuput WxH+0+0
# W = 1st_screen_width/(2nd_screen_width/1st_screen_width)
# H = ———"———

# Temporarily disable pointer while setting layout
pointer_control() {
	[ -v pointer_devices ] || pointer_devices=$(xinput --list |\
	sed -nr '/Virtual\score.*pointer/ !s/.*id=([0-9]+)\s+\[slave\s+pointer.*/\1/p')
	for dev in $pointer_devices; do xinput --$1 $dev; done
}

# Wait for the last command sent to background to create a window
wait_for_program () {
	n=0
	while true; do
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

# Cleaning before new session.
# That’s strange, Emacs runned from autostart script hangs after session 
#   is closed, but is okay if it was started via /etc/init.d/emacs.user
killall emacs emacsclient
sudo /usr/bin/killall iftop

# Applications that need to be started before layout setting: urxvtd and tmux
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

# WIDTH and HEIGHT were set in the ~/.preinit.sh
case $HOSTNAME in
	fanetbook)
		hsetroot -fill ~/.env/wallpaper.png
		urxvtc -hold -name 'htop' -title "htop" -e htop
		xte "mousemove $(( WIDTH/2 ))  $(( HEIGHT/2 ))"
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
		pgrep -u $UID -f "^bash $HOME/scripts/wallpaper_setter.sh -B" \
			&& ~/scripts/wallpaper_setter.sh -w \
			|| { ~/scripts/wallpaper_setter.sh -B -0.3 \
			   -e "i3-nagbar -m \"%m\" -b Restart \"%a\"" \
			   -d /home/picts/watched & }
		urxvtc
		i3-msg split v
		urxvtc -hold -title 'htop' -e htop
 		# Now we have two terminals   ÷

		# Move cursor near to the center of the lower urxvtc with htop
 		xte "mousemove $(( WIDTH/2 ))  $(( 3*HEIGHT/4 ))"
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
			xte "mousemove $(( 9*WIDTH/16 )) $(( 3*HEIGHT/4 ))"
			xte 'mouseclick 1'
			i3-msg layout tabbed
		}

		# Moving cursor to the upper empty urxvtc and raise it to ≈5/6
		#   of the height
		xte "mousemove $(( WIDTH/2 ))  $(( HEIGHT/4 ))" 
		xte 'mouseclick 1'
		i3-msg resize grow height 30 px or 30 ppt
		i3-msg split h
		urxvtc
		# Now in upper hald we have two terminals, too ⋅|⋅
		# Splitting left upper urxvtc
		xte "mousemove $(( WIDTH/4 )) $(( HEIGHT/2 ))"
		xte 'mouseclick 1'
		i3-msg split h
		i3-msg layout tabbed
		urxvtc

		xte "mousemove $(( 3*WIDTH/4 )) $(( HEIGHT/2 ))"
		xte 'mouseclick 1'
		i3-msg split h
		i3-msg layout tabbed
		urxvtc
		urxvtc -hold -title tmux -e $tmux attach
 		xte "mousemove $(( 11*WIDTH/12 )) $(( HEIGHT/2 ))"
 		xte 'mouseclick 1'

		# This is for calling via hotkey in ~/.i3/config to test without
		#   restarting WM.
		[ "$1" = stop_after_main_workspace ] && {
			pointer_control enable
			exit 0
		}

		startup_apps=("emacs --daemon" firefox pidgin "emacsclient -c -display $DISPLAY")
		;;
esac
pointer_control enable

# Common apps: thunar and mpd
pgrep -u $UID thunar >/dev/null || { (nohup thunar) & }

until mpc &>/dev/null; do
	sleep 1
done
pgrep -u $UID mpdscribble >/dev/null || \
	mpdscribble --conf ~/.mpd/mpdscribble.conf
pgrep -u $UID ncmpcpp >/dev/null || urxvtc -name ncmpcpp -e ncmpcpp

for app in "${startup_apps[@]}"; do
	# { … & } becasue otherwise ‘&’ will fork to background the whole string
	#   including subshell created by the left part of ‘||’ statement.
	# (nohup $app) actuallyy needed only for emacs as daemon
	pgrep -u $UID -f "^$app\>" >/dev/null || { (nohup $app) & }
done
