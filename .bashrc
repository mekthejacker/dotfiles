# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.

for opt in autocd cdspell dirspell dotglob extglob globstar \
	no_empty_cmd_completion; do
	shopt -s $opt
done
for completion_module in eix eselect gentoo git iptables layman man smartctl \
	ssh strace sysctl taskset tmux udisks; do 
	eselect bashcomp enable $completion_module &>/dev/null
done
unset opt completion_module
# man bash says that non-login shells do not source /etc/profile and 
#   ~/.bash_profile. My shells are non-login, however, they have PATH set
#   and thery sourcing ~/.bash_profile (which is sourcing this file 
#   in its turn). A miracle.
. /etc/profile.d/bash-completion.sh
unalias -a

pushd ~/bashrc >/dev/null
hostnamerc=${HOSTNAME%.*}.sh
[ -f $hostnamerc ] && [ -r $hostnamerc ] && . $hostnamerc
popd >/dev/null

# Testing ur PAM
#ulimit -S -n 8192
# Setting the ‘soft’ limit of maximum open files.
ulimit -Sn 4096

export EIX_LIMIT=0
export EDITOR="emacsclient -c -nw" # emacs -new -bg \"#333\"
export LESS="$LESS -x4"
export MPD_HOST=$HOME/.mpd/socket
export PATH="$PATH:~/assembling/android-sdk-linux/platform-tools/:~/assembling/android-sdk-linux/tools/:/usr/games/bin/"
export PS1="\[\e[01;34m\]┎ \w\n┖ \
\`echo \"scale=2; \$(cut -d' ' -f2 </proc/loadavg) /\
    \$(grep ^processor </proc/cpuinfo | wc -l)\" | bc\` \
\[\e[01;32m\]\
\`[ \u = \"$ME\" ] || { \
    [ \u = root ] && echo -n \"\[\e[01;31m\]\"; \
} || echo -n \"\[\e[01;37m\]\u \"\`\
\[\e[01;32m\]at \h \
\[\e[01;34m\]\\$\[\e[00m\] "
export REPOS_DIR=$HOME/repos

## Aliases caveats and hints:
## 1. Any double quotes must be escaped
#     alias first="echo \"naive example\""
## 2. Any execution expression must be escaped or they will execute at the time 
##    this file loads.
#     alias second="for i in \`ls\`; do ls $i; done"
## 3. Aliases can have multile lines
#     alias third="echo some stuff # this is comment
#                  echo lol second line # another comment"
#
alias e="$EDITOR"
alias ec="emacsclient -c -nw"
alias emc="emacsclient"
alias ls="ls --color=auto"
alias td="todo -A "
alias tdD="todo -D "
alias tmux="tmux -u -f ~/.tmux/config -S $HOME/.tmux/socket"
alias deploy="/root/deploy_configuration.sh "

[[ $- = *i* ]] || return
[ ! -v DISPLAY -a "`tty`" = /dev/tty2 ] && {
	# W! startx IGNORES ~/.xserverrc options if something passed beyond -- !
	exec startx -- -config xorg.conf$(<~/.xorg.conf.suffix) -nolisten tcp &>~/x.log
	rm ~/.xorg.conf.suffix &>/dev/null
}

# This is for one-command urxvt
one_command_execute() {
	(nohup $READLINE_LINE ) &
    exit
}

[ -v ONE_COMMAND_SHELL ] && {
	PS1=
	bind -x '"\C-m":"one_command_execute"'
	# bind -x '"^[":"exit"'
}

# Compresses all png files >1M in CWD
compress_screenshot() {
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
	find -iname "*.png" -size +1M -printf "%f\n" | parallel --eta crush
	export -nf crush
}


# Copies MPD playlist to a specified folder.
# $1 — path to playlist file (~/.mpd/playlists/…)
# $2 — where to copy
copy_playlist() {
	[ -f "$1" ] && [ -d "$2" ] && [ -w "$2" ] && {
		eval mpd_library_path="`sed -nr 's/^\s*music_directory\s+"(.*)"/\1/p'\
		                   ~/.mpd/mpd.conf`"
		while read filepath; do
			cp -v  "$mpd_library_path/$filepath" "$2"
		done < "$1"
	} || echo -e 'Usage:\ncopy_playlist <playlist file> <directory to copy to>'
}
