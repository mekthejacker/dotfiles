#!/usr/bin/env bash

# generate_json_for_i3bar.sh
# A replacement for i3status written in bash.

# Shebang here is just for you to check the JSON output in terminal for syntax
#   errors, not for running as executable in your i3 config,
#   where it should be SOURCED from.

[ "${ENV_DEBUG/*g*/}" ] || exec 2>/tmp/envlogs/genjson4i3bar

# I thought about typing interfunction variables in CAPS, but then
#   I realized that it would require CAPS almost everywhere, so there’s not
#   much need in it.

red='#ee1010'
yellow='#edd400'
green='#8ae234'
white='#ffffff'
orange='#e07a1f'
brown='#b16161'
blue='#729fcf'

# In caps typed those variables that must not be misunderstood as local.
#   They are important for interfunction communication, are used between runs
#   of same function, or can be changed within functions while affecting
#   the main algorithm.
TIMEOUT_STEP=0 # counts seconds till TIMEOUT_MAX
TIMEOUT_MAX=30 # the actual timeout is one second; TIMEOUT_MAX introduces
               # a period functions may rely on; functions have their own
               # local timeouts, ‘wait_time’ variable.
SEPARATOR_CHAR='·'  # U+00B7 https://en.wikipedia.org/wiki/Interpunct
GOOGLE_DNS='8.8.4.4'
PING_HOST="$GOOGLE_DNS"
ping_successful='Unknown' # preset for the first time

# module settings
ACTIVE_WINDOW_NAME_MAX_LENGTH=50
FREE_SPACE_MPOINTS='/home / /usr'
FREE_SPACE_YELLOW_POINT=5
FREE_SPACE_RED_POINT=1

# Decrypt Gmail authentication data
eval `gpg -qd ~/.env/private_data.sh.gpg 2>/dev/null \
      | grep -E '^GMAIL_(USERNAME|PASSWORD)'`

# 1. Let’s call each element of the status bar a ‘module’.
# 2. Then each module consists of a variable, which will contain related JSON
#    stuff and a function generating that JSON and puttin it into variable.
#    Functions are named after the variables, but have ‘get_’ prefix.
# 3. The ‘modules’ array defines the list of modules which will be used to stuff
#    the bar string; index number defines the priority of each module, i.e. will
#    it appear first and on the left (lower index) or last and on the right
#   (highest index).
modules=(
	# [0]=test
	[50]=active_window_name
	# Any element with a number that is a multiple of 100, becomes
	#   a separator. Separators are never shown if in the last 98
	#   elements there were no modules that gave any text, i.e. for [100]th
	#   module to appear as a separator, at least one of [1]..[99] should
	#   set a non-empty variable of same name.
	# Simply erase or comment a separator, if you don’t need it.
	[100]=
	[210]=mpd_state
	[220]=speakers_state
	[230]=mic_state
	[240]=internet_status
	[250]=gmail
	[300]=
	[350]=nice_date
)

case $HOSTNAME in
	fanetbook)
		modules[154]=xkb_layout
		modules[159]=battery_status
		;;
	home)
		modules[150]=free_space
		modules[200]=
		modules[255]=schedule
		;;
esac

#      modules=( … nice_date )                      ← name in the module list
#
#                 $nice_date                        ← variable that contains JSON data of the module
#
#              get_nice_date ()                     ← function that evaluates these data
#
#  bar='[ $module $nice_date $other_module … ] , '  ← data getting substituted in the complete
#                                                     portion of JSON for i3bar

# Tabulation and spaces in output of the script are just to have a nice view
#   while testing this script in a terminal and are not neccesary.

# DESCRIPTION:
#     Module for testing purposes.
get_test() {
	# https://developer.gnome.org/pango/stable/PangoMarkupFormat.html
	test='{ "full_text": "<span foreground=\"blue\" bgcolor=\"#efefef\" size=\"x-large\">Blue text</span> is <i>cool</i>!",
\t  "align": "right",
\t  "markup": "pango",
\t  "separator": false },'
}

# NOTE:
#     Despite the fact it may seem useless to have, because all the important
#     info you should be able to output in the window itself (also window
#     titles while stacked/tabbed), and on small screens there may be
#     not enough space for the title, but it’s here
#       - just for it to be if it accidentally become needed;
#       - if window lags and its output is grey screen or copy of what was
#         on the previous workspace, this window title is the only way you
#         can tell what actually this window is and where is belongs to.
get_active_window_name() {
	local id title
	id=`xprop -root | sed -nr 's/^_NET_ACTIVE_WINDOW.*# (.*)$/\1/p'`
	title=`xprop -id "$id" | sed -nr 's/\\\//g;s/^WM_NAME[^"]+"([^"]+)".*/\1/p'`
	[ ${#title} -gt $ACTIVE_WINDOW_NAME_MAX_LENGTH ] \
		&& title=`echo "$title" | sed -r "s/^(.{1,$ACTIVE_WINDOW_NAME_MAX_LENGTH})\b.*/\1…/"`
	active_window_name='{ "full_text": "'"$title"'",
\t  "align": "right",
\t  "markup": "pango",
\t  "separator": false },'
}

get_xkb_layout() {
	# When compiling my own xkb map via xkbcomp, I used the layout I made
	#   with setxkbmap where Scroll Lock indicator was used to indicate
	#   the current layout. But there’s no indicator on the tiny keyboard
	#   I’ve bought recently, so this function is to substitute this lack.
	#   Oh there was also a specific tool to print the current layout,
	#   https://github.com/ierton/xkb-switch I dunno how reliable it is,
	#   and since it’s not in repositories, I rather use xset.
	local scroll_lock=`xset -q | sed -nr 's/.*Scroll Lock:\s+(\S+)\s*$/\1/p'`
	[ "$scroll_lock" = on ] \
		&& local scroll_lock=RUS \
		|| local scroll_lock=ENG
#\t  "color": "#00ff00",
	xkb_layout='{ "full_text": "'"$scroll_lock"'",
\t  "align": "right",
\t  "separator": false },'
}

# This function needs to be redone.
# It must conform to the common pattern of ‘One JSON block – one function’.
# - also add comment about how [200]=' ' can contain custom separator character.
# Make it a multifunction (how do we divide them from the others? Do we need it?
#   by the get_multi_ or get_x_ prefix?) that calls itself as many times as many
#   elements a global array of same name has, say get_free_space() looks for
#   FREE_SPACE_RI=( [item1]='' [item2]='' …) # required items. I.e. there is
#   a special multifunction, that reserves a certain number of modules for
#   its needs (or should we reserve it? Like a 201–300 block? – Nah) and calls
#   another function several times passing next global array item as an argument.
#   — Conformance with separators?..
#   — Eeeeeh…
#   Okay, let it really alternate the modules list, also composite functions
#     like free_space_A() free_space_B() etc.
#   — This will be a pain.
#   — Ugh…
get_free_space() {
	local wait_time=10 mountpoint present_mpoints i inner_separator total free \
		  color_tag inner_comma
	[ $TIMEOUT_STEP -eq 0 -o $((TIMEOUT_STEP % wait_time)) -eq 0 ] && {
		unset free_space
		for mountpoint in $FREE_SPACE_MPOINTS; do
		# We look for an existed mount point which is in use and not bound.
			sed -nr "s~^\S+\s+$mountpoint\s+\S+\s+(\S+)\s.*~\1~p" \
				/proc/mounts | grep -qv bind \
			&& present_mpoints[${#present_mpoints[@]}]="$mountpoint"
		done
		[ -v present_mpoints ] && for ((i=0; i<${#present_mpoints[@]}; i++)); do
			[ $i -lt $((${#present_mpoints[@]}-1)) ] \
				&& inner_separator=" $_not_used_until_they_fix_the_bug_SEPARATOR_CHAR " \
				|| unset inner_separator # This comma appears between blocks
			                              #   showing mountpoints.
			read total free <<< `df -BG -P "${present_mpoints[$i]}" |\
			  sed -rn '$ s/^\S+\s+([0-9]+)G\s+\S+\s+([0-9]+)G.*$/\1\n\2/p'`
			unset color_tag
			if [ $free -le $FREE_SPACE_RED_POINT ]; then
				color_tag='<span fgcolor=\"'$red'\">'
			elif [ $free -le $FREE_SPACE_YELLOW_POINT ]; then
				color_tag='<span fgcolor=\"'$yellow'\">'
			fi
			[ $((i+1)) -eq ${#present_mpoints[@]} ] && inner_separator+=' '
			free_space="${free_space:-}${inner_comma:-}
\t{ \"full_text\": \"${color_tag:-}${present_mpoints[$i]}:$free${color_tag:+</span>}/<sub>$total</sub>$inner_separator\",
\t  \"separator\":false,
\t  \"separator_block_width\":0,
\t  \"markup\": \"pango\" }"

			inner_comma=',' # This comma is a part of json and divides
			                #  {blocks} of code.
		done
		[ "$free_space" ] && free_space="$free_space," # buuug >_< $inner_comma doesn’t append to the last block
	}
}


get_mpd_state() {
	local mpc_output icon random single r s
	unset mpd_caught_playing mpd_state
	mpc_output="$(mpc 2>&1)"
	sed -n '2s/playing//;T;Q1' <<<"$mpc_output" || {
		# read r s < <( sed -nr '$ s/.*random:\s*(on|off)\s+single:\s*(on|off).*/\1 \2/p' <<< "$mpc_output" )
		read r s <<EOF
$( sed -nr '$ s/.*random:\s*(on|off)\s+single:\s*(on|off).*/\1 \2/p' <<<"$mpc_output")
EOF
		[ "$r" = on ] && random="_z"
		[ "$s" = on ] && single="_s"
		mpd_caught_playing=t # this uses in get_gmail
		mpd_state='{ "full_text": "'♬$random$single'",\n\t  "separator": false },'
	}
}

get_speakers_state() {
	unset speakers_state
	amixer get 'Master',0 |& sed '$s/on]$/&/;T;Q1' &>/dev/null \
		&& speakers_state="{ \"full_text\": \"⊀\",
\t  \"color\": \"$red\",
\t  \"separator\": false },"
}

get_mic_state() {
	unset mic_state
	amixer get 'Capture',0 |& sed '$s/on]$/&/;T;Q1' &>/dev/null \
		&& mic_state="{ \"full_text\": \"⍉\",
\t  \"color\": \"$red\",
\t  \"separator\": false },"
}

get_battery_status() {
	local wait_time=30 charge_now bat_status adp_online battery_lifetime \
		  bat_lt_hours bat_lt_minutes bat_time_left \
		  level full_blocks offset next_block blocks colour journal
	[ $TIMEOUT_STEP -eq 0 -o $((TIMEOUT_STEP % wait_time)) -eq 0 ] && {
		unset battery_status
		[ -e /sys/class/power_supply/ADP1/online ] && {
			# We have adapter, and probably, battery.
			if [ -e /sys/class/power_supply/BAT1/status ]; then
				# Yes, battery is present too.
				pushd /sys/class/power_supply &>/dev/null
				[ -v BAT_DATA_PREPARED ] || {
					# Maximum charge available after the last calibration
					CHARGE_FULL=$(< BAT1/charge_full)
					# Maximum charge as it was designed
					CHARGE_FULL_DESIGN=$(< BAT1/charge_full_design)

					STEPS_PER_BLOCK=' ░▒▓█'
					BLOCKS_COUNT=5
					LEVELS_COUNT=$(( ${#STEPS_PER_BLOCK} * $BLOCKS_COUNT ))
					TOTAL_HOURS_BY_DESIGN="6"
					BAT_DATA_PREPARED=t
				}
				# When charging, this shows how much
				charge_now=$(< BAT1/charge_now)
				# Battery status as reported by kernel
				bat_status=$(< BAT1/status)
				# Is external power supply plugged?
				adp_online=$(< ADP1/online)
				popd &>/dev/null

				battery_lifetime=`echo "scale=2;
                                  $TOTAL_HOURS_BY_DESIGN*$charge_now\
				                  /$CHARGE_FULL_DESIGN" | bc`
				bat_lt_hours=${battery_lifetime%.*}
				[ ${#bat_lt_hours} -ne 0 ] && \
					bat_lt_hours="${bat_lt_hours}h " || unset bat_lt_hours
				bat_lt_minutes=`echo "scale=0; ${battery_lifetime#*.}*3/5" | bc`
				[ ${#bat_lt_minutes} -ne 0 ] && \
					bat_lt_minutes="${bat_lt_minutes}m"
				bat_time_left=" ${bat_lt_hours:-}${bat_lt_minutes:-}"
# W!
# Write a journal of battery charge level till it’s completely discharged.
# Be sure _the filesystem_ you save journal on _is protected_ from power loss,
#   e.g. has "data=journal,barrier=1" among mount opts for ext3/4, otherwise
#   all discharging will be in vain.
				# journal=/battery_journal.csv
				level=$(( $charge_now * $LEVELS_COUNT / $CHARGE_FULL ))
				full_blocks=$(( $level / $BLOCKS_COUNT ))
				[ $full_blocks -lt $BLOCKS_COUNT ] && {
					if [ $level -eq 0 ]; then
						offset=$level
					else
						offset=$(( $level - $full_blocks * $BLOCKS_COUNT - 1 ))
					fi
					next_block=${STEPS_PER_BLOCK:$offset:1}
				}

				for ((i=0; i<$full_blocks; i++)); do
					blocks="$blocks${STEPS_PER_BLOCK:4:1}"
				done
				[ -v next_block ] && blocks="$blocks$next_block"
				while [ ${#blocks} -lt $BLOCKS_COUNT ]; do
					blocks="$blocks${STEPS_PER_BLOCK:0:1}"
				done

				if [ $adp_online -eq 1 ]; then
					colour=$green
				elif [ $level -ge 5 ]; then
					colour=$white
				elif [ $level -gt 1 ]; then
					colour=$orange
				else
					# Battery is about to be discharged completely → 0
					# (but still can work for 30 min in idle for me)
					colour=$red
					# Throw a message about shutdown and try to perform it.
					$(Xdialog --timeout 5 \
						--ok-label Shutdown --cancel-label 'NO, WAIT!' \
						--yesno 'Battery level is low.\nIt’s time to shutdown soon.' 370x100)
					[ $charge_now -eq 0 -a $? -eq 0 ] && {
						shutdown &>/dev/null || {  # ~/bin/shutdown
							Xdialog --msgbox 'Shutdown returned with an error.\nYou have to do it manually!' 330x100
							# If the script cannot call shutdown itself,
							#   it must at least try to save the energy
							#   going to sleep for 20 minutes (by that time
							#   the battery will be probably exhausted).
							sleep 1200
						}
					}
				fi
				# [ -v journal ] && \
				# echo "`date +%s`;$charge_now;$current_now;$level" >> $journal
			else
				blocks='EJECTED'
				colour=$red
			fi
		} || {
			blocks='NO POWER_SUPPLY CLASS FOUND'
			colour=$red
		}
		battery_status="{ \"full_text\": \"┫$blocks┣${bat_time_left:-}\",
\t  \"color\":\"$colour\",
\t  \"separator\":false },"
	}
}

get_internet_status() {
	local wait_time=5 # ping_successful # ← local?
	[ $TIMEOUT_STEP -eq 0 -o $((TIMEOUT_STEP % wait_time)) -eq 0 ] && {
		unset HAS_INTERNETS
		[ -p /dev/fd/$PINGOUT ] && {
			unset ping_successful
			grep -q ' 0% packet loss' </dev/fd/$PINGOUT && ping_successful=t
			if [ "$PING_HOST" = "$GOOGLE_DNS" -a -v ping_successful ]; then
				HAS_INTERNETS=t
				# This block is _intended_ to be empty
				internet_status='{ "full_text": "",
\t  "separator":false },'
			elif [ "$PING_HOST" != "$GOOGLE_DNS" -a ! -v ping_successful ]; then
				# We pinged our gateway and it wasn’t successful.
				#   Maybe the problem is on our side? I.e. bad cable.
				internet_status='{ "full_text": "∿",
\t  "color": "'$yellow'",
\t  "separator":false },'
			else
				# We pinged google and it wasn’t successful, or we’re in transi-
				#   tion from gateway check (that was successful) to google DNS
				#   check.
				internet_status='{ "full_text": "∿",
\t  "color": "'$red'",
\t  "separator":false },'
			fi
			exec {PINGOUT}<&-
		}
		[ -v COPROC ] || {
			# wait_time can be here 2×, 3× timeouts or more.
			if [ "$PING_HOST" = "$GOOGLE_DNS" -a ! -v ping_successful ]; then
				PING_HOST=$(route -n | sed -rn 's/^0\.0\.0\.0\s+(\S+)\s.*/\1/p')  # default gateway IP
			elif [ "$PING_HOST" != "$GOOGLE_DNS" -a -v ping_successful ]; then
				PING_HOST=$GOOGLE_DNS
			fi
			coproc ping -W $wait_time -q -n -c1 $PING_HOST
			# <& duplicates input file descriptors,
			# >& duplicates output file descriptors, They both work here.
			# {braces} are important.
			exec {PINGOUT}<&${COPROC[0]}
		}
	}
}

# RELIES UPON:
#     HAS_INTERNETS
get_gmail() {
	local wait_time=5 gmail_server_reply letters_unread
	[ $TIMEOUT_STEP -eq 0 -o $((TIMEOUT_STEP % wait_time)) -eq 0 ] && {
		unset gmail
		if [ -v HAS_INTERNETS ]; then
			gmail_server_reply=`curl --connect-timeout $wait_time \
			-su $GMAIL_USERNAME:$GMAIL_PASSWORD \
		    https://mail.google.com/mail/feed/atom 2>/dev/null`
			[ "$gmail_server_reply" ] || {
				# Unable to connect to mail.google.com
				gmail='{ "full_text": "U✉",
\t  "color": "'$orange'",
\t  "separator":false },'
				return 1
			}
			sed -r 's~^<H2>Error [0-9]{3}</H2>$~&~;T;Q1' \
				&>/dev/null <<<"$gmail_server_reply" || {
				# Server reported invalid user data or other fault.
				gmail='{ "full_text": "E✉",
\t  "color": "'$red'",
\t  "separator":false },'
				return 1
			}
			letters_unread=`sed -nr 's/.*<fullcount>([0-9]+)<.*/\1/p' \
			                <<<"$gmail_server_reply"`
			[ "$letters_unread" -gt 0 ] && {
				# Yay, a new letter!
				gmail='{ "full_text": "'$letters_unread'",
\t  "color": "'$green'",
\t  "separator":false,
\t  "separator_block_width":0 },
\t{ "full_text": "✉",
\t  "color": "'$green'",
\t  "separator":false },'
			}
			[ "$letters_unread" -gt ${OLD_LETTERS_UNREAD:-0} ] && {
				[ -v mpd_caught_playing ] && mpc pause >/dev/null
				aplay ~/.env/Tutturuu_v2.wav           >/dev/null
				[ -v mpd_caught_playing ] && mpc play  >/dev/null
			}
			OLD_LETTERS_UNREAD=$letters_unread
		fi
	}
}

get_schedule() {
	local wait_time=30 dayofweek dayofmonth hour minutes
	[ $TIMEOUT_STEP -eq 0 -o $((TIMEOUT_STEP % wait_time)) -eq 0 ] && {
		unset schedule
		read dayofweek dayofmonth hour minutes <<<$(date "+%A %-d %-H %-M")
		# All the indicators shut down either by themselves after timeout or
		#   with aliases from ~/bashrc/home.sh. See ‘wtr’, ‘snt’, ‘okiru’.
		# Watering plants
		case $dayofweek in
			# If ~/watered hasn’t been `touch`ed within 1/2/3 days…
			Понедельник|Четверг) # Monday and Thursday—days for watering plants
				[ "`find $HOME/ -maxdepth 1 -name watered -mtime -1 2>/dev/null`" ] \
					|| schedule='{ "full_text": "✼",
\t  "color": "'$green'",
\t  "separator": false },'
				;;
			Вторник|Пятница) # Tuesday and Friday show that I forgot to do that yesterday
				[ "`find ~/ -maxdepth 1 -name watered -mtime -2 2>/dev/null`" ] \
					|| schedule='{ "full_text": "✼",
\t  "color": "'$yellow'",
\t  "separator": false },'
				;;
			Среда|Суббота) # two days delay, やべえ〜
				[ "`find ~/ -maxdepth 1 -name watered -mtime -3 2>/dev/null`" ] \
					|| schedule='{ "full_text": "✼",
\t  "color": "'$brown'",
\t  "separator": false },'
				;;
		esac
		# Sending water counters data
		[ $dayofmonth -ge 15 ] \
			&& [ -z "`find ~/ -maxdepth 1 -name sent -mtime -$((dayofmonth-14)) 2>/dev/null`" ] \
			&& schedule="${schedule:+${schedule}\n}"'{ "full_text": "♒",
\t  "color": "'$blue'",
\t  "separator": false },'
		# Waking a certain someone
		case $dayofweek in
			Понедельник|Вторник|Среда|Четверг|Пятница) # Mon–Fri
				[ $hour -eq 6 -a $minutes -ge 5 ] && [ -e /tmp/okiru ] \
					&& schedule="${schedule:+${schedule}\n}"'{ "full_text": "起きる",
\t  "color": "'$green'",
\t  "separator": false },'
				;;
		esac
	}
}

get_nice_date() {
	# This is to fix declensional endings of months’ names in Russian locale.
	local wait_time=10
	[ $TIMEOUT_STEP -eq 0 -o $((TIMEOUT_STEP % wait_time)) -eq 0 ] && {
		# Why %b is ‘июня’, but ‘июл’? >_>
		# nice_date=`date +'%A, %-d %b %-H:%M'`
		nice_date=`date +'%A, %-d =%-m= %-H:%M' \
	         | sed 's/=1=/января/;   s/=2=/февраля/;
	                s/=3=/марта/;    s/=4=/апреля/;
	                s/=5=/мая/;      s/=6=/июня/;
	                s/=7=/июля/;     s/=8=/августа/;
	                s/=9=/сентября/; s/=10=/октября/;
	                s/=11=/ноября/;  s/=12=/декабря/'`
		nice_date='{ "full_text": "'$nice_date'",
\t  "markup": "pango",
\t  "urgent": "true" }'
	}
}


# http://i3wm.org/docs/i3bar-protocol.html
echo '{"version":1}[' && while true; do
	bar="${comma:-}["
	# Should it evaluate each time in the cycle?
	# Do we really need conditionality in this case?
	indices=${!modules[@]}
	last_index=${indices##* }
	for ((i=0; i<last_index+1; i++)); do
		[ $((i % 100)) -eq 0 -a $i -ne 0 ] && {
			[ -v modules[i] -a "$buffer" ] \
				&& buffer+='\n\n\t{ "full_text": "'${modules[i]:-$SEPARATOR_CHAR}'",
\t  "separator": false },'
			bar+="$buffer"
			unset buffer
		}||{
			[ -v modules[i] ] && {
				get_${modules[i]}
				eval cur_module="\${${modules[i]}//\\/\\\\}"
				[ "$cur_module" ] && buffer+="\\n\\n\\t${cur_module}"
			}
		}
	done
	# Append what’s left in the buffer and the JSON tailing ‘]’
	bar+="${buffer:-}\n]"
	unset buffer
	echo -en "$bar" || exit 3
	comma=','
	sleep 1;
	[ $((++TIMEOUT_STEP)) -gt $TIMEOUT_MAX ] && TIMEOUT_STEP=1
done
