#!/usr/bin/env bash

# run_app.sh
# This substitute for the actual binaries allows to decrypt private data
#   in configuration files from the repository before the actual application
#   starts. Decrypted file are to be placed into /tmp/decrypted/ which is
#   supposed to reside on a temporary filesystem. The data are then encrypted
#   after application is closed (in case it were modified during the runtime).
# This script is a single file, its behaviour decided depending on what filename
#   it was called as.
# This all works on an assumption that
#   a) encrypted files are in the repository and have .gpg extension. Actual
#      file in repository represented by a symlink following to /tmp/decrypted/.
#   b) ~/.xinitrc has
#        export PATH="$HOME/bin:$PATH"
#      in order to make this hack work transparently for any shell or program
#      invoking the command that is supposed to call the binary.

# $1 — absolute path to the actual binary
# $2..n — absolute paths to files with private information.
#         These files supposed to reside in repository and have .gpg extension.
run_app() {
	which "$1" >/dev/null && {
		local app=$1
		shift 1
		for file in "$@"; do
			[ -e "$file" ] && {
				files[${#files[@]}]="$file"
				tmpfile="/tmp/decrypted/${file##*/}"
				tmpfile="${tmpfile%.gpg}"
				tmpfiles[${#tmpfiles[@]}]="$tmpfile"
				gpg -qd --output "$tmpfile" --yes "$file"
				lastmods[${#lastmods[@]}]=`stat -c %Y "$tmpfile"`
			}
		done

		while pgrep -xf "^bash ${0##*/}$"; do
			sleep 1;
			[ $((i++)) -gt 5 ] && break
		done
		# Testing if actual app is still/already running
		# -a to clarify issues when reading log file
		# x is not necessary since pattern is enclosed in ^$, but to be sure.
		# Some apps are meant to be running in the background, like mpd, so
		#   no && { errormsg && exit; } here
		pgrep -axf "^$app$" || $app
		for ((i=0; i<${#files[@]}; i++)); do
			[ ${lastmods[$i]} -lt "`stat -c %Y "${tmpfiles[i]}"`" ] && modified=t
		done
		[ -v modified ] && {
			for ((i=0; i<${#files[@]}; i++)); do
				unset dont_update
				#   batch, sign & encrypt                   hidden-recipient
				gpg --batch -se --output ${tmpfiles[i]}.gpg --yes -R *$ME_FOR_GPG ${tmpfiles[i]} 2>$elog \
					|| i3-nagbar -m "GPG couldn’t encrypt ${tmpfiles[i]##*/}. See $elog for details."
				local old_size=`stat -Lc %s "${files[i]}"` # dereference symlinks!
				local new_size=`stat -c %s "${tmpfiles[i]}.gpg"`
				[[ "$old_size" =~ ^[0-9]+$ ]] && [[ "$new_size" =~ ^[0-9]+$ ]] || {
					i3-nagbar -m "Couldn’t compute file sizes for ${tmpfiles[i]##*/}.gpg ($new_size) and ${files[i]##*/} ($old_size)."
					exit 6
				}

				local d=+$((new_size-old_size))

				# Firefox tends to alter files a little for no reason :D
				[ "$app_name" = firefox -o "$app_name" = firefox-bin ] \
					&& [ "${d//[+-]/}" -lt 11 ] \
					&& local dont_update=t
				[ $new_size -lt $old_size ] && {
					zenity --question --no-wrap --text "$app_name file $tmpfile has changed, but seem to have lower size.\n\nOLD_SIZE: $((old_size/1024)) KiB   NEW_SIZE: $((new_size/1024)) KiB, ${d/+-/-} B change.\n\nDo you want to replace it in the repository?" \
					       --ok-label='Replace' --cancel-label='Keep old' || local dont_update=t
				}
				[ -v dont_update ] || {
					cp ${tmpfiles[i]}.gpg ${files[i]} # not mv! mv erases symlinks.
					[ "`file --mime-type ${files[i]} | sed -nr 's/.*\s(\S+)/\1/p'`" = inode/symlink ] || {
						i3-nagbar -m "${files[i]} is not a symlink! Will exit nao."
						exit 7
					}
					pushd ~/repos/general
					git add ${files[i]#/} 2>>$elog && {
						git commit -m "Updated ${files[i]##*/} for $app_name ${d/+-/-} B." 2>>$elog \
							&& git push 2>>$elog \
							|| i3-nagbar -m "Couldn’t push ${files[i]##*/} for $app_name. See $elog for details."
						[ 1 -eq 1 ]
					}|| i3-nagbar -m "Couldn’t add ${files[i]##*/} for $app_name. See $elog for details."
					popd
				}
			done
		}
		for ((i=0; i<${#files[@]}; i++)); do
			rm ${tmpfiles[i]} ${tmpfiles[i]}.gpg
		done
	}
}

app_name=${0##*/}
[ "${ENV_DEBUG/*r*/}" ] || {
	elog=/tmp/envlogs/runapp_$app_name
	exec &>$elog
	set -x
}

case $app_name in
	# NB: only actual binaries with absolute paths here!
	firefox)
		[ -e /usr/bin/firefox-bin ] \
			&& firefox=/usr/bin/firefox-bin \
			|| firefox=/usr/bin/firefox
		if pgrep -f $firefox &>/dev/null; then
			# zenity --info --text="$*"
			# $@ is not a plain link, but firefox understands it.
			$firefox -new-tab "$@"
		else
			run_app $firefox \
				~/.mozilla/firefox/profile.default/key3.db.gpg \
				~/.mozilla/firefox/profile.default/signons.sqlite.gpg
		fi
		;;
	mpd)
		gpg -qd --yes --output /tmp/decrypted/mpd.conf.common ~/.mpd/mpd.conf.common.gpg
		cat /tmp/decrypted/mpd.conf.common > /tmp/decrypted/mpd.conf
		[ -e ~/.mpd/mpd.conf.$HOSTNAME ] && cat ~/.mpd/mpd.conf.$HOSTNAME \
			>> /tmp/decrypted/mpd.conf
		run_app /usr/bin/mpd
		;;
	mpdscribble)
		# Actually mpdscribble would require a delay, because it daemonizes
		#   after launch (if only --no-daemon option hasn’t been passed),
		#   but since its config isn’t a subject to change, it’s not relevant.
		run_app /usr/bin/mpdscribble \
			~/.mpdscribble/mpdscribble.conf.gpg
		;;
	pidgin)
		run_app /usr/bin/pidgin \
			~/.purple/accounts.xml.gpg
		;;
	shutdown)
		~/.i3/on_quit.sh
		kill -HUP `pgrep gpg-agent` # clear cache
		sudo /sbin/shutdown $@
		;;
	*)
		cat <<"EOF"
Usage:
    Just use symbolic links:
    ln -s ~/bin/run_app.sh ~/bin/firefox

Don’t forget to `export PATH="$HOME/bin:$PATH"`!
EOF
		exit 3
		;;
esac
