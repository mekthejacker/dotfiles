#!/bin/bash

# autostart.sh
# This script is called from ~/.i3/config with ‘exec ~/.i3/autstart.sh’

[ "${ENV_DEBUG/*a*/}" ] || {
	exec &>/tmp/envlogs/autostart
	date
	set -x
}

xrandr | grep -q 'VGA1 connected' \
	&& xrandr --output VGA1 --mode 1920x1080 --primary --same-as LVDS1 \
	          --output LVDS1 --mode 1366x768 --fb 1920x1080 --panning 1920x1080


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
# This is a well-known bug, emacsclient cannot connect to the daemon after X
#   have been restarted.
# Though, it works in a gentoo-way: via init scripts,
#   like ‘/etc/init.d/emacs.username’.
# This gives us the last solution: to run it from tmux session, if we want
#   to keep our configuration away from messing with system configuration,
#   be it init scripts or whatever.
#   pkill -9 emacsclient
pkill -9 emacsclient

# Because we can close terminals holding root’s iftops, but not them.
sudo /usr/bin/killall iftop

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
tmux="tmux -u -f $HOME/.tmux/config -S $HOME/.tmux/socket"
if pgrep -u $UID -f '^tmux.*$' &>/dev/null; then
	[ "$1" = stop_after_main_workspace ] || {
		for pane in `$tmux list-windows -t0 | sed -r 's/^([0-9]+):.*/\1/g'`; do
			$tmux send -t 0:$pane C-c
			$tmux send -t 0:$pane export\ DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" ENTER
			$tmux send -t 0:$pane export\ DISPLAY="$DISPLAY" ENTER
			$tmux send -t 0:$pane C-c
		done
	}
else
	$tmux \
	new -d su \; \
	set remain-on-exit on \; \
	neww su \; \
	set remain-on-exit on \; \
	select-window -t 0:1
	# Another user termianl in tmux
	#  neww -n wa-a \; \
	#  set remain-on-exit on \; \
fi

[ "$DISPLAY" = ":108" ] && exit 0  # stop here if it’s a Xephyr window

pointer_control disable

startup_apps=(mpd "firefox --profile $HOME/.ff" thunar pidgin skype)
# WIDTH and HEIGHT were set in the ~/.preload.sh
case $HOSTNAME in
	home)
		startup_apps+=(gimp geeqie redshift)
		;;
	paskapuukko)
		# startup_apps+=(skype)  # how the fuck does skype switch the workspace by itself?!
		;;
esac

pgrep -u $UID -f "^bash $HOME/bin/wallpaper_setter/wallpaper_setter.sh -S" \
	|| { ~/bin/wallpaper_setter/wallpaper_setter.sh -S -B -0.3 -d /home/picts/screens & }
# Urxvtc windows must appear after wallpaper is set, due to their
#   fake transparency.
~/bin/wallpaper_setter/wallpaper_setter.sh -w &

urxvtc --title 'Todo list' -e watch -t -n15 cat -n ~/todo
# ┌────┐
# │    │
# │    │
# └────┘
i3-msg split v
urxvtc -hold -title 'htop' -e htop
# ╔════╗
# ║    ║
# ╟────╢
# ║    ║
# ╚════╝
# Move cursor near the center of the lower urxvtc with htop
xte "mousemove $(( WIDTH/2 ))  $(( 3*HEIGHT/4 ))"
xte 'mouseclick 1'  # …and focus it.

iface_configs=(`ls ~/.iftop/$HOSTNAME.*[^~]`)  # ls -B doesn’t work here.
[ ${#iface_configs} -gt 1 -a $WIDTH -ge 1600 ] && iftops_need_their_own_container=t

i3-msg split h
# ╔═════╗ # ╔═══════╗
# ║     ║ # ║       ║
# ╟─────╢ # ╠━━━┯━━━╣
# ║  ⋅  ║ # ║   │   ║  # htop | [iftop container]
# ╚═════╝ # ╚═══╧═══╝

for ((i=0; i<${#iface_configs[@]}; i++)); do
	urxvtc -hold -title ${iface_configs[i]##*.} \
		   -e sudo /usr/sbin/iftop -c "${iface_configs[i]}"
	[ $i -eq 0 -a -v iftops_need_their_own_container ] && \
		i3-msg split h
done
# ╔═════════════════╗
# ║                 ║
# ╠━━━━━━━━┳━━┯━━┯━━╣
# ║  htop  ┃  │  │  ║  (Possible variation if there are 3 iftop configs and WIDTH >= 1600)
# ╚════════╩══╧══╧══╝
# ╔═══════════════╗
# ║               ║
# ╠━━━┯━━━┯━━━┯━━━╣
# ║   │   │   │   ║  (Possible variation if there are 3 htop configs and WIDTH < 1600.
# ╚═══╧═══╧═══╧═══╝   htop and iftops are in the same container)
[ ${#iface_configs[@]} -gt 0 ] && {
	[ -v iftops_need_their_own_container ] && {
		# move to the first iftop window
		# ╔═════════════════╗ # ╔═════════════════╗
		# ║                 ║ # ║                 ║
		# ║                 ║ # ║                 ║
		# ╠━━━━━━━━┳━━┯━━┯━━╣ # ╠━━━━━━━━┳━━━━━━━━╣
		# ║        ┃⋅ │  │  ║ # ║        ┃––+––+––║  ← tabs
		# ║        ┃  │  │  ║ # ║        ┃        ║
		# ╚════════╩══╧══╧══╝ # ╚════════╩════════╝
		xte "mousemove $(( 9*WIDTH/16 )) $(( 3*HEIGHT/4 ))"
		:
	}||{
		# move to the htop window to make it active tab, or it will be some iftop window
		# ╔═══════════════╗ # ╔═══════════════╗
		# ║               ║ # ║               ║
		# ║               ║ # ║               ║
		# ╠━━━┯━━━┯━━━┯━━━╣ # ╠━━━━━━━━━━━━━━━╣
		# ║⋅  │   │   │   ║ # ║–––+–––+–––+–––║  ← tabs
		# ║   │   │   │   ║ # ║               ║
		# ╚═══╧═══╧═══╧═══╝ # ╚═══════════════╝
		xte "mousemove $(( 1*WIDTH/16 )) $(( 3*HEIGHT/4 ))"
	}
	xte 'mouseclick 1'
	i3-msg layout tabbed
}
xte "mousemove $(( WIDTH/2 ))  $(( HEIGHT/4 ))"
xte 'mouseclick 1'
# raise upper empty urxvtc up to ≈5/6 of the height
i3-msg resize grow height 30 px or 30 ppt
i3-msg split h
urxvtc -hold -title tmux -e $tmux attach
# ╔═════════════════╗ # ╔════════╤════════╗
# ║        ⋅        ║ # ║        │        ║
# ║                 ║ # ║        │        ║
# ║                 ║ # ║        │        ║
# ╠━━━━━━━━┳━━━━━━━━╣ # ║        │        ║
# ║        ┃––+––+––║ # ╠━━━━━━━━╈━━━━━━━━╣
# ║        ┃        ║ # ║        ┃––+––+––║
# ║        ┃        ║ # ║        ┃        ║
# ╚════════╩════════╝ # ╚════════╩════════╝
xte "mousemove $(( WIDTH/4 )) $(( HEIGHT/2 ))"
xte 'mouseclick 1'
i3-msg split h
i3-msg layout tabbed
urxvtc
urxvtc
# ╔════════╤════════╗ # ╔════════╦════════╗
# ║        │        ║ # ║––+––+––┃        ║
# ║        │        ║ # ║        ┃        ║
# ║   ⋅    │        ║ # ║        ┃        ║
# ║        │        ║ # ║        ┃        ║
# ╠━━━━━━━━╈━━━━━━━━╣ # ╠━━━━━━━━╋━━━━━━━━╣
# ║        ┃––+––+––║ # ║        ┃––+––+––║
# ║        ┃        ║ # ║        ┃        ║
# ╚════════╩════════╝ # ╚════════╩════════╝
xte "mousemove $(( 3*WIDTH/4 )) $(( HEIGHT/2 ))"
xte 'mouseclick 1'
i3-msg split v
i3-msg layout tabbed
#urxvtc
#urxvtc -hold -title tmux -e $tmux attach
xte "mousemove $(( 11*WIDTH/12 )) $(( HEIGHT/2 ))"
xte 'mouseclick 1'
# ╔════════╦════════╗ # ╔════════╦════════╗
# ║––+––+––┃        ║ # ║––+––+––┃––+––+––║
# ║        ┃        ║ # ║        ┃        ║
# ║        ┃   ⋅    ║ # ║        ┃        ║
# ║        ┃        ║ # ║        ┃--+--+  ║ ← tmux panes
# ╠━━━━━━━━╋━━━━━━━━╣ # ╠━━━━━━━━╋━━━━━━━━╣
# ║        ┃––+––+––║ # ║        ┃––+––+––║
# ║        ┃        ║ # ║        ┃        ║
# ╚════════╩════════╝ # ╚════════╩════════╝

pointer_control enable

# This is to check whether script is called via hotkey in ~/.i3/config.
[ "$1" = stop_after_main_workspace ] && exit 0

# Some configs decrypted at ~/bin/run_app.sh
for app in "${startup_apps[@]}"; do
	# Switch to its workspace to take off urgency hint
	#	workspace="`sed -nr "s/^bindcode.*exec.*i3-msg\s+workspace\s+([0-9]*:?\S+)\s+.*pgrep\s+-u\s+\\\\\\$UID\s+$app.*\\\$/\1/p" ~/.i3/config`"

	# { … & } becasue otherwise ‘&’ will fork to background the whole string
	#   including subshell created by the left part of ‘||’ statement.
	# (nohup $app) actually needed only for emacs as daemon
	# Preventing apps that persist between sessions to be runned again
	pgrep -u $UID -f "^$app\>" >/dev/null || { (nohup $app </dev/null &>/dev/null) & }
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

crontab -l | grep -qF 'wallpaper_setter.sh' || {
	echo '*/10 * * * * ~/bin/wallpaper_setter/wallpaper_setter.sh -qn' \
		>>/var/spool/cron/crontabs/$ME \
		|| notify-send -t 4000 "${0##*/}" "Couldn’t set crontab file."
}

# For the automation of setting up sindows on other workspaces,
#   xdotool windowactivate #WID
# should be helpful.
#
#WID=`xdotool search --name "Mozilla Firefox" | head -1`
# >> No, use xdotool’s WINDOW STACK
#xdotool windowactivate $WID
#xdotool key F5
