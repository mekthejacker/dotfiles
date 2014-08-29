#!/bin/bash

# autostart.sh
# This script is called from ~/.i3/config with ‘exec ~/.i3/autstart.sh’

# set -x
# exec &>~/autostart.log

# Check for two monitors and wacom.
# xsetwacom --set <ID> MapToOuput WxH+0+0
# W = 1st_screen_width/(2nd_screen_width/1st_screen_width)
# H = ———"———

# Temporarily disable pointer while setting layout
pointer_control() {
	[ -v pointer_devices ] || pointer_devices=$(xinput --list \
		| sed -nr '/Virtual\score.*pointer/ !s/.*id=([0-9]+)\s+\[slave\s+pointer.*/\1/p')
	for dev in $pointer_devices; do xinput --$1 $dev; done
}

# Wait for the last command sent to background to create a window
wait_for_program () {
	local c=0; until [ $((++c)) -eq 15 ]; do
		xdotool search --onlyvisible --pid $! 2>/dev/null && break
		sleep 1
    done
	[ $c -eq 15 ] && i3-nagbar -m "Error on executing $0 script"
}

# Cleaning before new session.
# This is a well-known bug, emacsclient cannot connect to the daemon after X
#   have been restarted.
# Though, it works in a gentoo-way: via init scripts, 
#   like ‘/etc/init.d/emacs.username’.
# This gives us the last solution: to run it from tmux session, if we want 
#   to keep our configuration away from messing with system configuration, 
#   be it init scripts or whatever.
#   pkill -9 emacsclient
pkill -9 emacsclient

# Because we can close terminals holding root's iftops, but not them.
sudo /usr/bin/killall iftop

# Applications that need to be started before layout setting: 
#   urxvtd, tmux and emacs daemon in tmux.
# Substitute line: 
	# neww -n wa-a "{ (nohup emacs --daemon &>/dev/null) & } && /bin/bash " \; \
#   is useless since emacsclient running from here still fails to connect to
#   Emacs because it tries to do that while applications are messing around
#   with gpg keys, which causes a delay before i3 windows actually appear.
#   This was checked on the other machine with the same configuration except
#     the key management: all works fine there.
#   I fucking hate that goddamn piece of crap, but too lazy to set up vim.
# Yes, it seems that the only way to have that shit working between X restarts
#   and independently of X is to run daemon via init scripts >_>
pgrep urxvtd || urxvtd -q -o -f
tmux="tmux -u -f $HOME/.tmux/config -S $HOME/.tmux/socket"
pgrep -u $UID -f '^tmux.*$' &>/dev/null || $tmux \
	new -d su \; \
	set remain-on-exit on \; \
	neww su \; \
	set remain-on-exit on \; \
	select-window -t 0:1
# Another user termianl in tmux
#	neww -n wa-a \; \
#	set remain-on-exit on \; \

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
			|| { ~/scripts/wallpaper_setter.sh -B -0.3 \
			   -e "i3-nagbar -m \"%m\" -b Restart \"%a\"" \
			   -d /home/picts/watched & }
		# Urxvtc windows must appear after wallpaper is set, due to their
		#   fake transparency.
		~/scripts/wallpaper_setter.sh -w

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

		# Oh, fine, we can just run emacsclient with no argument to -a option
		#   and it will start emacs daemon and will connect to it.
		# But if daemon runs from here, it will fail after X restart ;_;
		# Crapissimo: neither -a, nor -a '', -a "", -a $'\000' do not work.
		startup_apps=(firefox pidgin) #  "emacsclient --alternate-editor= -c -display $DISPLAY")
		;;
esac
pointer_control enable

#set -x
# Some configs decrypted at ~/bin/run_app.sh
for app in mpd thunar "${startup_apps[@]}"; do
	# { … & } becasue otherwise ‘&’ will fork to background the whole string
	#   including subshell created by the left part of ‘||’ statement.
	# (nohup $app) actuallyy needed only for emacs as daemon
	# Preventing apps that persist between sessions to be runned again
	pgrep -u $UID -f "^$app\>" >/dev/null || { (nohup $app) & }
done

until mpc &>/dev/null; do  sleep 1;  done
pgrep -xu $UID mpdscribble || mpdscribble
pgrep -xu $UID ncmpcpp >/dev/null || urxvtc -name ncmpcpp -e ncmpcpp
