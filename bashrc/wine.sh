[ -v DISPLAY ] && {
	# This setup uses a dummy user called sszb that holds all prefixes,
	#   but in order for him to be able to show the windows on our X session,
	#   he must be allowed to do this in the first place.
	xhost +si:localuser:sszb > /dev/null
	export WINEDEBUG="-all" \
		   WINEARCH \
		   WINEPREFIX \
		   __GL_THREADED_OPTIMIZATIONS=1 \
		   __GL_SYNC_TO_VBLANK=0 \
		   __GL_YIELD="NOTHING" \
		   SDL_AUDIODRIVER=alsa

	# In order to get output use
	#     WINEDEBUG=warn wine …
	#   or
	#     WINEDEBUG=warn+all wine …


	# DESCRIPTION
	#     This is general function to do all the jobs.
	# TAKES
	#     [$@] — list of arguments for wine, winetricks etc.
	wine() {
		local arch=32 binary _funcname
		[ -v FUNCNAME[1] ] && _funcname=${FUNCNAME[1]} || _funcname=wine
		case $_funcname in
			wine)
				binary='/usr/bin/wine' ;;
			wine64)
				binary='/usr/bin/wine64'; arch=64 ;;
			winetricks64) arch=64 ;&
			winetricks)
				binary='/usr/bin/winetricks' ;;
			winecfg64) arch=64 ;&
			winecfg)
				binary='/usr/bin/winecfg' ;;
			regedit64) arch=64 ;&
			regedit)
				binary='/usr/bin/regedit' ;;
			*)
				echo 'I am not supposed to run as this command.' >&2
				return 3
		esac
		WINEARCH=win$arch WINEPREFIX=/home/sszb/.wine${arch//32/} sudo -u sszb -H $binary "$@"
		# Clean emulated wine desktop from icons placed by programs
		sudo -u sszb -H /bin/rm /home/sszb/.wine${arch//32/}/drive_c/users/sszb/#msgctxt#directory#Desktop/* \
			/home/sszb/.wine${arch//32/}/drive_c/users/Public/#msgctxt#directory#Desktop/* 2>/dev/null
	}
	wine64() { wine "$@"; }
	winetricks() { wine "$@"; }
	winetricks64() { wine "$@"; }
	winecfg() { wine "$@"; }
	winecfg64() { wine "$@"; }
	regedit() { wine "$@"; }
	regedit64() { wine "$@"; }
	#
	alias killsteam="pkill -9 -f 'hl2.*'; pkill -9 -f steam"
	alias killsszb='sudo -u sszb /usr/bin/killall -9 -u sszb'
	alias kill-my-semaphores='for i in $(ipcs -s | sed -rn "s/.*\s([0-9]+)\s+'$USER'.*/\1/p"); do ipcrm -s $i; done;'
	alias kill-sszb-semaphores="for i in $(ipcs -s | sed -rn 's/.*\s([0-9]+)\s+sszb.*/\1/p'); do ipcrm -s $i; done"
	#
	alias alice="pushd /home/games/Alice; cp linux_config config.cfg; wine alice.exe; popd"
	alias arx="pushd /home/Games/Arx\ Fatalis/ ; ./arx -u/home/Games/Arx\ Fatalis/; popd"
	alias audiosurf="pushd /home/games/audioslurp && wine Launcher.exe && popd"
	alias banished="pushd /home/games/Banished; wine64 Application.exe; popd"
	alias hegemony="pushd /home/games/hegemony; wine Hegemony\ Gold.exe; popd"
	alias hitman="pushd /home/sszb/.wine/drive_c/Games/Hitman_Blood_money; wine HitmanBloodMoney.exe; popd"
	alias hl2-cm="pushd /home/games/steam/SteamApps/common/CM2013/; wine Launcher_EP0.EXE; popd;"
	alias hl2-ep1-cm="pushd /home/games/steam/SteamApps/common/CM2013/; wine Launcher_EP1.EXE; popd"
	alias hl2-ep2-cm="pushd /home/games/steam/SteamApps/common/CM2013/; wine Launcher_EP2.EXE; popd"
	alias hl2-cm-conf="pushd /home/games/steam/SteamApps/common/CM2013/; wine Configurator.EXE; popd"
	alias il2="pushd /home/games/IL2; wine il2fb.exe; popd"
	alias minimetro="$HOME/assembling/minimetro/MiniMetro*x86_64"
	alias s="taskset -c 1-3 steam"
	alias teamviewer="pushd /home/soft_win/teamviewer_8_portable; wine TeamViewer.exe; popd"
	wog() { pushd /home/games/WorldOfGoo; ./WorldOfGoo.bin64; popd; }
	alias zeus="pushd /home/games/Poseidon; wine Zeus.exe; popd"

	wineprefix-setup64() { wineprefix-setup "$@"; }

	#
	# IT DOESN’T WORK PROPERLY FOR WINE64 YET
	#
	# [$1] — '--setoptonly' = quit after setting options
	wineprefix-setup() {
		[ ${FUNCNAME[1]} = wineprefix-setup64 ] \
			&& local WINEARCH=win64 WINEPREFIX=/home/sszb/.wine64 \
			|| local WINEARCH=win32 WINEPREFIX=/home/sszb/.wine
		# Maybe some day it will work…
		# shopt -s expand_aliases
		local w='\e[00;37m'
		local g='\e[00;32m'
		local r='\e[00;31m'
		# stop
		local s='\e[00m'
		# underline white
		local u='\e[04;37m'

		[ -d "$WINEPREFIX" ] && {
			read -n1 -p "$WINEPREFIX still exists. Remove it? [y/N] > "
			echo
			case "$REPLY" in y|Y) sudo -u sszb -H /bin/bash -c "rm -rf \"$WINEPREFIX\"";; esac
		}
		echo -e "$w---] 1. Checking WINEPREFIX in $WINEPREFIX${s}"
		WINEDEBUG=-all sudo -u sszb -H wine cmd.exe /c echo %ProgramFiles% \
			&& echo -e "$w---] [${g}OK${w}]$s" \
			|| echo -e "$w---] [${r}FAIL${w}]$s"
		[ "$1" = checkonly ] && return

		echo -e "\n$w---] 2. Setting wine options:$s"
		declare -A options=(
			[ddr]=opengl # Set DirectDrawRenderer to opengl //gdi
			[fontsmooth]=gray # Enable subpixel font smoothing //rgb,bgr,disable
			[glsl]=enabled # Enable glsl shaders //disabled (may be faster)
			[multisampling]=enabled # Enable Direct3D multisampling //disabled
			[mwo]=force # Set DirectInput MouseWarpOverride to force //disable,enabled
			[psm]=enabled # Set PixelShaderMode to enabled //disabled
			[sound]=alsa # Set sound driver to ALSA //disabled,oss,coreaudio (mac)
			[strictdrawordering]=enabled # //disabled (may make things faster), fixes severe glitches in DE:HR, Tombraider 2013, Metro 2033 etc.
			[videomemorysize]=$((`nvidia-settings --query $DISPLAY/VideoRam | sed -nr '2s/.*\s([0-9]+)\.$/\1/p'`/1024)) # in MiB
			[vsm]=hardware # Set VertexShaderMode to hardware
		)
		[ -v options[ddr] ] || exit 3 # enjoy your fglrx/nouveau/whatever
		for option in "${!options[@]}"; do
			value=${options[$option]}
			echo -e "\n${w}---] $option$s=$value$s"
			sudo -u sszb -H winetricks "$option=$value" >/dev/null \
				&& echo -e "$w---] [${g}OK${w}]$s" \
				|| echo -e "$w---] [${r}FAIL${w}]$s"
		done
		# WIDTH, HEIGHT and DPI are set in ~/preload.sh
		echo -e "\n${w}---] Setting emulated virtual desktop size to ${WIDTH}x${HEIGHT}${s}."
		cat <<EOF >/tmp/vd.reg
ÿþWindows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Wine\Explorer\Desktops]
"Default"="${WIDTH}x${HEIGHT}"
EOF
		chmod 644 /tmp/vd.reg
		sudo -u sszb -H /usr/bin/regedit /tmp/vd.reg \
			&& echo -e "$w---] [${g}OK${w}]$s" \
			|| echo -e "$w---] [${r}FAIL${w}]$s"
		rm /tmp/vd.reg

		echo -e "\n${w}---] Setting display DPI to the actual value of $DPI."
		hex_dpi=`printf "%08x\n" $DPI`
		cat <<EOF >/tmp/vd.reg
ÿþWindows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Hardware Profiles\Current\Software\Fonts]
"LogPixels"=dword:$hex_dpi
EOF
		chmod 644 /tmp/vd.reg
		sudo -u sszb -H /usr/bin/regedit /tmp/vd.reg \
			&& echo -e "$w---] [${g}OK${w}]$s" \
			|| echo -e "$w---] [${r}FAIL${w}]$s"
		rm /tmp/vd.reg

		echo -e "\n${w}---] Disabling dwrite.dll for steam (bug #31374)."
		cat <<EOF >/tmp/no-dwrite.reg
ÿþWindows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Valve\Steam]
"DWriteEnable"=dword:0
EOF
		chmod 644 /tmp/no-dwrite.reg
		# Strange, but it seems functions cannot into aliases… ;_;
		sudo -u sszb -H /usr/bin/regedit /tmp/no-dwrite.reg \
			&& echo -e "$w---] [${g}OK${w}]$s" \
			|| echo -e "$w---] [${r}FAIL${w}]$s"
		rm /tmp/no-dwrite.reg

		[ "$1" = --setoptsonly ] && return

		echo -e "\n${w}---] 3. Installing necessary packages: $s"
		local packages=(
			corefonts # Default windows fonts
			devenum   # Required by many games
			d3dcompiler_43 # Don’t install the whole ‘directx9’!
			d3dx9     #        because it will break interaction between those
			          #        built in wine, which wine _must_ use to work
			          #        properly (e.g. xinput), and those native
			          #        installed by the ‘directx9’ command.
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
			xact      # X3DAudio1_7.dll issues
		)
		for package in ${packages[@]}; do
			echo -e "\n${w}---] Installing $package.${s}" # ${ } just to distiguish.
			sudo -u sszb -H winetricks "$package" >/dev/null \
				&& echo -e "$w---] [${g}OK${w}]$s" \
				|| echo -e "$w---] [${r}FAIL${w}]$s"
		done
	}

}


# If ‘steam servers are too busy (error 2)’ after ‘completing installation’ freezes on 0 or 1%,
#   this is probably a wine issue. Try to reinstall
#   http://www.microsoft.com/en-us/download/details.aspx?id=21835
#   http://www.microsoft.com/en-us/download/details.aspx?id=30679
