#!/usr/bin/env bash

# run_app.sh

app_name=${0##*/}
# [ "${ENV_DEBUG/*r*/}" ] || {
	elog="/tmp/envlogs/runapp_$app_name"
	echo >$elog
	exec &>$elog
	set -x
# }
# IIRC, output from certain commands has to be redirected explicitly,
#   hence >>$elog presence after commands. But this may mess usual
#   case when running this script
[ -f "$elog" ] || elog=/dev/null

case $app_name in
	# NB: only actual binaries with absolute paths here!
	firefox)
		[ -e /usr/bin/firefox-bin ] \
			&& firefox=/usr/bin/firefox-bin \
			|| firefox=/usr/bin/firefox
		#  Cleaning fat caches
		#  1. DOM volatile data (no, form data is in another file)
		#     To be deleted once it grwos bigger than 10 MiB.
		find ~/.ff/ -size +10M -name webappsstore.sqlite -delete
		$firefox --profile ~/.ff "$@"
		;;
	master-pdf-editor)
		[ $# -eq 0 ]  &&  pgrep -u sszb -f MasterPDFEditor.exe && {
			notify-send --hint int:transient:1 \
			            -t 5000 \
			            "Master PDF Editor"  "Already running!"
			exit 0
		}
		for path in "$@"; do
			if [ -e "$path" ]; then
				# For each path, that is a valid path
				# (mostly to avoid parts of the paths, like “./something.jpg”,
				#  Thunar and Geeqie let you copy full path, so use them).
				mpdf_paths+=(
					"$(WINEPREFIX=~sszb/.wine32-programs \
					      sudo -u sszb -H /usr/bin/winepath -w "$path" )"
				)
			else
				notify-send --hint int:transient:1 \
	                        --urgency critical \
	                        -t 5000 \
	                        "Master PDF Editor"  "Invalid path: “$path”." \
	            || :
			fi
		done
		nohup /bin/bash -c "WINEPREFIX=~sszb/.wine32-programs \
			sudo -u sszb -H \
				/usr/bin/wine '/home/sszb/.wine32-programs/drive_c/Program Files/Code Industry/Master PDF Editor 5/MasterPDFEditor.exe' \
				              \"${mpde_paths[@]}\"" &

		;;
	mpd)
		cp ~/.mpd/mpd.conf.common ~/.mpd/mpd.conf
		cat ~/.mpd/mpd.conf.$HOSTNAME >>~/.mpd/mpd.conf
		sed -ri "s/USER/$USER/" ~/.mpd/mpd.conf
		/usr/bin/mpd "$@"
		;;
	mpv)
		# Stop mpd playing for regular mpv instances,
		# but do not control those mpv instances, that are encoding processes.
		# When you make webms with the lua script for conversion,
		# that background mpv that does encoding would try to pause the already
		# paused mpd, and when the conversion is done it will… right, unpause it.
		[[ "$*" =~ ^.*\ --ovc=.*$ ]] || {
			control_mpd=t
			mpc |& sed -n '2s/playing//;T;Q1' || mpd_caught_playing=t
		}
		[ -v control_mpd ] && mpc pause >/dev/null
		/usr/bin/mpv "${@//\$/\$}"
		result=$?
		[ -v control_mpd -a -v mpd_caught_playing ] && mpc play >/dev/null
		exit $result  # or else the first pass of mpv encoder process may end with 1
		              # and the second pass will never start,
		              # leaving us with a half-baked webm.
		;;
	photoshop)
		#  To open local files smoothly, paths must be converted
		[ $# -eq 0 ]  &&  pgrep -u sszb -f Photoshop && {
			notify-send --hint int:transient:1 \
			            -t 5000 \
			            "Photoshop"  "Already running!"
			exit 0
		}
		for path in "$@"; do
			if [ -e "$path" ]; then
				# For each path, that is a valid path
				# (mostly to avoid parts of the paths, like “./something.jpg”,
				#  Thunar and Geeqie let you copy full path, so use them).
				photoshop_paths+=(
					"$(WINEPREFIX=~sszb/.wine32-programs \
					      sudo -u sszb -H /usr/bin/winepath -w "$path" )"
				)
			else
				notify-send --hint int:transient:1 \
	                        --urgency critical \
	                        -t 5000 \
	                        "Photoshop"  "Invalid path: “$path”." \
	            || :
			fi
		done
		nohup /bin/bash -c "WINEPREFIX=~sszb/.wine32-programs \
			sudo -u sszb -H \
				/usr/bin/wine explorer /desktop=Photoshop,1920x1038 \
				              '/home/sszb/.wine32-programs/drive_c/Program Files/Adobe/Adobe Photoshop CC 2018 (32 Bit)/Photoshop.exe' \
				              \"${photoshop_paths[@]}\"" &

		 # This is what photoshop outputs, when the window doesn’t show up.
		#
		# 003e:warn:keyboard:X11DRV_InitKeyboard vkey 012C is being used by more than one keycode
		# 003e:warn:keyboard:X11DRV_InitKeyboard vkey 01B4 is being used by more than one keycode
		# 003e:warn:keyboard:X11DRV_InitKeyboard vkey 0003 is being used by more than one keycode
		# 003e:warn:keyboard:X11DRV_InitKeyboard No more vkeys available!
		# 003e:warn:class:CLASS_RegisterClass Win extra bytes 48 is > 40
		# 003e:warn:wineconsole:WCUSER_SetFontPmt Couldn't match the font from registry... trying to find one
		# 003c:warn:ntdll:NtQueryAttributesFile L"\\??\\C:\\Program Files\\Adobe\\Adobe Photoshop CC 2018 (32 Bit)\\imm32.dll" not found (c0000034)
		# 003c:fixme:ntdll:EtwEventRegister ({5eec90ab-c022-44b2-a5dd-fd716a222a15}, 0x405227, 0x53c3f0, 0x53c408) stub.
		# 003c:fixme:ntdll:EtwEventSetInformation (deadbeef, 2, 0x532950, 43) stub
		# 003c:warn:ntdll:NtQueryAttributesFile L"\\??\\C:\\Program Files\\Adobe\\Adobe Photoshop CC 2018 (32 Bit)\\HLLog.config" not found (c0000034)
		# 003c:fixme:ver:GetCurrentPackageId (0x34fe24 (nil)): stub
		# 003c:warn:ntdll:NtQueryAttributesFile L"\\??\\C:\\Program Files\\Adobe\\Adobe Photoshop CC 2018 (32 Bit)\\mscoree.dll" not found (c0000034)
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
