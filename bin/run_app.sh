#!/usr/bin/env bash

# run_app.sh

app_name=${0##*/}
[ -v D ] && {
	elog="/tmp/envlogs/runapp_$app_name"
	echo >$elog
	exec &>$elog
	set -x
}
# IIRC, output from certain commands has to be redirected explicitly,
#   hence >>$elog presence after commands. But this may mess usual
#   case when running this script
[ -f "$elog" ] || elog=/dev/null


generic_wine_app() {
	#  To open local files smoothly, paths must be converted
	local paths=() path virt_desktop
	[ $# -eq 0 ]  &&  pgrep -u sszb -f "$wineprog_process_name" && {
		notify-send --hint int:transient:1 \
		            -t 5000 \
		            "$wineprog_name"  "Already running!"
		exit 0
	}
	for path in "$@"; do
		if [ -e "$path" ]; then
			# For each path, that is a valid path
			# (mostly to avoid parts of the paths, like “./something.jpg”,
			#  Thunar and Geeqie let you copy full path, so use them).
			paths+=(
				"$(WINEPREFIX=$wineprog_prefix \
				      sudo -u sszb -H /usr/bin/winepath -w "$path" )"
			)
		else
			notify-send --hint int:transient:1 \
                        --urgency critical \
                        -t 5000 \
                        "$wineprog_name"  "Invalid path: “$path”." \
            || :
		fi
	done
	[ "$wineprog_needs_virtdesktop" = yes ] && {
		virt_desktop="explorer /desktop=${wineprog_name//\ /_},1920x1038"
	}
	( nohup /bin/bash -c "WINEPREFIX=$wineprog_prefix \
		sudo -u sszb -H  /usr/bin/wine ${virt_desktop:-} \
			 '$wineprog_exe_path' \"${paths[@]}\"" ) &
}

case $app_name in
	# NB: only actual binaries with absolute paths here!
	acrobat-reader)
		wineprog_name='Acrobat Reader'
		wineprog_process_name='acrord32.exe'
		wineprog_exe_path='/home/sszb/.wine32-programs/drive_c/Program Files/Adobe/Acrobat Reader DC/Reader/AcroRd32.exe'
		wineprog_prefix='/home/sszb/.wine32-programs'
		wineprog_needs_virtdesktop='yes'
		generic_wine_app "$@"
		;;
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
		wineprog_name='Master PDF Editor'
		wineprog_process_name='MasterPDFEditor.exe'
		wineprog_exe_path='/home/sszb/.wine32-programs/drive_c/Program Files/Code Industry/Master PDF Editor 5/MasterPDFEditor.exe'
		wineprog_prefix='/home/sszb/.wine32-programs'
		wineprog_needs_virtdesktop='yes'
		generic_wine_app "$@"
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
		wineprog_name='Photoshop'
		wineprog_process_name='Photoshop'
		wineprog_exe_path='/home/sszb/.wine32-programs/drive_c/Program Files/Adobe/Adobe Photoshop CC 2018 (32 Bit)/Photoshop.exe'
		wineprog_prefix='/home/sszb/.wine32-programs'
		wineprog_needs_virtdesktop='yes'
		generic_wine_app "$@"
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
	png22pnm)
		#  This is for sam2p tool
		#  It still uses pngtopnm, which was called back then png2pnm,
		#  there’s probably a typo in the name in the code with two ‘2’.
		#echo "png22pnm: $@" >/tmp/t
		local arg
		for arg in "$@"; do
			[ "$arg" = -rgba ] && arg='-alpha'
		done
		pngtopam "$@"
		exit 0
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

exit 0