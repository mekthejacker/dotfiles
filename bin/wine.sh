#! /usr/bin/env bash

# This script serves three purposes:
#   - to run wine from another user for safety and usage benefits,
#     such as dealing with hanging semaphores. Local WINEPREFIXes
#     are still accessible too;
#   - unify commands – user chooses between available WINEPREFIX folders,
#     then WINEARCH and an appropriate wine binary is guessed from that folder;
#   - automate the setup of a new WINEPREFIX folder.
# © deterenkelt 2018
# For the licence see --version output.

# This script assumes three steps, that you should do:
#   1. That you have created some user (accepted as --wine-user
#      in this script)
#
#      Example commmand:
#      # useradd -m -G audio,video,cdrom,games,plugdev -s /bin/bash wineuser
#
#      Where the ‘wineuser’ is the new fake user,
#      as which you will be running wine.
#
#   2. That you’ve set up /etc/sudoers the following way. This is to not type
#      ‘sudo…’ every time (this script takes the job) and to pass important
#      variables to wineuser’s environment, such as DISPLAY, XAUTHORITY
#      or __GL_SYNC_TO_VBLANK.
#
#      Add to /etc/sudoers:
#        User_Alias WINE_USER = you, and, all, the, others, who, may, run, wine
#        Defaults:WINE_USER env_reset
#        Defaults:WINE_USER env_keep += DISPLAY
#        Defaults:WINE_USER env_keep += LANG
#        Defaults:WINE_USER env_keep += XAUTHORITY
#        Defaults:WINE_USER env_keep += WINEARCH
#        Defaults:WINE_USER env_keep += WINEDEBUG
#        Defaults:WINE_USER env_keep += WINEPREFIX
#        Defaults:WINE_USER env_keep += WINEDLLOVERRIDES
#        Defaults:WINE_USER env_keep += LD_PRELOAD
#        Defaults:WINE_USER env_keep += __GL_THREADED_OPTIMIZATIONS
#        Defaults:WINE_USER env_keep += __GL_SYNC_TO_VBLANK
#        Defaults:WINE_USER env_keep += __GL_YIELD
#        Defaults:WINE_USER env_keep += SDL_AUDIODRIVER
#        Defaults:WINE_USER env_keep += CSMT
#        WINE_USER ALL = (wineuser) NOPASSWD: ALL
#
#      Replace user name(s) in the User_Alias line with the appropriate one(s).
#      The ‘wineuser’ in the parentheses in the last line should be the name
#      of the fake user, that you’ve created beforehand. Now you (and this
#      script) are able to run any command as wineuser:
#        $ sudo -u wineuser -H …
#      without password.
#
#              | The variables inbetween the first and the last lines
#              | keep settings for wine, X server and X drivers,
#              | which otherwise would be lost on a call via sudo.
#
#  3. Your WINEPREFIX folders should start with either ‘.wine32’ or ‘.wine64’.
#     This is to make sure, what WINEARCH you want and remove any ambiguities,
#     when it’s time to guess WINEARCH from WINEPREFIX for the script.
#     Not a big price for the ease of use, huh?
#
#  4. Finally, to use wine with this script (and not wine as is), set up your
#     shells to use it.
#     - add these lines to your ~/.bashrc and edit the paths:
#
#          # This setup uses a dummy user called sszb that holds prefixes,
#         #  but in order for him to be able to show the windows on our X session,
#         #  he must be allowed to do this in the first place.
#         #
#         xhost +si:localuser:$WINEUSER > /dev/null
#         alias       wine="$HOME/bin/wine.sh --wine-user sszb --run-as wine"
#         alias     wine64="$HOME/bin/wine.sh --wine-user sszb --run-as wine64"
#         alias    winecfg="$HOME/bin/wine.sh --wine-user sszb --run-as winecfg"
#         alias    regedit="$HOME/bin/wine.sh --wine-user sszb --run-as regedit"
#         alias winetricks="$HOME/bin/wine.sh --wine-user sszb --run-as winetricks"
#         alias   killwine="$HOME/bin/wine.sh --wine-user sszb --run-as killwine"
#
#       Repalce ‘sszb’ with the user you created before to run wine.
#       ‘killwine’ is a handy command, that will make sure you get a clean
#       environment between runs. Look for the note about ‘semaphores’
#       in this file.
#     - in the ~/.bashrc Add the path used above to PATH:
#
#         [ "${PATH//*$HOME\/bin*/}" ] && export PATH="$HOME/bin:$PATH"
#
#     - Now that you’ve set up the environment, your shells have to re-source
#       the ~/.bashrc or whatever file you placed the settings. If you didn’t
#       understand, what that means, simply log off and log in again.



 # Output of menu() is more readable than bash’s select, that lumps
#  several options in 5–15 columns. Also info() and err() save space here.
#
#  Find the lib at https://github.com/deterenkelt/bhlls
#
NO_LOGGING=t
. ~/repos/bhlls/bhlls.sh
# set -x
set -feE
shopt -s extglob
VERSION="20170128"

show_help() {
	cat <<-EOF
	Usage
	./wine.sh --wine-user <USER> --run-as <WINE_COMMAND> -- [<FILE.EXE> [EXE_OPTS]]

	            USER is the user you created to run wine in your place.
	    WINE_COMMAND is one of the keys: wine, wine64, winecfg, regedit,
	                 winetricks, wineprefix-setup, killwine.
	     Double dash separates wine.sh own options from the options
	                 for the actual wine binaries (those in /usr/bin/).
	        FILE.EXE is a Windows executable, that can be passed optionally.
	        EXE_OPTS are the options to FILE.EXE.


	Examples

	    Running Steam
	    $ ./wine.sh --wine-user fakeuser --run-as wine \\
	                -- \\
	                /home/steam/Steam.exe -no-cef-sandbox

	    Running winecfg
	    $ ./wine.sh --wine-user fakeuser --run-as winecfg

	    Running winecfg from a specified WINEPREFIX (omits searching)
	    $ WINEPREFIX=/home/fakeuser/.wine32 ./wine.sh --wine-user fakeuser \\
	                                                  --run-as winecfg

	    Setting up a new wineprefix with the specified name
	    $ WINEPREFIX=/home/fakeuser/.wine32-some-game ./wine.sh \\
	                                                  --wine-user fakeuser \\
	                                                  --run-as wineprefix-setup

	    Prepending the command with WINEPREFIX is
	    - *optional* for WINE_COMMANDs wine, wine64, winecfg, regedit, winetricks;
	    - *mandatory* for WINE_COMMAND wineprefix-setup.
	    WINE_COMMAND killwine *ignores* it.

	See the notes in the beginning of the script on how to create the user
	and set up the environment.
	EOF
}

show_version() {
	cat <<-EOF
	wine.sh $VERSION
	© deterenkelt 2013–2018
	License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
	This is free software: you are free to change and redistribute it.
	There is NO WARRANTY, to the extent permitted by law.
	EOF
}

show_error() {
	local file=$1 line=$2 lineno=$3
	echo -e "$file: An error occured!\nLine $lineno: $line" >&2
	notify-send --hint int:transient:1 -t 3000 "${BASH_SOURCE##*/}" "Error: check the console."
}

 # The reason we need this function is because set +e won’t remove the trap.
#  So after disabling the errexit shell option, we also need to remove that
#  trap manually and put it back.
#
traponerr() {
	case "$1" in
		set)
			# NB single quotes – to prevent early expansion
			trap 'show_error "$BASH_SOURCE" "$BASH_COMMAND" "$LINENO"' ERR
			;;
		unset)
			# NB trap '' ERR will ignore the signal.
			#    trap - ERR will reset command to 'show_error "$BASH_SOURCE…'
			trap '' ERR
			;;
	esac
}
traponerr set


[ -v DISPLAY ] || {
	err 'DISPLAY is unset. Are we running outside an X server?'
	exit 3
}

unset WINEDEBUG \
      WINEARCH \
      __GL_THREADED_OPTIMIZATIONS \
      __GL_SYNC_TO_VBLANK \
      __GL_YIELD

 # In order to get more output from wine, use
#  WINEDEBUG=warn  or  WINEDEBUG=warn+all
#
export WINEDEBUG="-all" \
       WINEARCH \
       WINEPREFIX \
       SDL_AUDIODRIVER=alsa
       __GL_THREADED_OPTIMIZATIONS=1 \
       __GL_SYNC_TO_VBLANK=0 \
       __GL_YIELD="NOTHING"


 # If WINEPREFIX wasn’t passed through the environment,
#  find available WINEPREFIX folders in $HOME and fake user’s
#  $HOME and make the user choose from them.
#
set_wineprefix() {
	local prefix_list
	if [ -v WINEPREFIX ]; then
		[ -d "$WINEPREFIX" -a -r "$WINEPREFIX" ] || {
			# If we create a new WINEPREFIX, it indeed does not exist.
			# However in this function we must validate the folder name.
			[ "$1" != may_not_exist ] && {
				err "Passed WINEPREFIX is not a readable directory:\n$WINEPREFIX"
				return 3
			}
		}
	else
		prefix_list=( $(pushd /home &>/dev/null;  \
			            find -L $USER $WINEUSER -maxdepth 1 \
			                                    -name ".wine*" \
			                                    -type d \
			            | sort)
			        )
		if [ ${#prefix_list[@]} -eq 1 ]; then
			menu "Found one WINEPREFIX:
			      ${prefix_list[0]}
			      Choose it?" _Yes_ No
			[ "$CHOSEN" = Yes ] \
				&& WINEPREFIX="/home/${prefix_list[0]}" \
				|| { err 'Aborted.'; return 3; }
		elif [ ${#prefix_list[@]} -eq 0 ]; then
			err "No .wine\* folders found in $HOME and /home/$WINEUSER."
			return 3
		else
			menu 'Choose WINEPREFIX' "${prefix_list[@]}"
			WINEPREFIX="/home/$CHOSEN"
		fi
	fi
	WINEPREFIX_NAME="${WINEPREFIX##*/}"  # .wine32-something or .wine64-smth.
	WINEPREFIX_OWNER="${WINEPREFIX#/home/}"
	 # $USER or $WINEUSER.
	#  To delete trash from WINEPREFIX later in __wine().
	WINEPREFIX_OWNER="${WINEPREFIX_OWNER%/*}"
	[[ "$WINEPREFIX_OWNER" =~ ^($USER|$WINEUSER)$ ]] || {
		err 'Couldn’t determine WINEPREFIX_OWNER. Is their \$HOME in /home?'
		return 3
	}
	[[ "$WINEPREFIX_NAME" =~ ^\.wine32 ]] && WINEARCH=win32
	[[ "$WINEPREFIX_NAME" =~ ^\.wine64 ]] && WINEARCH=win64
	[ "$WINEARCH" ] || {
		err 'WINEPREFIX name should start with either ‘.wine32’ or ‘.wine64’!'
		return 3
	}
	export WINEPREFIX WINEARCH WINEPREFIX_NAME WINEPREFIX_OWNER
	info "PREFIX = $WINEPREFIX"
	info "ARCH = $WINEARCH"
	return
}


 # This is a general function to do all the jobs.
#  [$@] — list of arguments for wine, winetricks etc.
#
__wine() {
	local run_as="$1" binary sudo="sudo -u $WINEUSER -H"
	shift
	set_wineprefix || return $?
	case "$run_as" in
		wine|wine64)
			[ $WINEARCH = win32 ] \
				&& binary='/usr/bin/wine' \
				|| binary='/usr/bin/wine64'
			;;
		winecfg)
			binary='/usr/bin/winecfg'
			;;
		wineboot)
			binary='/usr/bin/wineboot'
			;;
		regedit)
			binary='/usr/bin/regedit'
			;;
		winetricks)
			binary='/usr/bin/winetricks'
			;;
		*)
			err 'I am not supposed to run as this command.'
			return 3
	esac
	[ "$WINEPREFIX_OWNER" = "$USER" ] \
		&& $binary "$@" \
		|| $sudo $binary "$@"
	# Clean emulated wine desktop from icons placed by programs.
	# killwine() must be able to run without binding to a wineprefix, so these
	# lines are here, in __wine().
	if [ "$WINEPREFIX_OWNER" = "$USER" ]; then
		/bin/rm $WINEPREFIX/drive_c/users/$WINEPREFIX_OWNER/#msgctxt#directory#Desktop/* \
		        $WINEPREFIX/drive_c/users/Public/#msgctxt#directory#Desktop/* 2>/dev/null
	else
		$sudo /bin/rm $WINEPREFIX/drive_c/users/$WINEPREFIX_OWNER/#msgctxt#directory#Desktop/* \
		              $WINEPREFIX/drive_c/users/Public/#msgctxt#directory#Desktop/* 2>/dev/null
	fi
	 # guarantee that wine won’t hang and semaphores were cleared
	#  at the disadvantage, that when an application restarts itself,
	#  its children process may be killed.
	#
	# killwine
	return
}


killwine() {
	local i
	sudo -u $WINEUSER /usr/bin/killall -9 -u $WINEUSER
	# After wine is closed/killed, semaphores that it created, may still hang
	# in the OS. Certain programs do not like it and refuse to work. An advan-
	# tage of running wine from a separate user is also that we can clear
	# the semaphore list safely, without breaking something in the main user’s
	# session (if we would run wine locally, e.g. in our own ~/.wine32).
	for i in $(ipcs -s | sed -rn "s/.*\s([0-9]+)\s+$WINEUSER.*/\1/p"); do
		ipcrm -s $i
	done
	return
}


wineprefix-setup() {
	[ -v WINEPREFIX ] || {
		err "Pass the folder you want to create as
		     WINEPREFIX=/home/$WINEUSER/.wine32-something wineprefix-setup"
		return 3
	}
	set_wineprefix may_not_exist || $?
	# Maybe some day it will work…
	# shopt -s expand_aliases
	[ -d "$WINEPREFIX" ] && {
		menu "$WINEPREFIX still exists. Remove it? [y/N]" Yes _No_
		[ "$CHOSEN" = Yes ] \
			&& sudo -u $WINEUSER -H rm -rf "$WINEPREFIX" \
			|| { err 'Aborted'; return 3; }
	}
	infow "1. Checking WINEPREFIX in $WINEPREFIX" \
	      "WINEDEBUG=-all sudo -u $WINEUSER -H wine cmd.exe /c echo %ProgramFiles%" \
	      force_stderr

	info "2. Setting wine options"
	declare -A options=(
		[csmt]=on
		[ddr]=opengl # Set DirectDrawRenderer to opengl //gdi
		[fontsmooth]=gray # Enable subpixel font smoothing //rgb,bgr,disable
		# GLSL
		# enabled
		# disabled on nvidia may be faster
		[glsl]=disabled # Enable glsl shaders
		[multisampling]=enabled # Enable Direct3D multisampling //disabled
		[mwo]=force # Set DirectInput MouseWarpOverride to force //disable,enabled
		[psm]=3 # Supported shader model version // <0|1|2|3>
		[sound]=alsa # Set sound driver to ALSA //disabled,oss,coreaudio (mac)
		[strictdrawordering]=disabled # //disabled (may make things faster), fixes severe glitches in DE:HR, Tombraider 2013, Metro 2033 etc.
		[videomemorysize]=$((`nvidia-settings --query $DISPLAY/VideoRam | sed -nr '2s/.*\s([0-9]+)\.$/\1/p'`/1024)) # in MiB
		[vsm]=3
		[gsm]=3
		[psm]=3
		[win7]=  # Windows version // <win31|win95|win98|win2k|winxp|win2k3|vista|win7>
	)
	for opt in "${!options[@]}"; do
		value=${options[$opt]}
		infow "Setting $opt${value:+=$value}" \
		      "sudo -u $WINEUSER -H winetricks \"$opt${value:+=$value}\" >/dev/null" \
		      force_stderr
	done
	read width height width_mm \
		< <(xrandr | sed -rn 's/^.* connected.* ([0-9]+)x([0-9]+).* ([0-9]+)mm x [0-9]+mm.*$/\1 \2 \3/p; T; Q1' \
		    && echo '800 600 211.6')
	DPI=$(echo "scale=2; dpi=$width/$width_mm*25.4; scale=0; dpi /= 1; print dpi" | bc -q)

	info "2a. Setting emulated virtual desktop size to $width×$height"
	cat <<-EOF >/tmp/vd.reg
	ÿþWindows Registry Editor Version 5.00
		[HKEY_CURRENT_USER\Software\Wine\Explorer\Desktops]
	"Default"="${width}x$height"
	EOF
	chmod 644 /tmp/vd.reg
	infow "Running regedit…" \
	      "sudo -u $WINEUSER -H /usr/bin/regedit /tmp/vd.reg" \
	      force_stderr
	rm /tmp/vd.reg

	info "2b. Setting display DPI to the actual value of $DPI"
	hex_dpi=$(printf "%08x\n" $DPI)
	cat <<-EOF >/tmp/vd.reg
	ÿþWindows Registry Editor Version 5.00
		[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Hardware Profiles\Current\Software\Fonts]
	"LogPixels"=dword:$hex_dpi
	EOF
	chmod 644 /tmp/vd.reg
	infow "Running regedit…" \
	      "sudo -u $WINEUSER -H /usr/bin/regedit /tmp/vd.reg" \
	      force_stderr
	rm /tmp/vd.reg

	info "3. Installing necessary packages"
	local packages=(
		corefonts # Default windows fonts
		devenum   # Required by many games
		d3dcompiler_43 # Don’t install the whole ‘directx9’!
		d3dx9     #        because it will break interaction between those
		          #        built in wine, which wine _must_ use to work
		          #        properly (e.g. xinput), and those native
		          #        installed by the ‘directx9’ command.
		d3dx10
		d3dx10_43
		d3dx11_42
		d3dx11_43
		dotnet45  # Required by many windows apps
		flash     # Adobe Flash plugin
		#ie8
		mfc42     # Required by some games
		#msxml6
		physx     # Required by games using PhysX
		quartz    # Required by many games
		unifont   # This font has all glyphs possible
		vcrun2008 # Required by many apps
		vcrun2010 # Required by many apps
		vcrun2015 # Required by many apps
		xact      # X3DAudio1_7.dll issues
	)
	for package in ${packages[@]}; do
		infow "Installing $package" \
		      "sudo -u $WINEUSER -H winetricks \"$package\" >/dev/null" \
		      force_stderr
	done
	type wineprefix-setup-postinstall &>/dev/null \
		&& WINEPREFIX="$WINEPREFIX" WINEARCH=$WINEARCH wineprefix-setup-postinstall
	return
}


 # If ‘steam servers are too busy (error 2)’ after ‘completing installation’
#  freezes on 0 or 1%, this is a known issue. Try to reinstall
#  http://www.microsoft.com/en-us/download/details.aspx?id=21835
#  http://www.microsoft.com/en-us/download/details.aspx?id=30679



#
 #  Main algorithm starts here
#

# getopt from util-linux 2.24 is known to allow long options with a single dash
#   independetly of whether the -a|--alternative option is passed.
opts=`getopt \
             --options \
                       hv \
             --longoptions \
help,\
run-as:,\
version,\
wineuser:,wine-user:,\
             -n 'wine.sh' -- "$@"`
getopt_exit_code=$?
[ $getopt_exit_code -gt 0 ] && {
	case $getopt_exit_code in
		1) err 'getopt error.' && exit 3;;
		2) err 'Bad parameters to getopt.' && exit 3;;
		3) err 'Internal error in getopt.' && exit 3;;
		4) err 'Remove -T, baka.' && exit 3;;
	esac
}
eval set -- "$opts"

while true; do
	option="$1" # becasue this way it may be used in err()
	case "$option" in
		-h|'--help')
			show_help
			exit 0
			;;
		'--run-as')
			[[ "$2" =~ ^(wine|wine64|winecfg|regedit|winetricks|wineprefix-setup|killwine)$ ]] \
				&& RUN_AS="$2" \
				|| { err "Possible arguments to --run-as are: wine, wine64, winecfg, regedit,
				          winetricks, wineprefix-setup, killwine"; }
			shift 2
			;;
		'--wine-user')
			id "$2" &>/dev/null \
				&& WINEUSER="$2" \
				|| { err "No such user: $2"; exit 3; }
			shift 2
			;;
		-v|'--version')
			show_version
			exit 0
			;;
		--)
			shift
			break
			;;
	esac
done

case "$RUN_AS" in
	wine|wine64|winecfg|regedit|winetricks)
		__wine "$RUN_AS" "$@" || exit $?
		;;
	wineprefix-setup)
		wineprefix-setup || exit $?
		;;
	killwine)
		killwine || exit $?
		;;
esac