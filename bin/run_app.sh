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

# Avoiding spontaneous SCIM bug.
#gpg="GTK_IM_MODULE= QT_IM_MODULE= gpg" # That’s strange, but this won’t work.

shopt -s extglob

# Some apps tend to alter files a little while the user data haven’t change
nuisance_apps="firefox|firefox-bin|palemoon"
# Ignore such changes that are smaller or equal to ↓↓↓, in bytes.
max_change_size_to_ignore=15
# Ignore the setting above and always ask, if the size of an encrypted file
#   has reduced.
#ALWAYS_ASK_IF_SMALLER=t

# $1 — absolute path to the actual binary
# $2..n — absolute paths to the *.gpg files with private information, that lay
#     in same folder as their non-encrypted counterparts should be. In my
#     repository, *.gpg files in $HOME are actually symbolic links to the
#    ‘general’ repository.
run_app() {
	which "$1" >/dev/null && {
		local app=$1
		[[ "$app" =~ ^.*/.*$ ]] || {
			echo "This function must be given an absolute path to an actual binary, like /usr/bin/… or so." >&2
			exit 4
		}
		shift 1
		for gpgfile in "$@"; do
			[ -e "$gpgfile" ] && {
				gpgfiles[${#gpgfiles[@]}]="$gpgfile"
				tmpfile="/tmp/decrypted/${gpgfile##*/}"
				tmpfile="${tmpfile%.gpg}"
				tmpfiles[${#tmpfiles[@]}]="$tmpfile"
				GTK_IM_MODULE= QT_IM_MODULE= gpg -qd --output "$tmpfile" --yes "$gpgfile"
				lastmods[${#lastmods[@]}]=`stat -c %Y "$tmpfile"`
				ln -sf "$tmpfile" "${gpgfile%.gpg}"
			}
		done

		while pgrep -xf "^bash ${0##*/}$"; do
			sleep 1
			[ $((i++)) -gt 5 ] && break
		done
		# Testing if actual app is still/already running
		# -a to clarify issues when reading log file
		# x is not necessary since pattern is enclosed in ^$, but to be sure.
		# Some apps are meant to be running in the background, like mpd, so
		#   no && { errormsg && exit; } here
		pgrep -axf "^$app$" || "$app"
		for ((i=0; i<${#tmpfiles[@]}; i++)); do
			[ ${lastmods[$i]} -lt "`stat -c %Y "${tmpfiles[i]}"`" ] && modified=t
		done
		[ -v modified ] && {
			for ((i=0; i<${#gpgfiles[@]}; i++)); do
				unset dont_update
				#   batch, sign & encrypt                   hidden-recipient
				GTK_IM_MODULE= QT_IM_MODULE= gpg --batch -se --output ${tmpfiles[i]}.gpg --yes -R *$ME_FOR_GPG ${tmpfiles[i]} &>>$elog \
					|| i3-nagbar -m "GPG couldn’t encrypt ${tmpfiles[i]##*/}. See $elog for details."
				local old_size=`stat -Lc %s "${gpgfiles[i]}"` # dereference symlinks!
				local new_size=`stat -c %s "${tmpfiles[i]}.gpg"`
				[[ "$old_size" =~ ^[0-9]+$ ]] && [[ "$new_size" =~ ^[0-9]+$ ]] || {
					i3-nagbar -m "Couldn’t compute file sizes for ${tmpfiles[i]##*/}.gpg ($new_size) and ${gpgfiles[i]##*/} ($old_size)."
					exit 5
				}

				local d=+$((new_size-old_size))

				# Some apps tend to alter files a little for no reason :D
				[[ "$app_name" == @($nuisance_apps) ]] \
					&& [ "${d//[+-]/}" -le $max_change_size_to_ignore ] \
					&& local dont_update=t
				[ -v ALWAYS_ASK_IF_SMALLER -a $new_size -lt $old_size ] && {
					Xdialog --title "Private data update" \
						--backtitle "$app_name file $tmpfile has changed" \
						--no-wrap --ok-label=Replace --cancel-label='Keep old' \
						--yesno "And the size seem to have been reduced.

OLD_SIZE: $((old_size/1024)) KiB   NEW_SIZE: $((new_size/1024)) KiB, ${d/+-/-} B change.

Do you want to replace it in the repository?" 0x0 \
						&& unset dont_update || local dont_update=t
				}
				[ -v dont_update ] || {
					cp "${tmpfiles[i]}.gpg" "${gpgfiles[i]}" # not mv! mv erases symlinks.
					[ "`file --mime-type "${gpgfiles[i]}" | sed -nr 's/.*\s(\S+)/\1/p'`" = inode/symlink ] || {
						i3-nagbar -m "${gpgfiles[i]} is not a symlink! Will exit nao."
						exit 6
					}
					pushd ~/repos/general
					git stash
					git add "${gpgfiles[i]#/}" 2>>$elog && {
						git commit -m "Updated ${gpgfiles[i]##*/} for $app_name ${d/+-/-} B." 2>>$elog \
							&& git push 2>>$elog # \
#							↑ ↑ || i3-nagbar -m "Couldn’t push ${gpgfiles[i]##*/} for $app_name. See $elog for details."
						:
					}|| i3-nagbar -m "Couldn’t add ${gpgfiles[i]##*/} for $app_name. See $elog for details."
					git stash pop
					popd
				}
			done
		}
		for ((i=0; i<${#gpgfiles[@]}; i++)); do
			rm ${tmpfiles[i]} ${tmpfiles[i]}.gpg
		done
	}
}

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
	# firefox)
	# 	[ -e /usr/bin/firefox-bin ] \
	# 		&& firefox=/usr/bin/firefox-bin \
	# 		|| firefox=/usr/bin/firefox
	# 	if pgrep -f $firefox &>/dev/null; then
	# 		# Xdialog --msgbox "$*" 0x0
	# 		# $@ is not a plain link, but firefox understands it.
	# 		$firefox -new-tab "$@"
	# 	else
	# 		run_app $firefox \
	# 			~/.mozilla/firefox/profile.default/key3.db.gpg \
	# 			~/.mozilla/firefox/profile.default/signons.sqlite.gpg
	# 	fi
	# 	;;
	# palemoon)
	# 	if pgrep -f /usr/bin/palemoon &>/dev/null; then
	# 		# Xdialog --msgbox "$*" 0x0
	# 		# $@ is not a plain link, but firefox understands it.
	# 		/usr/bin/palemoon -new-tab "$@"
	# 	else
	# 		run_app /usr/bin/palemoon \
	# 			"$HOME/.moonchild productions/pale moon/profile.default/key3.db.gpg" \
	# 			"$HOME/.moonchild productions/pale moon/profile.default/signons.sqlite.gpg"
	# 	fi
	# 	;;
	geeqie)
		# This entry is only to work around the drawbacks of interface:
		#  - you can’t select several files and click a bookmark in Sort
		#    manager to move them — it’ll only copy the first selected file;
		#  - if you select several files and explicitly choose to move them
		#    by selecting the command from the RMB menu, bookmarks there aren’t
		#    what Sort manager had. To keep them intact, let’s replace the
		#    [bookmarks] section in the history file (which is actually
		#    another config file) to reflect current condition of [sort_manager].
		sed -ri '/\[sort_manager]/,/^$/ {
		             s/^(\s*|\[sort_manager])$/&/;t;H
		         }
		         /\[bookmarks]/,/^$/ {
		             /\[bookmarks]/!d
		             G;s/\n\n/\n/;s/$/\n/
		         }' ~/.config/geeqie/history
		run_app /usr/bin/geeqie # ~/.config/geeqie/history.gpg ~/.config/geeqie/geeqierc.xml
		;;
	mpd)
		GTK_IM_MODULE= QT_IM_MODULE= gpg -qd --yes --output /tmp/decrypted/mpd.conf.common ~/.mpd/mpd.conf.common.gpg
		sed "s/USER/$USER/g" /tmp/decrypted/mpd.conf.common > /tmp/decrypted/mpd.conf
		[ -e ~/.mpd/mpd.conf.$HOSTNAME ] && cat ~/.mpd/mpd.conf.$HOSTNAME \
			>> /tmp/decrypted/mpd.conf
		ln -sf /tmp/decrypted/mpd.conf ~/.mpd/mpd.conf
		run_app /usr/bin/mpd
		;;
	mpdscribble)
		# Actually mpdscribble would require a delay, because it daemonizes
		#   after launch (if only --no-daemon option hasn’t been passed),
		#   but since its config isn’t a subject to change, it’s not relevant.
		run_app /usr/bin/mpdscribble \
			~/.mpdscribble/mpdscribble.conf.gpg
		;;
	mpv)
		mpc pause
		/usr/bin/mpv "$@"
		mpc play
		;;
	pidgin)
		run_app /usr/bin/pidgin
#		run_app /usr/bin/pidgin \
#			~/.purple/accounts.xml.gpg
		;;
	shutdown)
		#~/.i3/on_quit.sh
		pkill -HUP gpg-agent # clear cache
		sudo /sbin/init 0
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
