#!/usr/bin/env bash

# run_app.sh

app_name=${0##*/}
[ "${ENV_DEBUG/*r*/}" ] || {
	elog="/tmp/envlogs/runapp_$app_name"
	echo >$elog
	exec &>$elog
	set -x
}
# IIRC, output from certain commands has to be redirected explicitly,
#   hence >>$elog presence after commands. But this may mess usual
#   case when running this script
[ -f "$elog" ] || elog=/dev/null

case $app_name in
	# NB: only actual binaries with absolute paths here!
	mpd)
		cp ~/.mpd/mpd.conf.common ~/.mpd/mpd.conf
		cat ~/.mpd/mpd.conf.$HOSTNAME >>~/.mpd/mpd.conf
		sed -ri "s/USER/$USER/" ~/.mpd/mpd.conf
		/usr/bin/mpd "$@"
		;;
	firefox)
		[ -e /usr/bin/firefox-bin ] \
			&& firefox=/usr/bin/firefox-bin \
			|| firefox=/usr/bin/firefox
		$firefox --profile ~/.ff
		;;
	mpv)
		# Stop mpd playing for regular mpv instances,
		# but do not control those mpv instances, that are encoding processes.
		# When you make webms with the lua script for conversion,
		# that background mpv that does encoding would try to pause the already
		# paused mpd, and when the conversion is done it will… right, unpause it.
		echo "$*" >> ~/what
		[[ "$*" =~ ^.*\ --ovc=.*$ ]] || {
			control_mpd=t
			mpc |& sed -n '2s/playing//;T;Q1' || mpd_caught_playing=t
		}
		[ -v control_mpd ] && mpc pause >/dev/null
		/usr/bin/mpv "$@"
		result=$?
		[ -v control_mpd -a -v mpd_caught_playing ] && mpc play >/dev/null
		exit $result  # or else the first pass of mpv encoder process may end with 1
		              # and the second pass will never start,
		              # leaving us with a half-baked webm.
		;;
	shutdown)
		#~/.i3/on_quit.sh
		pkill -HUP gpg-agent # clear cache
		sudo /sbin/init 0
		;;
	*)
		cat <<-"EOF"
		Usage:
			Just use symbolic links:
			ln -s ~/bin/run_app.sh ~/bin/firefox

		Don’t forget to `export PATH="$HOME/bin:$PATH"`!
		EOF
		exit 3
	;;
esac
