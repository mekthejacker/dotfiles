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

# exec &>~/runapp.log
# set -x 
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
		while pgrep -f "^bash ${0##*/}"; do
			sleep 1;
			[ $((i++)) -gt 5 ] && break
		done
		pgrep -af "^$app\b" || $app # -a for debug
		for ((i=0; i<${#files[@]}; i++)); do
			[ ${lastmods[$i]} -lt "`stat -c %Y "${tmpfiles[$i]}"`" ] && modified=t
		done
		[ -v modified ] && {
			cd ~/repos/general
			for ((i=0; i<${#files[@]}; i++)); do
				gpg --batch -se --output ${files[$i]} --yes -R *dete ${tmpfiles[$i]} \
					|| zenity --error --text="GPG couldn’t encrypt “${tmpfiles[$i]}”."
				git add ${files[$i]} || local git_error=t
			done
			[ -v git_error ] || {
				git commit -m "Updated private data for $app." \
					&& git push || local git_error=t
			}
			[ -v git_error ] && zenity --error \
				--text="Couldn’t push changes for “$app” files.\n${tmpfiles[@]}"
		}
		for ((i=0; i<${#files[@]}; i++)); do
			rm ${tmpfiles[$i]}
		done
	}
}

# NB: only actual binaries with absolute paths here!
case ${0##*/} in
	firefox)
		[ -e /usr/bin/firefox-bin ] \
			&& firefox=/usr/bin/firefox-bin \
			|| firefox=/usr/bin/firefox
		if pgrep -f $firefox &>/dev/null; then
			# zenity --info --text="$*"
			# $@ is not a plain link, but firefox understands it.
			$firefox -new-tab $@
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
		run_app /usr/bin/mpdscribble \
			~/.mpdscribble/mpdscribble.conf.gpg
		;;
	pidgin)
		run_app /usr/bin/pidgin \
			~/.purple/accounts.xml.gpg
		;;
	shutdown)
		kill -HUP `pgrep gpg-agent` # clear cache
		sudo /sbin/shutdown $@
		;;
	*)
		cat <<EOF
Usage:
    Just use symbolic links:
    ~/bin/firefox -> ~/bin/run_app.sh
EOF
		exit 3
		;;
esac
