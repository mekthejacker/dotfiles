# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !

# This is to dispose of old aliases and function definitions before
#   (re-)sourcing new or rewritten ones.

unalias -a
# If I replace it with
#     unset -f `declare -F | sed 's/^declare -f //g'`
# won’t it break something that have been read from /etc/…?
unset -f `sed -nr "s/^\s*([-_a-zA-Z0-9]+)\(\)\s*\{.*$/\1/p" \
          ~/.bashrc ~/bashrc/* 2>/dev/null`

[ -v ENV_DEBUG ] || {
	rm -rf /tmp/envlogs/* &>/dev/null
	mkdir -m 700 /tmp/envlogs &>/dev/null # /tmp should be on tmpfs
}
# code     file               logfile (under /tmp/envlogs/)
# x    /usr/bin/X          x (just for the mention, it’s always present)
# p    ~/.preload.sh       preload
# i    /usr/bin/i3         i3.stdout + i3.stderr
# g    ~/.i3/g…_for_i3bar  gentext4i3bar
# a    ~/.i3/autostart.sh  autostart
# r    ~/bin/run_app.sh    runapp_<app_name>
# q    ~/.i3/on_quit.sh    on_quit
# -    prevents the variable to be empty
export ENV_DEBUG=-pq
for opt in autocd cdspell dirspell dotglob extglob globstar \
    no_empty_cmd_completion; do
    shopt -s $opt
done
for completion_module in eix eselect gentoo git gpg iptables layman man \
    smartctl ssh strace sysctl taskset tmux udisks; do
    eselect bashcomp enable $completion_module &>/dev/null
done
unset opt completion_module
# man bash says that non-login shells do not source /etc/profile and
#   ~/.bash_profile. My shells are non-login, however, they have PATH set
#   and they source ~/.bash_profile (which is sourcing this file
#   in its turn). A miracle.
. /etc/profile.d/bash-completion.sh

# Testing ur PAM
#ulimit -S -n 8192
# Setting the ‘soft’ limit of maximum open files.
ulimit -Sn 4096
set -b # report exit status of background jobs immediately

export DEPLOY_EXCLUDE_DIRS="$HOME/.ssh|$HOME/.gnupg"
export EIX_LIMIT=0
export EDITOR="emacsclient -c -nw"
export LESS="$LESS -x4"
export MPD_HOST=$HOME/.mpd/socket
#grep -qF '/assembling/' <<<"$PATH" \
#	|| export PATH="$PATH:~/assembling/android-sdk-linux/platform-tools/:~/assembling/android-sdk-linux/tools/"
grep -qF '/usr/games/bin/' <<<"$PATH" \
	|| export PATH="$PATH:/usr/games/bin/"
export PS1="\[\e[01;34m\]┎ \w\n\[\e[01;34m\]┖ \
\`echo \"scale=2; \$(cut -d' ' -f2 </proc/loadavg) /\
    \$(grep ^processor </proc/cpuinfo | wc -l)\" | bc\` \
\[\e[01;32m\]\
\`[ \u = \"$ME\" ] \
    ||{ [ \u = root ] && echo -n \"\[\e[01;31m\]\"; } \
|| echo -n \"\[\e[01;37m\]\u \"\`\
\[\e[01;32m\]\
at \h \
\[\e[01;34m\]\\$\[\e[00m\] "

## Aliases caveats and hints:
## 1. All innder double quotes must be escaped
#     alias preservequotespls="echo \"naive example!\""
## 2. Every call of subshell must be escaped or it will be executing
#     at the time this file loads.
#     alias dontlistmyhomefolderpls="for i in \`ls\`; do ls $i; done"
## 3. To prevent early expanding of variable names, one can use single
#     quotes or escaping, or both if situation requires so.
#     alias hisbashrcpls="sudo -u another_user /bin/bash -c 'nano \$HOME/.bashrc'"
## 4. Aliases can have multiple lines
#     alias plsplsplsdontbreak="echo some stuff # this is comment
#                               echo lol second line # another comment"

# add to todo list
a() { echo "$@" >> ~/todo; }
# delete from todo list
d() {
    [ "$1" = '-' ] && echo -n >~/todo || {
        for i in $@; do
            [[ "$i" =~ ^[0-9]+$ ]] && sed -i $1d ~/todo
        done
    }
}
alias bc="bc -q"
alias ec="emacsclient -c -nw"
alias erc="emacsclient -c -nw ~/.bashrc"
alias grep="grep --color=auto"
# pinentry doesn’t like scim
alias gpg="GTK_IM_MODULE= QT_IM_MODULE= gpg"
alias ls="ls --color=auto"
alias re=". ~/.bashrc" # re-source
spr="| curl -F 'sprunge=<-' http://sprunge.us" # add ?<lang> for line numbers
#alias td="todo -A "
#alias tdD="todo -D "
alias tmux="tmux -u -f ~/.tmux/config -S $HOME/.tmux/socket"
alias deploy="/root/scripts/deploy_configuration.sh "

#[ -v SSH_CLIENT ] && . ~/.preload.sh

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
[[ $- = *i* ]] || return 0

[ ! -v DISPLAY -a "`tty`" = /dev/tty2 ] && {
	# W! startx IGNORES ~/.xserverrc options if something passed beyond -- !
	# This will use /etc/X11/xorg.conf as a default config
	exec startx -- -nolisten tcp &>/tmp/envlogs/x # … -- -verbose 5 -logverbose=5
	# This was needed when I used to switch between configs.
	# exec startx -- -config xorg.conf$(<~/.xorg.conf.suffix) -nolisten tcp &>/tmp/envlogs/x
	# rm ~/.xorg.conf.suffix &>/dev/null
}

pushd ~/bashrc >/dev/null
hostnamerc=${HOSTNAME%.*}.sh
[ -r $hostnamerc ] && . $hostnamerc
popd >/dev/null

# This is for one-command urxvt
one_command_execute() {
	exec &>/dev/null
	# TAB completion puts an extra space after the command.
	READLINE_LINE=${READLINE_LINE%%+([[:space:]])}
	until [ -v all_aliases_expanded ]; do # recursive alias expansion
		# Tabulation cahracter may be used in user’s aliases.
		local first_word=${READLINE_LINE%%[[:space:]]*}
		[ "$first_word" = "$old_first_word" ] && break # to prevent a loop
		alias -p | grep -q "^alias $first_word='.*'$" && {
			local cmd=`alias -p | sed -nr "s/^alias $first_word='(.*)'$/\1/p"`
			# escape all special characters in the expanded alias is more
			#   consuming, than just stripping its name and combining
			#   a new string.
			READLINE_LINE=${READLINE_LINE/#$first_word/}
			READLINE_LINE="$cmd $READLINE_LINE"
			local old_first_word="$first_word"
		} || local all_aliases_expanded=t
	done
	(nohup $READLINE_LINE) &
	local c=0
	until [ $((c++)) -eq 3 ]; do
		xdotool search --onlyvisible --pid $! &>/dev/null && break
		sleep 1
	done
	exit
}

[ -v ONE_COMMAND_SHELL ] && {
	PS1='\[\e[01;37m\](☞°ヮ°)☞\[\e[00m\] '
	## This doesn’t work now, so I have to use default binding C-M-e to
	##   expand aliases before they’ll go to nohup.
	# shopt -s expand_aliases # actually, this may be needed only inside
	#                         # of the subshell
	# bind shell-expand-line
	bind -x '"\C-m":"one_command_execute"'
}

# Compresses all png files in CWD
# $1 — minimum size, under which no compression shall be done
#      If not set 1M (1MiB) is the default.
compress_screenshot() {
	[ "$1" ] && {
		[[ "$1" =~ ^[0-9]+[KMG]$ ]] && min_size=${1/K/k} \
			||{ echo "The parameter should conform to that pattern: [0-9]+[KMG]." >&2; return 3; }
	}|| min_size=1M
	crush() {
		which pngcrush &>/dev/null && {
			pngcrush -reduce "$1" "/tmp/$1"
			mv "/tmp/$1" "$1"
		}
	# which convert &>/dev/null && [ -v JPEG_CONVERSION ] && {
	# 	convert "$shot" -quality $JPEG_CONVERSION "${shot%.*}.jpg"
	# 	rm "$shot"
	# }
	}
	export -f crush
	find -iname "*.png" -size +$min_size -printf "%f\n" | parallel --eta crush
	export -nf crush
}

# Copies MPD playlist to a specified folder.
# $1 — path to playlist file (~/.mpd/playlists/…)
# $2 — where to copy
copy_playlist() {
	local playlist="$1"
	local dest="$2"
	[ -f "$HOME/.mpd/playlists/${playlist}.m3u" ] \
		&& local playlist="$HOME/.mpd/playlists/${playlist}.m3u"
	[ -f "$playlist" ] && [ -d "$dest" -a -w "$dest" ] && {
		eval mpd_library_path="`sed -nr 's/^\s*music_directory\s+"(.*)"/\1/p'\
		                   ~/.mpd/mpd.conf`"
		while read filepath; do
			filepath="${filepath/$mpd_library_path/}"
			cp -v  "$mpd_library_path/$filepath" "$dest"
		done < "$playlist"
	} || echo -e 'Usage:\ncopy_playlist <playlist file> <directory to copy to>'
}

# $1 — filename to fix figure dashes in
fix_fdash() {
	[ -w /tmp/c ] && sed -ri 's/^- (.*)$/‒ \1/g' /tmp/c
}

mount_box() {
	gpg -qd --output /tmp/decrypted/secrets.`date +%s` ~/.davfs2/secrets.gpg
	sudo /root/scripts/mount_box.sh $USER &
}

umount_box() {
	sudo /root/scripts/mount_box.sh $USER umount &
}

# TAKES:
#     $1 — file name to upload.
spr() {
	[ -r "$1" ] || {
		echo 'Pass a file name to paste.'
		return 3
	}
	#firefox http://sprunge.us/aXZI?py#n-7
	cat "$1" | curl -F 'sprunge=<-' http://sprunge.us
}
