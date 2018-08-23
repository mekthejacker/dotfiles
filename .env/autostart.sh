#!/bin/bash

# autostart.sh
# This script is called from ~/.env/config with ‘exec ~/.env/autstart.sh’

[ "${ENV_DEBUG/*a*/}" ] || {
	exec &>/tmp/envlogs/autostart
	date
	set -x
}

xrandr | grep -q 'VGA1 connected' \
	&& xrandr --output VGA1 --mode 1920x1080 --primary --same-as LVDS1 \
	          --output LVDS1 --mode 1366x768 --fb 1920x1080 --panning 1920x1080

~/bin/set_wallpaper.sh

# Temporarily disable pointer while setting layout
# $1 == <enable|disable>
pointer_control() {
	[ -v pointer_devices ] || pointer_devices=$(xinput --list \
		| sed -nr '/Virtual\score.*pointer/ !s/.*id=([0-9]+)\s+\[slave\s+pointer.*/\1/p')
	for dev in $pointer_devices; do xinput --$1 $dev; done
}

# Wait for the last command sent to background to create a window
wait_for_program () {
	#
	# You should use
	#   xdotool search --sync --onlyvisible --class "some wm class here"
	# instead
	#
	local c=0; until [ $((++c)) -eq 15 ]; do
		xdotool search --onlyvisible --pid $! 2>/dev/null && break
		sleep 1
    done
	[ $c -eq 15 ] && i3-nagbar -m "Error on executing $0 script"
}

# Cleaning before new session.

# Because we can close the terminal that holds root’s bwmon, but not the bwmon itself.
sudo /usr/bin/killall bwmon  # also cbm

[ "$1" = stop_after_main_workspace ] && {
	# On restarting the workspace (when something fucked up keyboard in urxvt again)
	i3-msg "[workspace=0:Main] kill"
	pkill -9 -f urxvt
}


# Applications that need to be started before layout setting:
#   urxvtd, tmux and emacs daemon in tmux.
# Substitute line:
	# neww -n wa-a "{ (nohup emacs --daemon &>/dev/null) & } && /bin/bash " \; \            ## nohup requires also requires ‘</dev/null’ to not hang
#   is useless since emacsclient running from here still fails to connect to
#   Emacs because it tries to do that while applications are messing around
#   with gpg keys, which causes a delay before i3 windows actually appear.
#   This was checked on the other machine with the same configuration except
#     the key management: all works fine there.
#   I fucking hate that goddamn piece of crap, but too lazy to set up vim.
# Yes, it seems that the only way to have that shit working between X restarts
#   and independently of X is to run daemon via init scripts >_>
pgrep -u $UID urxvtd || urxvtd -q -o -f
tmux="tmux -u -f $HOME/.tmux/config -L $USER"
if pgrep -u $UID -f '^tmux.*$' &>/dev/null; then
	[ "$1" = stop_after_main_workspace ] || {
		:
		#for pane in `$tmux list-windows -t0 | sed -r 's/^([0-9]+):.*/\1/g'`; do
		#	$tmux send -t 0:$pane C-c
		#	$tmux send -t 0:$pane export\ DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" ENTER
		#	$tmux send -t 0:$pane export\ DISPLAY="$DISPLAY" ENTER
		#	$tmux send -t 0:$pane C-c
		#done
	}
else
	$tmux new-session -d -s $USER su
	$tmux set remain-on-exit on
	$tmux neww su
	$tmux set remain-on-exit on
	# $tmux new-session -d -s bots "cd ~/bin/animepostingbot/; ./animepostingbot.sh"
	# $tmux set remain-on-exit on
	$tmux switch-client -t $USER
	$tmux select-window -t $USER:^
fi

[ "$DISPLAY" = ":108" ] && exit 0  # stop here if it’s a Xephyr window

pointer_control disable

startup_apps=(
	mpd
	"firefox --profile $HOME/.ff"
	thunar
	pidgin
)
# WIDTH and HEIGHT were set in the ~/.preload.sh
case $HOSTNAME in
	home)
		startup_apps+=(gimp subl3 geeqie riot-web)
		;;
	paskapuukko)
		# startup_apps+=(skype)  # how the fuck does skype switch the workspace by itself?!
		;;
esac

#pgrep -u $UID -f "^bash $HOME/bin/wallpaper_setter/wallpaper_setter.sh -S" \
#	|| { ~/bin/wallpaper_setter/wallpaper_setter.sh -S -B -0.3 -d /home/picts/screens & }
# Urxvtc windows must appear after wallpaper is set, due to their
#   fake transparency.
#~/bin/wallpaper_setter/wallpaper_setter.sh -w &

urxvtc
# ┌───────┐
# │ urxvt │
# │       │
# └───────┘
i3-msg split v
urxvtc -hold -title 'htop' -e htop
# ╔═══════╗
# ║ urxvt ║
# ╟───────╢
# ║ htop  ║
# ╚═══════╝
# Move cursor near the center of the lower urxvtc with htop
xte "mousemove $(( WIDTH/2 ))  $(( 3*HEIGHT/4 ))"
xte 'mouseclick 1'  # …and focus it.
sleep .3
i3-msg split h
# ╔═════╗ # ╔═══════╗
# ║     ║ # ║       ║
# ╟─────╢ # ╠━━━┯━━━╣
# ║  ⋅  ║ # ║   │   ║
# ╚═════╝ # ╚═══╧═══╝

urxvtc -hold -title 'Interface bandwidths' -e sudo /usr/bin/bwmon

# ╔═════════════════╗
# ║      urxvt      ║
# ╠━━━━━━━━┳━━━━━━━━╣
# ║  htop  ┃  bwmon ║
# ╚════════╩════════╝

xte "mousemove $(( WIDTH/2 ))  $(( HEIGHT/4 ))"
xte 'mouseclick 1'
# raise upper empty urxvtc up to ≈5/6 of the height
i3-msg resize grow height 30 px or 30 ppt
sleep .3
i3-msg split h
case $HOSTNAME in
	home)
		transmission_pid=$(pgrep -u $USER -f transmission-gtk)
		if [ -e "/proc/${transmission_pid:-nosuchfile}" ]; then
			transmission-gtk
		else
			(nohup transmission-gtk </dev/null &>/dev/null) &
			transmission_pid=$!
		fi
		xdotool search --sync --onlyvisible --pid "$transmission_pid"
		;;
	*)
		urxvtc -hold -title tmux -e /bin/bash -c "$tmux attach; bash"
		;;
esac
# ╔═════════════════╗ # ╔════════╤════════╗
# ║        ⋅        ║ # ║        │        ║
# ║                 ║ # ║  urxvt │ tr-gtk ║
# ║                 ║ # ║        │        ║
# ╠━━━━━━━━┳━━━━━━━━╣ # ║        │        ║
# ║        ┃        ║ # ║        │        ║
# ║        ┃        ║ # ╠━━━━━━━━╈━━━━━━━━╣
# ║        ┃        ║ # ║  htop  ┃ bwmon  ║
# ╚════════╩════════╝ # ╚════════╩════════╝

xte "mousemove $(( WIDTH/4 )) $(( HEIGHT/2 ))"
xte 'mouseclick 1'
sleep .3
i3-msg split h
i3-msg layout tabbed
urxvtc
urxvtc
# ╔════════╤════════╗ # ╔════════╦════════╗
# ║        │        ║ # ║––+––+––┃        ║
# ║        │        ║ # ║ur ur ur┃ tr-gtk ║
# ║   ⋅    │        ║ # ║        ┃        ║
# ║        │        ║ # ║        ┃        ║
# ║        │        ║ # ║        ┃        ║
# ╠━━━━━━━━╈━━━━━━━━╣ # ╠━━━━━━━━╋━━━━━━━━╣
# ║        ┃        ║ # ║  htop  ┃ bwmon  ║
# ╚════════╩════════╝ # ╚════════╩════════╝

xte "mousemove $(( 3*WIDTH/4 )) $(( HEIGHT/2 ))"
xte 'mouseclick 1'
sleep .3
i3-msg split v
i3-msg layout tabbed
[ "$HOSTNAME" = home ] && {
	urxvtc -hold -title tmux -e /bin/bash -c "$tmux attach; bash"
}
#urxvtc
# ╔════════╦════════╗ # ╔════════╦════════╗
# ║––+––+––┃        ║ # ║––+––+––┃–––+––––║
# ║        ┃        ║ # ║ur ur ur┃tmu tran║
# ║        ┃   ⋅    ║ # ║        ┃        ║
# ║        ┃        ║ # ║        ┃--+--+  ║ ← tmux panes
# ║        ┃        ║ # ║        ┃        ║
# ╠━━━━━━━━╋━━━━━━━━╣ # ╠━━━━━━━━╋━━━━━━━━╣
# ║        ┃        ║ # ║  htop  ┃ bwmon  ║
# ╚════════╩════════╝ # ╚════════╩════════╝

#  Focus the window, just in case
xte "mousemove $(( 11*WIDTH/12 )) $(( HEIGHT/2 ))"
xte 'mouseclick 1'

i3-msg move left

pointer_control enable

# This is to check whether script is called via hotkey in ~/.env/config.
[ "$1" = stop_after_main_workspace ] && exit 0

# Some configs decrypted at ~/bin/run_app.sh
for app in "${startup_apps[@]}"; do
	# Switch to its workspace to take off urgency hint
	#	workspace="`sed -nr "s/^bindcode.*exec.*i3-msg\s+workspace\s+([0-9]*:?\S+)\s+.*pgrep\s+-u\s+\\\\\\$UID\s+$app.*\\\$/\1/p" ~/.env/config`"

	# { … & } becasue otherwise ‘&’ will fork to background the whole string
	#   including subshell created by the left part of ‘||’ statement.
	# (nohup $app) actually needed only for emacs as daemon
	# Preventing apps that persist between sessions to be runned again
	pgrep -u $UID -f "$app\>" >/dev/null || { (nohup $app </dev/null &>/dev/null) & }
done

c=0; until mpc &>/dev/null; do
	sleep 1;
	[ $((c++)) -gt 60 ] && {
		echo 'Couldn’t wait more for mpd to give a response.' >&2
		NO_MPD=t
		break
	}
done
[ -v NO_MPD ] || {
	pgrep -xu $UID mpdscribble || mpdscribble
	pgrep -xu $UID ncmpcpp >/dev/null || urxvtc -name ncmpcpp -e ncmpcpp
}

 # Take off urgent hints
#
sleep 5
for win in $(wmctrl -l | awk -F' ' '{print $1}'); do
	wmctrl -i -r $win -b remove,demands_attention
done

 # Run C-S-t in Sublime to switch on max payne
#
#



#crontab -l | grep -qF 'wallpaper_setter.sh' || {
#	echo '*/10 * * * * ~/bin/wallpaper_setter/wallpaper_setter.sh -qn' \
#		>>/var/spool/cron/crontabs/$ME \
#		|| notify-send -t 4000 "${0##*/}" "Couldn’t set crontab file."
#}

# For the automation of setting up sindows on other workspaces,
#   xdotool windowactivate #WID
# should be helpful.
#
#WID=`xdotool search --name "Mozilla Firefox" | head -1`
# >> No, use xdotool’s WINDOW STACK
#xdotool windowactivate $WID
#xdotool key F5
