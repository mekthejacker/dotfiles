# common.sh
#
#  Aliases and functions common for all hosts.
#  See also:
#  - wine-aliases.sh
#  - $HOSTNAME.sh



 # Aliases caveats and hints:
#  1. All innder double quotes must be escaped
#     alias preservequotespls="echo \"naive example!\""
#  2. Every call of subshell must be escaped or it will be executing
#     at the time this file loads.
#     alias dontlistmyhomefolderpls="for i in \`ls\`; do ls $i; done"
#  3. To prevent early expanding of variable names, one can use single
#     quotes or escaping, or both if situation requires so.
#     alias hisbashrcpls="sudo -u another_user /bin/bash -c 'nano \$HOME/.bashrc'"
#  4. Aliases can have multiple lines
#     alias plsplsplsdontbreak="echo some stuff # this is comment
#                               echo lol second line # another comment"
#
#  Better use functions.

alias bc="bc -q"
# Check unicode symbols
chu() { echo -n "$@" | uniname; }  # from uniutils package
alias ec="emacsclient -c -nw"
alias emc="emacsclient"
alias erc="emacsclient -c -nw ~/.bashrc"
alias ffmpeg="ffmpeg -hide_banner"
alias ffprobe="ffprobe -hide_banner"
#  Viruses writers don’t expect that.
alias firefox='firefox --profile ~/.ff'
alias fm="font-manager"
alias hu="hugo"
alias hus="hugo server --watch --source ~/repos/goen/"
alias husd="hugo server --watch --source ~/repos/goen/ --buildDrafts --destination ~/repos/goen/dev"
alias grep="grep --color=auto"
alias imgur="~/bin/imgur_upload.sh"
#  pinentry doesn’t like scim
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
alias uguu="~/bin/uguu_upload.sh"
alias xz="pixz"
alias yout="youtube-dl --write-sub --sub-format best --sub-lang en"
waifu2x() {
	waifu2x-converter-cpp --disable-gpu
}


 # Git
#
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


at-msg() {
	local when msg
	read -p "Examples: ‘+10 mins’, ‘19:30’."$'\n'"When? > " when
	read -p "Text message: > " msg
	date --date="$when" +"%H:%M" >/dev/null || return 4

	at "`date --date="$when" +"%H:%M"`" \
	     <<<"mpc |& sed -n '2s/playing//;T;Q1' || {
	             mpc pause                     >/dev/null
	             echo '{ \"command\": [\"set_property\", \"pause\", true] }' | socat - ~/.mpv/socket
	             echo '{ \"command\": [\"set_property\", \"fullscreen\", false] }' | socat - ~/.mpv/socket
	             aplay ~/.env/Tutturuu_v2.wav  >/dev/null
	             mpc play                      >/dev/null
	         }
	         DISPLAY=$DISPLAY Xdialog --msgbox \"\n   $msg   \n\" 200x100"
	# Should add exit fullscreen command for mpv.
	# See JSON IPC for mpv.
	# 1. find an mpv instance (by WM_CLASS? or from the list of X windows? i3 workspace windows?)
	# 2. find whether the current mpv instance is in fullscreen mode
	# 3. if it is, then send a command to socket to exit fullscreen.
	# For #3 to work IPC socket path should be added to the mpv config.
}

# DESCRIPTION:
#     Takes a magnet link and places a .torrent file made of it to a directory.
#     USeful for rtorrent
# TAKES:
#   $1 — magnet link
#   $2 — path to resulting .torrent file
magnet-to-torrent() {
	[ -z "$*" -o $# -ne 2 ] && {
		cat <<-EOF
		Usage: magnet-to-torrent <magnet link> <new file path>
		EOF
		return
	}
	[[ "$1" =~ xt=urn:(btih|sha1):([^&/]+) ]] || {
		echo 'Invalid magnet link!' >&2
		return 3
	}
	[ -d "${2%/*}" ] || {
		echo "No such directory: ${2%/*}" >&2
		return 4
	}
	echo "d10:magnet-uri${#1}:${1}e" > "$2"
	echo "Copied to $2"
}

# Copies current MPD playlist to a specified folder.
copy-playlist() {
	err() { echo "$1" >&2; [ "$2" ] && return $2; }  # $1 — message; $2 — return code
	local cur_pl='current' dest="$HOME/desktop/gn5-music/" \
		  pl_dir pl library_path got_a_sane_reply
	pl_dir=`sed -nr 's/^\s*playlist_directory\s+"(.+)"\s*$/\1/p' ~/.mpd/mpd.conf`
	[ "$pl_dir" ] || err 'mpd.conf doesn’t have playlist_directory?' 3
	library_path=`sed -nr 's/^\s*music_directory\s+"(.+)"\s*$/\1/p' ~/.mpd/mpd.conf`
	library_path="${library_path/#\~/$HOME}"
	rm -r $dest/*
	eval [ -d "$pl_dir" ] \
		|| err 'Playlist directory is indeterminable.' 4
	eval [ -d "$library_path" ] \
		|| err 'Path to music library is indeterminable.' 5
	# [ "$*" ] && dest="$*" || {
	# 	dest="$HOME/phone_card"
	# 	disk=`sudo /sbin/findfs LABEL=PHONE_CARD` \
	# 		&& sudo /bin/mount -t vfat -o users,fmask=0111,dmask=0000,rw,codepage=866,iocharset=iso8859-5,utf8 $disk $HOME/phone_card \
	# 			|| return `err "Default destination PHONE_CARD cannot be found." 7`
	# }
	eval pushd $pl_dir
	rm -vf $cur_pl.m3u
	mpc save "$cur_pl"  # MPD_HOST must be set in the environment
	[ -f "$cur_pl.m3u" ] || err 'Playlist wasn’t saved' 6
	[ -w "$dest" ] && {
		while read filepath; do
			filepath="${filepath/$library_path/}"
			cp -nv  "$library_path/$filepath" "$dest" || {
				unset got_a_sane_reply
				until [ -v got_a_sane_reply ]; do
					read -n1 -p 'Error on copying. Continue? [Y/n] > '; echo
					case "$REPLY" in
						y|Y|'') got_a_sane_reply=t;;  # And skip further messages
						n|N) break 2;;
						*) echo 'Y or N.';;
					esac
				done
			}
		done < "$cur_pl.m3u"
		popd
	}||{ popd; err "Destination dir ‘$dest’ is not writable." 7; }

    # [ "$dest" = "$HOME/phone_card" ] && {
	# 	sudo /bin/umount "$dest"
	# 	rm -rf "$dest"
	# }
}


mount-box() {
	gpg -qd --output /tmp/decrypted/secrets.`date +%s` ~/.davfs2/secrets.gpg
	sudo /root/scripts/mount_box.sh $USER &
}


umount-box() {
	sudo /root/scripts/mount_box.sh $USER umount &
}


 # Uploads a text file to sprunge
#  $1 — file name to upload.
#
spr() {
	[ -r "$1" ] || {
		echo 'Pass a file name to paste.'
		return 3
	}
	#firefox http://sprunge.us/aXZI?py#n-7
	curl -F 'sprunge=<-' http://sprunge.us <"$1" \
		| perl -p -e 'chomp if eof' | tee /dev/tty | xclip
	echo
}


 # Encrypts a file with GPG
#  $1 — file to encrypt. Encrypted version will be palced along with it.
#
gpg-enc() {
	GTK_IM_MODULE= QT_IM_MODULE= gpg \
		--batch -se --output $1.gpg --yes -R *$ME_FOR_GPG $1
}


arecord-mixed() {
	set -x
	sudo /sbin/modprobe snd_aloop
	# Applications which sound is to be recorded may need to be restarted.
	cp ~/.asoundrc.mix ~/.asoundrc
	# 2 is the number of the Loopback card.
	arecord -D "hw:2,1" -f cd -t wav /tmp/s.wav
	rm  ~/.asoundrc
	sudo /sbin/modprobe -r snd_aloop
	set +x
}


 # Records sound from microphone and converts it to mp3
#
rec() {
	local ts
	ts=`date +%s`
	arecord -f cd -t wav /tmp/$ts.wav
	ffmpeg -i /tmp/$ts.wav -codec:a libmp3lame -qscale:a 0 /tmp/$ts.mp3
	echo -n /tmp/$ts.mp3 | xclip
}


 # Find a picture or webm
#
fpic() { find -L /home/picts -iname "*$@*"; }


 # Adds all hosts in a given subnet to the java exception site list.
#  $1 — A net address without the last octet, 192.168.2 for example.
#
java-site-exception() {
	local exception_list=$HOME/.java/deployment/security/exception.sites \
	      exceptions o site e match c
	exceptions=(`<$exception_list`)
	[[ "$1" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || {
		echo "Usage:    ${FUNCNAME[0]} 192.168.2" >&2
		return
	}
	c=0
	for o in {1..254}; do
		for site in "https://$1.$o/" "http://$1.$o/"; do
			unset match
			for e in ${exceptions[@]}; do
				[ "$site" = "$e" ] && match=t
			done
			[ -v match ] || {
				echo "$site" >>$exception_list
				let c++
			}
		done
	done
	echo "Added $c hosts."
}
# Thanks, Krishna!


 # Forwards local ports via $1 to $2.
#
ssh-ipmi() {
    local gw=$1 ipmi=$2 found
    case "$mode" in
    	''|ipmi)
			# 22 – SSH, duh
			# 80, 443 – webiface
			# 623 – java?
			# 5900 – virtual disk I/O?
			ports=(22 80 443 623 5900)
    		;;
		ilo)
			# 22 – SSH, duh
			# 80, 443 – webiface
			# 763 – moonshot cartridge iLO
			# 17988 – java?
			# 17990 – virtual disk I/O?
			ports=(22 80 443 763 17988 17990)
			;;
	esac
    # We’d usually want to bind $ipmi to a local address, such as 127.0.0.x,
    # with the last octet of $ipmi left as is.
    o=${ipmi##*.}
    pgrep -f "ssh.*-L\s*127\.0\.0\.$o:" &>/dev/null && {
        # Our preferred octet is occupied, looking for the first available.
        for ((i=0; i<255; i++)); do
            for ((j=1; j<254; j++)); do
                [ $i -eq 0 -a $j -eq 1 ] && continue  # skip for 127.0.0.1:80
                pgrep -f "ssh.*-L\s*127\.0\.$i\.$j:" &>/dev/null || {
                    found=t
                    break 2
                }
            done
        done
        [ -v found ] || {
            echo 'Error: Couldn’t find a free address in 127.0/16.' >&2
            return 3
        }
        local_addr=127.0.$i.$j
        :
    }|| local_addr=127.0.0.$o
    ssh -Nf -C $gw -L $local_addr:${ports[0]}:$ipmi:${ports[0]} \
                   -L $local_addr:${ports[1]}:$ipmi:${ports[1]} \
                   -L $local_addr:${ports[2]}:$ipmi:${ports[2]} \
                   -L $local_addr:${ports[3]}:$ipmi:${ports[3]}
    pgrep -af "ssh.*$gw\s+-L\s*$local_addr:.*:$ipmi:"
}
ssh-clear() { pkill -9 -f "ssh.*-L.*"; }
ssh-ilo() { mode=ilo ssh-ipmi "$@"; }
ssh-moonsht-ilo() { mode=moonsht-ilo ssh-ipmi "$@"; }

 # Copies the path to the currently playing song to clipboard.
#
song() {
	mpd_library_path=$(
		sed -rn "/^\s*music_directory/ {
			s/^\s*music_directory\s+\"([^\"]+)\"\s*$/\1/;
			s%~%$HOME%p
		}" ~/.mpd/mpd.conf
	)
	song_local_path=$(mpc -f '%file%' | head -n1)
	song_full_path="$mpd_library_path/$song_local_path"
	if [ -r "$song_full_path" ]; then
		type xsel &>/dev/null && echo -n $song_full_path | xsel || {
			type xclip &>/dev/null && echo -n $song_full_path | xclip
		} || notify-send --hint int:transient:1 -t 3000 'mpd' 'Couldn’t copy path to clipboard.'
	else
		notify-send --hint int:transient:1 -t 3000 'mpd' 'Couldn’t retrieve song path.'
	fi
}