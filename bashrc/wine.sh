[ -v DISPLAY ] && {
	xhost +si:localuser:sszb > /dev/null
	export WINEPREFIX=/home/sszb/.wine
	export WINEARCH=win32
	export WINEDEBUG="-all"
	# In order to get output use
	#     WINEDEBUG=warn wine …
	#   or
	#     WINEDEBUG=warn+all wine …
	# export LD_PRELOAD="/lib64/libpthread.so.0 /usr/lib64/libGL.so"
	export __GL_THREADED_OPTIMIZATIONS=0 # May be set to 1 if game supports it
	export __GL_SYNC_TO_VBLANK=0
	export __GL_YIELD="NOTHING"
	export SDL_AUDIODRIVER=alsa
	alias wine='LANG=ru_RU.UTF-8 sudo -u sszb -H /usr/bin/wine'
	alias winetricks='sudo -u sszb -H /usr/bin/winetricks --optout'
	alias winecfg='sudo -u sszb -H /usr/bin/winecfg'
	alias regedit='sudo -u sszb -H /usr/bin/regedit'
	alias kill-semaphores="for i in $(ipcs -s |sed -rn 's/.*\s([0-9]+)\s+sszb.*/\1/p'); do ipcrm -s $i; done"
	# Apps
	#   alias borderlands="WINEDLLOVERRIDES=mmdevapi wine /home/sszb/.wine/drive_c/Games/Borderlands/Binaries/Borderlands.exe"
	#   alias ac="wine /home/sszb/.wine/drive_c/Program\ Files/Ubisoft/Assassin\'s\ Creed/AssassinsCreed_Game.exe &"
	alias alice='pushd /home/games/Alice
	             cp linux_config config.cfg
	             wine alice.exe
	             popd'
	alias audiosurf="pushd /home/games/AudioSurf && wine Launcher.exe && popd"
	alias il2="pushd /home/games/IL2; wine il2fb.exe; popd"
	alias arx="pushd /home/Games/Arx\ Fatalis/ ; ./arx -u/home/Games/Arx\ Fatalis/; popd"
	alias hitman="pushd /home/sszb/.wine/drive_c/Games/Hitman_Blood_money; wine HitmanBloodMoney.exe; popd;"
	alias steam="taskset -c 1-3 steam"
	alias zeus="pushd /home/games/Poseidon; wine Zeus.exe; popd"
	alias hegemony="wine /home/games/Hegemony\ Gold\ -\ Wars\ of\ Ancient\ Greece/Hegemony\ Gold.exe"
	alias banished="pushd /home/gamefiles/Banished; WINEARCH=win64 WINEPREFIX=/home/sszb/.wine64 wine Banished.exe; popd"
	alias minimetro="$HOME/assembling/minimetro/MiniMetro*x86_64"

	alias killsteam="pkill -9 -f 'hl2.*'; pkill -9 -f steam"
	alias killsszb='sudo -u sszb /usr/bin/killall -9 -u sszb'

	# $1 == '--setoptonly' (optional) — quit after setting options
	set_wineprefix() {
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
			[videomemorysize]=1024
			[vsm]=hardware # Set VertexShaderMode to hardware
		)
		for option in "${!options[@]}"; do
			value=${options[$option]}
			echo -e "\n${w}---] $option$s=$value$s"
			sudo -u sszb -H winetricks "$option=$value" >/dev/null \
				&& echo -e "$w---] [${g}OK${w}]$s" \
				|| echo -e "$w---] [${r}FAIL${w}]$s"
		done
		echo -en "\n${w}---] Setting emulated virtual desktop size to "
		echo -e "${WIDTH}x${HEIGHT}${s}." # defined in ~/.preload.sh
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
#   this is wine issue. Reinstall
#   http://www.microsoft.com/en-us/download/details.aspx?id=21835
#   http://www.microsoft.com/en-us/download/details.aspx?id=30679
