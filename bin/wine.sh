#! /usr/bin/env bash

#  wine.sh
#  Handle multiple wine bottles easy and safely.
#  © deterenkelt 2018
#  For the licence see --version output.

 # What this script does
#
#  - Launches wine, winecfg, winetricks and other commands without
#    prepending the command with a correct wineprefix: simply move the cursor
#    to the right wine folder and hit enter. The list is moderately highlighted.
#    (You can still pass WINEPREFIX via environment, when using this script).
#
#  - Runs commands as a separate user
#    What is the benefit?
#      a) mistakes and malicious programs do not affect your user folders;
#      b) wine bugs do not affect your user’s environment; to name one,
#         a poorly exited windows binary may leave uncleared semaphores,
#         that will prevent this programs to run. Semaphores are created
#         by wine in the Linux environment, i.e. they belong to the user, that
#         runs wine, they don’t die when wine closes, they persist between
#         wine runs. Other programs may create semaphores too, so there’s no
#         way to identify, which are bad. Thus to clear bad semaphores one
#         would have to log out or reboot. Running wine applications from
#         another user allows to clean all its semaphores without worrying
#         to break the environment of the real user;
#      c) it’s easier to kill hanging wine processes, when you can run
#         $ pkill -9 -u wineuser
#      d) untrustede software may be launched from another user, and trusted –
#         from the real user winepreefixes – this script works with both.
#
#   - Automates the setup of a new WINEPREFIX folder and stuffing it with
#     libraries.


 # What this script requires
#
#  1. Create a user, that will run wine instead of you.
#     (This name shall later be used as the value for --wine-user)
#
#     Example commmand:
#     # useradd -g $(id -g myrealuser) \
#               -m -G users,audio,video,cdrom,games,plugdev \
#               -s /bin/bash wineuser
#
#     Where “myrealuser” is the username with which you log in every day.
#     “wineuser” is the name for the new fake user for running wine in your
#     place.
#
#     “-g $(id -g myrealuser)” will set the initial group for that user
#     as your own. This way you will have less troubles, when you’d need
#     to access myrealuser’s files and folders – just give files the necces-
#     sary group permissions.
#
#
#  2. Set up /etc/sudoers to make running commands transparent.
#     This script uses sudo to run wine as another user, so we set permissions
#       for you, so you wouldn’t need to type password each time.
#     Your environment should also be protected from leaking into fake user’s.
#       In order to forbid leaking, the following rules first forbid any vari-
#       ables, that transit from your environment, then give permissions
#       per variable – it’s only those variables, that are related to running
#       Wine properly.
#     Add to /etc/sudoers
#
#       User_Alias WINE_USER = you, and, all, the, others, who, may, run, wine
#       Defaults:WINE_USER env_reset
#       Defaults:WINE_USER env_keep += DISPLAY
#       Defaults:WINE_USER env_keep += LANG
#       Defaults:WINE_USER env_keep += XAUTHORITY
#       Defaults:WINE_USER env_keep += WINEARCH
#       Defaults:WINE_USER env_keep += WINEDEBUG
#       Defaults:WINE_USER env_keep += WINEPREFIX
#       Defaults:WINE_USER env_keep += WINEDLLOVERRIDES
#       Defaults:WINE_USER env_keep += LD_PRELOAD
#       Defaults:WINE_USER env_keep += __GL_THREADED_OPTIMIZATIONS
#       Defaults:WINE_USER env_keep += __GL_SYNC_TO_VBLANK
#       Defaults:WINE_USER env_keep += __GL_YIELD
#       Defaults:WINE_USER env_keep += SDL_AUDIODRIVER
#       Defaults:WINE_USER env_keep += CSMT
#       WINE_USER ALL = (wineuser) NOPASSWD: ALL
#
#     Replace user name(s) in the User_Alias line with the appropriate one(s).
#       The “wineuser” on the last line should be the name of the fake user.
#     From now on you should be able to run any command as wineuser without
#       password.
#       $ sudo -u wineuser  -H  firefox
#
#
#  3. Create some wineprefixes.
#     Note, that folders should start with either ‘.wine32’ or ‘.wine64’ –
#       this will determine, whether it’s 32-bit or 64-bit. The script will
#       set WINEARCH based on the name.
#       $ WINEPREFIX=/home/wineuser/.wine32-programs  wineprefix-create
#
#
#  4. Final step – add these lines to your ~/.bashrc and edit the paths:
#
#        # This setup uses a dummy user called wineuser that holds prefixes,
#       #  but in order for him to be able to show the windows on our X session,
#       #  he must be allowed to do this in the first place.
#       #
#       xhost +si:localuser:wineuser > /dev/null
#       wine()              { $HOME/bin/wine.sh --wine-user wineuser --run-as wine "$@"; }
#       wine64()            { $HOME/bin/wine.sh --wine-user wineuser --run-as wine64 "$@"; }
#       wineconsole()       { $HOME/bin/wine.sh --wine-user wineuser --run-as wineconsole "$@"; }
#       winecfg()           { $HOME/bin/wine.sh --wine-user wineuser --run-as winecfg "$@"; }
#       regedit()           { $HOME/bin/wine.sh --wine-user wineuser --run-as regedit "$@"; }
#       winetricks()        { $HOME/bin/wine.sh --wine-user wineuser --run-as winetricks "$@"; }
#       wineprefix-create() { $HOME/bin/wine.sh --wine-user wineuser --run-as wineprefix-create "$@"; }
#       killwine()          { $HOME/bin/wine.sh --wine-user wineuser --run-as killwine "$@"; }
#       export -f wine wine64 wineconsole winecfg regedit winetricks wineprefix-create killwine
#
#     Repalce “wineuser” everywhere with the user you have created beforehand.
#       “killwine” is a handy command, that will make sure you get a CLEAN
#       environment between runs. Look for the note about “semaphores”
#       in this file.
#
#     Add the path, where you keep this file to PATH in your ~/.bashrc.
#       The following commands adds ~/bin as the folder with custom scripts.
#
#       [ "${PATH//*$HOME\/bin*/}" ] && export PATH="$HOME/bin:$PATH"
#
#     Now that you’ve set up the environment, your shells have to re-source
#       the ~/.bashrc or whatever file you placed the settings. If you didn’t
#       understand, what that means, simply log off and log in again.
#
#
#  Enjoy and happy drinking!
#


#  Bulletproof mode on
set -feEuT
shopt -s extglob

 # Bahelite is a library for error handling, better interface, messages etc.
#  Find the lib at https://github.com/deterenkelt/bahelite
. ~/repos/bahelite/bahelite.sh
VERSION="20180614"

show_help() {
	cat <<-EOF
	Usage
	./wine.sh --wine-user <USER> --run-as <WINE_COMMAND> -- [<FILE.EXE> [EXE_OPTS]]

	            USER is the user you created to run wine in your place.
	    WINE_COMMAND is one of the keys: wine, wine64, winecfg, regedit,
	                 winetricks, wineprefix-create, killwine.
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
	                                                  --run-as wineprefix-create

	    Prepending the command with WINEPREFIX is
	    - *optional* for WINE_COMMANDs wine, wine64, winecfg, regedit, winetricks;
	    - *mandatory* for WINE_COMMAND wineprefix-create.
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

[ -v DISPLAY ] || err 'DISPLAY is unset. Run this script inside of an X server.'

#  https://wiki.winehq.org/Wine_User%27s_Guide#Environment_variables

 # In order to get more output from wine, use
#  WINEDEBUG=warn  or  WINEDEBUG=warn+all.
#  WINEDEBUG=loaddll will show, if some DLL doesn’t load.
#
export WINEDEBUG="${WINEDEBUG:-fixme+all,err+all}" \
       WINEARCH \
       WINEPREFIX \
       SDL_AUDIODRIVER=${SDL_AUDIODRIVER:-alsa} \
       __GL_THREADED_OPTIMIZATIONS=${__GL_THREADED_OPTIMIZATIONS:-1} \
       __GL_SYNC_TO_VBLANK=${__GL_SYNC_TO_VBLANK:-0} \
       __GL_YIELD=${__GL_YIELD:-NOTHING}

 # Saves the path to the last chosen wineprefix,
#  so that next time we could set this path as default.
#
write_previous_wprefix() {
	local file="$HOME/.cache/wine.sh/previous_wprefix"
	[ -w "${file%/*}" ] || mkdir -p "${file%/*}"
	echo "$1" > "$file" || return 1
	return 0
}

 # Used in setting default wineprefix, when selecting among several folders.
#
read_previous_wprefix() {
	local file="$HOME/.cache/wine.sh/previous_wprefix"
	[ -r "$file" ] && echo "$(<"$file")" || return 1
	return 0
}

 # If WINEPREFIX wasn’t passed through the environment,
#  find available WINEPREFIX folders in $HOME and wineuser’s
#  $HOME and make the user choose one of them.
#
set_wineprefix() {
	local prefix_list
	if [ -v WINEPREFIX ]; then
		[ -d "$WINEPREFIX" -a -r "$WINEPREFIX" ] || {
			# If we create a new WINEPREFIX, it indeed does not exist.
			# However in this function we must validate the folder name.
			[ "${1:-}" != may_not_exist ] && {
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
			menu -m 2 "Found one WINEPREFIX:
			      ${prefix_list[0]}
			      Choose it?" _Yes_ No
			[ "$CHOSEN" = Yes ] \
				&& WINEPREFIX="/home/${prefix_list[0]}" \
				|| { err 'Aborted.'; return 3; }
		elif [ ${#prefix_list[@]} -eq 0 ]; then
			err "No .wine\* folders found in $HOME and /home/$WINEUSER."
			return 3
		else
			# Trying to set the cursor on the previously used wineprefix
			previous_wprefix=$(read_previous_wprefix)
			for ((i=0; i<${#prefix_list[@]}; i++)); do
				[ "${prefix_list[i]}" = "$previous_wprefix" ] \
					&& prefix_list[$i]="_${prefix_list[i]}_"
			done
			menu -m list 'Choose WINEPREFIX' "${prefix_list[@]}"
			WINEPREFIX="/home/$CHOSEN"
			write_previous_wprefix "$CHOSEN"
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


 # Handles all wine* executables and regedit.
#  $1 – binary name: “wine”, “wine64”, “winetricks”…
#  $2..n — list of arguments for that executable.
#
__wine() {
	local run_as="$1" binary sudo="sudo -u $WINEUSER -H"
	shift
	set_wineprefix || return $?
	case "$run_as" in
		wine|wine64)
			# User Guide says that if we call and .exe directly,
			# wine should be used with options “start” and “/unix”
			# (with unix paths), i.e
			#   wine start /unix /path/to/some/windows.exe
			# But some programs refuse to start this way, and only start
			# without “start /unix”.
			[ $WINEARCH = win32 ] \
				&& binary='/usr/bin/wine' \
				|| binary='/usr/bin/wine64'
			;;
		wineconsole)
			binary='/usr/bin/wineconsole'
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
			binary='/usr/bin/winetricks --force'
			;;
		winepath)
			binary='/usr/bin/winepath'
			;;
		*)
			err 'I am not supposed to run as this command.'
			return 3
	esac
	[ "$WINEPREFIX_OWNER" = "$USER" ] \
		&& $binary "$@" \
		|| $sudo $binary "$@"
	#  Clean emulated wine desktop from icons placed by programs.
	#  killwine() must be able to run without binding to a wineprefix, so these
	#  lines are here, in __wine().
	set +f
	if [ "$WINEPREFIX_OWNER" = "$USER" ]; then
		/bin/rm $WINEPREFIX/drive_c/users/$WINEPREFIX_OWNER/#msgctxt#directory#Desktop/* \
		        $WINEPREFIX/drive_c/users/$WINEPREFIX_OWNER/Desktop/*.lnk \
		        $WINEPREFIX/drive_c/users/Public/Desktop/*.lnk 2>/dev/null
	else
		$sudo /bin/rm $WINEPREFIX/drive_c/users/$WINEPREFIX_OWNER/#msgctxt#directory#Desktop/* \
		              $WINEPREFIX/drive_c/users/$WINEPREFIX_OWNER/Desktop/*.lnk \
		              $WINEPREFIX/drive_c/users/Public/Desktop/*.lnk 2>/dev/null
	fi
	set -f
	return 0
}


killwine() {
	local i
	sudo /usr/bin/pkill -9 -u $WINEUSER
	#  After wine is closed/killed, semaphores that it created, may still hang
	#  in the OS. Certain programs do not like it and refuse to work. An advan-
	#  tage of running wine from a separate user is also that we can clear the
	#  semaphore list safely, without breaking something in the main user’s
	#  session (if we would run wine locally, e.g. in our own ~/.wine32).
	for i in $(ipcs -s | sed -rn "s/.*\s([0-9]+)\s+$WINEUSER.*/\1/p"); do
		ipcrm -s $i
	done
	return 0
}


 # Creates a wineprefix in the specified folder and stuffs it with libraries.
#  Usage:
#    WINERREFIX=/home/wineuser/.wine32-hurr  wineprefix-create
#
#  It is generally advisable to keep at least two bottles: one for programs
#    and one for games. They may even run different versions of system wine
#    binaries.
#  A tip: save a prepared wineprefix to a tar archive and call it
#    .wine32-stuffed for example. Downloading and installing libraries takes
#    a significant time, so it’s good to keep an already prepared wineprefix,
#    when you need a new one. Instead of running this function and starting
#    from scratch each time – just unpack the prepared one!
#
wineprefix-create() {
	[ -v WINEPREFIX ] || {
		err "Pass the folder you want to create as
		     WINEPREFIX=/home/$WINEUSER/.wine32-something wineprefix-create"
		return 3
	}
	set_wineprefix may_not_exist || return $?
	# Maybe some day it will work…
	# shopt -s expand_aliases
	[ -d "$WINEPREFIX" ] && {
		menu -m 2 "$WINEPREFIX still exists. Remove it? [y/N]" Yes _No_
		[ "$CHOSEN" = Yes ] \
			&& sudo -u $WINEUSER -H rm -rf "$WINEPREFIX" \
			|| { err 'Aborted'; return 3; }
	}
	# infow "1. Checking WINEPREFIX in $WINEPREFIX" \
	#       "WINEDEBUG=-all sudo -u $WINEUSER -H wine cmd.exe /c echo %ProgramFiles%" \
	#       force_stderr
	infow "1. Checking WINEPREFIX in $WINEPREFIX" \
	      "WINEDEBUG=-all WINEPREFIX=$WINEPREFIX wineboot" \
	      force_stderr

	info "2. Setting wine options"
	declare -A options=(

		 # Multi-threaded command stream
		#  on | off
		[csmt]=on

		 # Set DirectDrawRenderer to opengl
		#  opengl | gdi
		[ddr]=opengl

		 # Enable subpixel font smoothing
		#  rgb | bgr | disable | gray
		[fontsmooth]=gray

		 # GLSL
		#  enabled | disabled
		#  Disabling is generally not recommended, but on nvidia may be faster.
		[glsl]=disabled

		 # Enable Direct3D multisampling
		#  enabled | disabled
		[multisampling]=enabled

		 # Set DirectInput MouseWarpOverride
		#  force | disable | enabled
		[mwo]=force

		 # Set sound driver
		#  alsa | disabled | oss | coreaudio (mac)
		[sound]=alsa

		 # Strict order removes glitches. If there are no glitches, disabling
		#  it makes things faster.
		#  disabled | enabled
		[strictdrawordering]=disabled

		 # VRAM size, in MB, that wine reports to applications.
		#  Doesn’t affect how many ram they really can take. Only some games
		#  use this.
		#  default | 512 | 1024 | 2048
		#  Using “default” needs GLX_MESA_query_renderer
		[videomemorysize]=$(
			which nvidia-settings &>/dev/null && {
				nvidia-settings --query $DISPLAY/VideoRam \
				| sed -nr '2s/.*\s([0-9]+)\.$/  scale=0; \1 \/ 1024  /p' \
				| bc -q
			} || { echo 'default'; }
		)

		 # Shader versions
		#  0|1|2|3
		[vsm]=3
		[gsm]=3
		[psm]=3

		 # Windows version
		#  win98 | win2k | winxp | win2k3 | vista | win7 | win8 | win10
		[winver]=win7
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

		binkw32
		flash
		ie8
		ie8_kb2936068
		devenum

		#  Don’t install the whole ‘directx9’!
		#  because it will break interaction between those
		#  built in wine, which wine _must_ use to work
		#  properly (e.g. xinput), and those native
		#  installed by the ‘directx9’ command.
		d3dcompiler_43
		d3dx9
		# d3dx10
		# d3dx10_43
		# d3dx11_42
		# d3dx11_43

		physx
		quartz

		# Default windows fonts + cover up for missing glyphs
		corefonts
		unifont

		# Required by many apps
		mfc40
		mfc42
		msxml3
		msxml4
		msxml6
		vcrun2003
		vcrun2005
		vcrun2008
		vcrun2010
		vcrun2012
		vcrun2013
		vcrun2015
		vcrun2017
		dotnet45

		winhttp
		wininet

		# X3DAudio1_7.dll issues
		xact

		xna31
		xna40
	)
	for package in ${packages[@]}; do
		infow "Installing $package" \
		      "WINEPREFIX=$WINEPREFIX sudo -u $WINEUSER -H winetricks \"$package\" >/dev/null" \
		      force_stderr
	done
	type wineprefix-create-postinstall &>/dev/null \
		&& WINEPREFIX="$WINEPREFIX" WINEARCH=$WINEARCH wineprefix-create-postinstall
	return 0
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
			[[ "$2" =~ ^(wine|wine64|wineconsole|winecfg|regedit|winetricks|wineprefix-create|killwine)$ ]] \
				&& RUN_AS="$2" \
				|| { err "Possible arguments to --run-as are: wine, wine64, winecfg, regedit,
				          winetricks, wineprefix-create, killwine"; }
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
	wine|wine64|wineconsole|winecfg|regedit|winetricks)
		__wine "$RUN_AS" "$@" || exit $?
		;;
	wineprefix-create)
		wineprefix-create || exit $?
		;;
	killwine)
		killwine || exit $?
		;;
esac
