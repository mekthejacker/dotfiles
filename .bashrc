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
set -b # report exit status of background jobs immediately

export EIX_LIMIT=0
export EDITOR="nano"
export LESS='-R -M --shift 5 -x4'
# Less uses ‘standout’ for search results highlight
#export LESS_TERMCAP_so=$'\E[01;33;03;40m' # red on black
export MPD_HOST=$HOME/.mpd/socket
[ "${PATH//*$HOME\/bin*/}" ] && export PATH="$HOME/bin:$PATH"
[ "${PATH//*$HOME\/\.env*/}" ] && export PATH="$HOME/.env:$PATH"
[ "${PATH//*\/usr\/games\/bin*/}" ] && export PATH="$PATH:/usr/games/bin/"


# ┎ (chroot) /
# ┖ .03 at home #
#
#
# ┎ <if we’re in a chroot’ed environment> <current working directory>
# ┖ <loadavg> <user if bash host != our hostname> <at hostname>  <git hints>  <# for root|$otherwise>
#
gen_prompt() {
	local \
		last_cmd_exit_code=$? \
		prompt_char='\\$' \
		b='\[\e[01;34m\]' \
		g='\[\e[01;32m\]' \
		w='\[\e[01;37m\]' \
		r='\[\e[01;31m\]' \
		s='\[\e[00m\]' \
		git_status= error= chroot=
	export PS1=''
	[ -v ONE_COMMAND_SHELL ] && {
		# printf '\33]50;%s\007' "xft:DejaVu Sans mono:autohint=true:antialias=true:pixelsize=14,xft:Kochi Gothic"
		export PS1="${w}(☛＾ヮ°)☛${s} "  # See ~/.Xresources for urxvt fonts!
		# printf '\33]50;%s\007' "xft:Terminus,xft:Kochi Gothic"
		return 0
	}
	gen_git_status() {
		# I don’t need it for my dotfiles and general repos,
		# it would only mess with my aliases
		[ "$PWD" -ef "$HOME" ] && {
			# ▣▤▥▧▩◍◈◇◆◛◚◻◼◽◾
			return 0
		}
		local branch status staged unstaged behind ahead conflicts mark
		declare -g error git_status
		if ! status=`gis --porcelain -b 2>/dev/null`; then
			if [ $? -ne 128 ]; then
				error='Couldn’t get git status.'
				return 3
			else
				return 0  # 128 = not a git repo
			fi
		fi
		if branch=`git rev-parse --abbrev-ref HEAD  2>/dev/null`; then
			[ "$branch" = HEAD ] && branch='detached'
		else
			error='Couldn’t determine git branch.'
			return 3
		fi
		# unpushed=`set -e; exec 2>/dev/null; git --no-pager log --no-color --oneline  @{push}.. | wc -l` || {
        #     error='Couldn’t get the number of unpushed commits.'
        #     return 3
        # }
		# [ $unpushed -eq 0 ] && unset unpushed
		# ±̑
		#           ## master...origin/master [ahead 1, behind 1]  ↓
		[[ "$status" =~ ^$'\t'?##[^$'\n']+\[(ahead\ ([0-9]+))?(,\ )?(behind ([0-9]+))?\] ]] && {
			[ "${BASH_REMATCH[2]}" ] && ahead=${BASH_REMATCH[2]}
			[ "${BASH_REMATCH[5]}" ] && behind=${BASH_REMATCH[5]}
		}
		if [[ "$status" =~ $'\n'(DD|AU|UD|UA|DU|AA|UU){2}\  ]]; then
			conflicts=t mark='M'
		else
			[[ "$status" =~ $'\n'\ ?[MARC]\  ]] && staged=t
			[[ "$status" =~ $'\n'\?\?\  ]] && unstaged=t
			[ -v ahead ] && mark='_'  # unpushed commits
			[ -v staged ] && mark='+'  # added, but not committed
			[ -v ahead -a -v staged ] && mark='±'
			[ -v unstaged ] && { [ "$mark" ] && mark+='̃' || mark+=' ̃'; }  # untracked
			# U+0303 Combining tilde.
			# U+0302 Combining circumflex and U+0311 Combining inverted breve are fine too.
		fi
		# Assembling status line
		git_status=" ${w}${behind:+$behind }$branch${ahead:+ $ahead}${mark:+ $mark}${s}  "
	}
	gen_git_status
	PS1+="${error:+${r}$error${s}\n}"
	[ $UID -eq 0 ] && {
		# If we are root, check if we’re in a chrooted environment
		[ "$(stat -c %d:%i '/')" != "$(stat -c %d:%i '/proc/1/root/.')" ] \
			&& chroot="${s}(chroot) ${b}"
	}
	PS1+="${b}┎ $chroot$PWD\n${b}┖ "
	case $USER in
		"$ME")
			PS1+="$g"
			;;
		root)
			PS1+="$r"
			prompt_char=$'#'
			;;
		*)
			PS1+="${w}$USER ${b}"
			;;
	esac
	PS1+="at $HOSTNAME"
	# Print the prompt character twice if last command exited
	#   with something other than 0.
	# echo '$last_cmd_exit_code = ' $last_cmd_exit_code
	# [ $last_cmd_exit_code -eq 0 ] || prompt_char="\\\$-$last_cmd_exit_code"
	[ $last_cmd_exit_code -eq 0 ] || prompt_char="$prompt_char$prompt_char"
	PS1+=" $git_status${b}$prompt_char${s} "
	:
}
export PROMPT_COMMAND="gen_prompt"

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

alias bc="bc -q"
alias ec="emacsclient -c -nw"
alias emc="emacsclient"
alias erc="emacsclient -c -nw ~/.bashrc"
alias ffmpeg="ffmpeg -hide_banner"
alias ffprobe="ffprobe -hide_banner"
alias fm="font-manager"
alias hu="hugo"
alias hus="hugo server --watch --source ~/repos/goen/"
alias husd="hugo server --watch --source ~/repos/goen/ --buildDrafts --destination ~/repos/goen/dev"
alias grep="grep --color=auto"
# git
alias gash="git stash"
alias gi='git'
alias gia='git add'
alias giaa='git add --all'
alias gib='git branch'
alias gic='git commit'
alias gica='git commit -a'
alias gicm='git commit -m'
alias gict='git commit -t'  # Use a template file
alias gicam='git commit -am'
gicat() {
	[ "$PWD" = "$HOME" ] && {
		echo 'Cannot run from HOME due to git().' >&2
		return 3
	}
	local cur_worktree commit_desc commit_desc_path
	cur_worktree=`git rev-parse --show-toplevel`
	commit_desc="future_commit"
	commit_desc_path="$cur_worktree/$commit_desc"
	[ -r "$commit_desc_path" ] || {
		echo "‘$commit_desc’ wasn’t found in ‘$cur_worktree’!" >&2
		return 3
	}
	git commit -a -t "$commit_desc_path"  # Use a template file
}
alias gicamend='git commit -a --amend'  # after editing the wrongly commited files
alias gico='git checkout'  # checkout may also take args in form [commit] <file>
alias gif='git fetch'
alias giff='git diff'
alias giffbase='git diff --base'  # against base file
alias giffours='git diff --ours'  # against our changes
alias gifftheirs='git diff --theirs'  # against their changes
alias gil='git ls-files'
alias gilog='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset" --abbrev-commit --date=relative'
alias gilog2='git log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'
alias gilog3='git log --all --graph --decorate'
alias gilogp='git log -p '  # changes in file over time
alias gipa='git format-patch'  # …origin
alias gire='git revert'  # revert a specific commit
alias giread='git revert HEAD'  # reverts the last commit
alias gire='git revert'
alias gire='git revert'
alias gis='git status'
alias gism='git submodule'
alias gism-add='git submodule add'
alias gism-deinit='git submodule deinit'
alias gism-init='git submodule init'
alias gism-s='git submodule status'
alias gism-upd='git submodule update'
alias gism-sync='git submodule sync'
alias gull='git pull'
alias gush='git push'
# DESCRIPTION:
#     Overriding git for $HOME to maintain configs in one public (dotiles)
#     and one private (general) repo.
git() {
	[ "$PWD" = "$HOME" ] && {
		local opts="--work-tree $HOME --git-dir dotfiles.git" doton=t genon= left=$'\e[D' right=$'\e[C' input_is_ready
		until [ -v input_is_ready ]; do
			echo -en "Which repo would you like to operate on? ${doton:+\e[32m}dotfiles${doton:+\e[0m <} ${genon:+> \e[32m}general${genon:+\e[0m} "
			read -sn1
			[ "$REPLY" = $'\e' ] && read -sn2 rest && REPLY+="$rest"
			[ "$REPLY" ] && {
				case "$REPLY" in
					"$left")
						opts="--work-tree $HOME --git-dir dotfiles.git"
						doton=t; genon=
						;;
					"$right")
						opts="--work-tree $HOME --git-dir general.git"
						doton=; genon=t
						;;
				esac
				echo -en "\r\e[K" # \K lear line
			}||{
				echo
				input_is_ready=t
			}
		done
	}
	`which git` $opts "$@"
}

# DESCRIPTION:
#     Check if a file in $HOME is in dotfiles of general repo,
# TAKES:
#     $1 — file path under $HOME
isinrepo() {
	[ "$*" ] || {
		echo -e "Usage:\t${FUNCNAME[0]} $HOME/…/<filename>\n"
		return
	}
	local found
	[ "`dotgit ls-files "$1"`" -ef "$1" ] \
		&& echo "$@: Found in dotfiles." && found=t
	[ "`gengit ls-files "$1"`" -ef "$1" ] \
		&& echo "$@: Found in general." && found=t
	[ -v found ] || {
		echo "$@: Not found."
		return 3
	}
}

# pinentry doesn’t like scim
alias gpg="GTK_IM_MODULE= QT_IM_MODULE= gpg"
alias ls="ls -1h --color=auto"
mpvforcesubs='--sub-font=Roboto --sub-ass-force-style=FontName=Roboto'
alias mumble="mumble -style adwaita"
alias re=". ~/.bashrc" # re-source
alias redsh-cancel="DISPLAY=:0 redshift -O 6300"
alias rename="perl-rename"
alias rename-test="perl-rename -n"
spr="| curl -F 'sprunge=<-' http://sprunge.us" # add ?<lang> for line numbers
alias ssh="cat ~/.ssh/config*[^~] >~/.ssh/config; ssh "
alias trami="transmission-gtk"
#alias td="todo -A "
#alias tdD="todo -D "
#alias tmux="tmux -u -f ~/.tmux/config -S $HOME/.tmux/socket"
alias tmux="tmux -u -f ~/.tmux/config -L $USER"
alias yout="youtube-dl --write-sub --sub-format best --sub-lang en"


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

 # Sourcing bhlls for err() and info() functions
#
NO_CHECK_FOR_SOURCED_SCRIPT=t
NO_LOGGING=t
#. ~/repos/bhlls/bhlls.sh
# Returning pathname expansion after bhlls
set +f

pushd ~/bashrc >/dev/null
hostnamerc=${HOSTNAME%.*}.sh
[ -r $hostnamerc ] && . $hostnamerc
popd >/dev/null

# This is for one-command urxvt
one_command_execute() {
	exec &>/dev/null
	# TAB completion puts an extra space after the command.
	READLINE_LINE=${READLINE_LINE%%+([[:space:]])}
	# until [ -v all_aliases_expanded ]; do # recursive alias expansion
	# 	# Tabulation cahracter may be used in user’s aliases.
	# 	local first_word=${READLINE_LINE%%[[:space:]]*}
	# 	[ "$first_word" = "$old_first_word" ] && break # to prevent a loop
	# 	alias -p | grep -q "^alias $first_word='.*'$" && {
	# 		local cmd=`alias -p | sed -nr "s/^alias $first_word='(.*)'$/\1/p"`
	# 		# escape all special characters in the expanded alias is more
	# 		#   consuming, than just stripping its name and combining
	# 		#   a new string.
	# 		READLINE_LINE=${READLINE_LINE/#$first_word/}
	# 		READLINE_LINE="$cmd $READLINE_LINE"
	# 		local old_first_word="$first_word"
	# 	} || local all_aliases_expanded=t
	# done
	# 1. Scripts and binaries in $PATH are the easiest things to run.
	# 2. Shell functions may be run, but must be exported with ‘export -f’.
	# 3. Aliases cannot be exported and hence cannot be used here.
	nohup /bin/bash -c "$READLINE_LINE" &>/tmp/one_command_exec_output &
	local c=0
	until [ $((c++)) -eq 3 ]; do
		xdotool search --onlyvisible --pid $! &>/dev/null && break
		sleep 1
	done
	exit 0
}

[ -v ONE_COMMAND_SHELL ] && {
	## This doesn’t work now, so I have to use default binding C-M-e to
	##   expand aliases before they’ll go to nohup.
	# shopt -s expand_aliases # actually, this may be needed only inside
	#                         # of the subshell
	# bind shell-expand-line
	bind -x '"\C-m":"one_command_execute"'
}


#[ "$TERM" = jfbterm ] && ~/work/lifestream/minimal-sysrcd/deploy/squashfs-root/root/installer/tc-setup.sh --prepare-pxe-client

#  As the prompt indicates the last command status,
#  ~/.bashrc should return nicely.
return 0
