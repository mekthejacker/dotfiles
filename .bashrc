# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen!

# This is to dispose of old aliases and function definitions before
#   (re-)sourcing new or rewritten ones.

unalias -a
# If I replace it with
#     unset -f `declare -F | sed 's/^declare -f //g'`
# won’t it break something that have been read from /etc/…?
unset -f `sed -nr "s/^\s*([-_a-zA-Z0-9]+)\(\)\s*\{.*$/\1/p" \
          ~/.bashrc ~/bashrc/* ~/repos/bhlls/bhlls.sh 2>/dev/null`

for opt in autocd cdspell dirspell dotglob extglob globstar \
    no_empty_cmd_completion; do
    shopt -s $opt
done
#for completion_module in eix eselect gentoo git gpg iptables layman man \
#    smartctl ssh strace sysctl taskset tmux udisks watchsh; do
#    eselect bashcomp enable $completion_module &>/dev/null
#done
unset opt #completion_module

# Testing ur PAM
#ulimit -S -n 8192
# Setting the ‘soft’ limit of maximum open files.
ulimit -Sn 4096
set -b  # report exit status of background jobs immediately

export EIX_LIMIT=0
export EDITOR="nano"
export LESS='-R -M --shift 5 -x4'
# Less uses ‘standout’ for search results highlight
#export LESS_TERMCAP_so=$'\E[01;33;03;40m' # red on black
export MPD_HOST=$HOME/.mpd/socket
[ "${PATH//*$HOME\/bin*/}" ] && export PATH="$HOME/bin:$PATH"
[ "${PATH//*$HOME\/\.env*/}" ] && export PATH="$HOME/.env:$PATH"
[ "${PATH//*\/usr\/games\/bin*/}" ] && export PATH="$PATH:/usr/games/bin/"






# Though TERM is kept via SSH’s SendEnv,
#   rxvt-unicode-256color gives messed colours in emacsclient.
# Other working replacement may be screen-256color. rxvt-basic works as a monochrome screen
#[ -v SSH_CLIENT ] && export TERM=xterm-256color

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
[[ $- = *i* ]] || return 0

[ -v ENV_DEBUG ] || {
	rm -rf /tmp/envlogs/* &>/dev/null
	mkdir -m 700 /tmp/envlogs &>/dev/null # /tmp should be on tmpfs
}
# code     file               logfile (under /tmp/envlogs/)
# +    starts the string
# x    /usr/bin/X          x (just for the file name, it’s always present)
# p    ~/.preload.sh       preload
# i    /usr/bin/i3         i3.stdout + i3.stderr
# g    ~/.i3/g…_for_i3bar  gentext4i3bar
# a    ~/.i3/autostart.sh  autostart
# r    ~/bin/run_app.sh    runapp_<app_name>
# q    ~/.i3/on_quit.sh    on_quit
# -    prevents the variable from being empty
export ENV_DEBUG='+'

[ ! -v DISPLAY -a "`tty`" = /dev/tty2 ] && {
	# W! startx IGNORES ~/.xserverrc options if something passed beyond -- !
	# This will use /etc/X11/xorg.conf as a default config
	exec startx -- -nolisten tcp &>/tmp/envlogs/x # … -- -verbose 5 -logverbose=5
	# This was needed when I used to switch between configs.
	# exec startx -- -config xorg.conf$(<~/.xorg.conf.suffix) -nolisten tcp &>/tmp/envlogs/x
	# rm ~/.xorg.conf.suffix &>/dev/null
}

set +f

pushd ~/bashrc >/dev/null
hostnamerc=${HOSTNAME%.*}.sh
#  Exporting functions for one_command_shell
set -o allexport
[ -r $hostnamerc ] && . $hostnamerc
set +o allexport
popd >/dev/null

 # urxvt as a launcher
#  Since regular launchers cannot into bash functions and aliases,
#    the best is to spawn a small terminal window, that would execute
#    just one command and quit.
#  In the i3 config one-command urxvt is bound to “$mod+27” <-- use this
#    string to find the line.
#
one_command_execute() {
	exec &>/dev/null
	# TAB completion puts an extra space after the command.
	READLINE_LINE=${READLINE_LINE%%+([[:space:]])}
	until [ -v all_aliases_expanded ]; do # recursive alias expansion
		# Tab character may be used in user’s aliases.
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

	# 1. Scripts and binaries in $PATH are the easiest things to run.
	# 2. Shell functions may be executed, but must be exported beforehand
	#    with ‘export -f’. This is why I use “allexport” above.
	nohup /bin/bash -c "$READLINE_LINE" &>/tmp/one_command_exec_output &

	 # Use this to wait for programs (not needed for most of them).
	#
	# local c=0 c_max=30
	# [ "$(type -t sleep)" = file ] && local sleep_binary_present=t c_max=300
	#
	# until [ -v time_to_quit ]; do
	# 	# Search for the child of the bash process we spawned.
	# 	xdotool search --onlyvisible --pid $(pgrep -P $!) &>/dev/null \
	# 		&& break
	# 	[ -v sleep_binary_present ] \
	# 		&& sleep .1 \
	# 		|| sleep 1
	# 	[ $((c++)) -eq $c_max ] && local time_to_quit=t
	# done
	exit 0
}

 # This variable is present in the environment, only if ~/.bashrc
#  is sourced by the one-command urxvt. See “urxvt as a launcher” above.
#
[ -v ONE_COMMAND_SHELL ] && {
	## This doesn’t work now, so I have to use default binding C-M-e to
	##   expand aliases before they’ll go to nohup.
	# shopt -s expand_aliases # actually, this may be needed only inside
	#                         # of the subshell
	# bind shell-expand-line
	bind -x '"\C-m":"one_command_execute"'
}

#  As the smart prompt indicates the last command status,
#  ~/.bashrc should return nicely.
return 0

