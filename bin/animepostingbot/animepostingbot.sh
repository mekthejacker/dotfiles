#! /usr/bin/env bash

# animepostingbot.sh
# A bot using API to post files on GNU/Social network.
# © 2016–2017 deterenkelt.

# This program is free software; you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published
#   by the Free Software Foundation; either version 3 of the License,
#   or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
#   but without any warranty; without even the implied warranty
#   of merchantability or fitness for a particular purpose. See the
#   GNU General Public License for more details.


 # tested with
#
# GNU bash-4.3.39
# GNU sed-4.2.2
# GNU grep-2.21
# GNU find-4.5.14
# GNU coreutils-8.24
#     curl-7.43

set -f
mydir=`dirname "$0"`
rc="$mydir/animepostingbot.rc.sh"
log="$mydir/log"
used_files="$mydir/used"
problem_files="$mydir/problems"
touch "$used_files"
readarray -t used_cache < "$used_files"
file=''
message=''
pre="$rc:"$'\n'
VERSION='20170422-0824'
[[ "$REP" =~  ^[0-9]+$ ]] && {
	in_reply_to_status_id="$REP"
}
source='Anibot'

read_rc_file() {

	local var trash_found lostnfound_found
	. "$rc"
	for var in username password proto server media_upload_url making_post_url attachment_url older_than dirs remember_files; do
		[ -v $var ] || {
			echo "${pre}Variable $var should be set in animepostingbot.rc.sh!" >&2
			exit 3
		}
	done
	[ -v pause_secs ] && {
		[[ "$pause_secs" =~ ^[0-9]{1,9}$ ]] || {
			echo "${pre}Variable pause_secs is set, but it should be a number!" >&2
			exit 3
		}
	}
	[[ "$remember_files" =~ ^[0-9]{1,6}$ ]] || {
		echo "${pre}Variable remember_files should be a number!" >&2
		exit 3
	}
	[[ "$older_than" =~ ^[0-9]{1,4}$ ]] || {
		echo "${pre}Variable older_than should be a number!" >&2
		exit 3
	}
	for _d in ${dirs[@]}; do
		[ -d "$_d" ] || {
			echo "${pre}Wrong directory specified in the dir array: $_d" >&2
			exit 3
		}
	done
	[ ${#dirs[@]} -eq 0 ] && {
		echo "${pre}Specify at least one directory in the dirs array"
	}
	for i in ${blacklist[@]}; do
		[ "$i" = '*/.Trash-*' ] && trash_found=t
		[ "$i" = '*/lost+found*' ] && lostnfound_found=t
	done
	[ -v trash_found ] || blacklist+=('*/.Trash-*')
	[ -v lostnfound_found ] || blacklist+=('*/lost+found*')
}

# rc vars are used for pre-checks, so first call must be here,
#   and not where the cycle starts.
read_rc_file

[ -v pause_secs ] || do_once=t

exts=(-iname *.jpg -o -iname *.jpeg -o -iname *.png -o -iname *.gif -o -iname *.tiff -o -iname *.webm)
start_time=`date +%s`

[ -v D -a -r "$D" ] && {
	# If we debug and pass a file name, print out the data, not upload anything.
	echo "Enabling debugging with file=$D"
	[ -v Dnu ] && D_no_upload=t
	D_no_files=t
}

[ -v D ] && do_once=t  # Make it one shot for debugging.


update_file_list() {
	[ ${#blacklist[@]} -eq 0 ] || {
		find_excludes+=( "-not" "(" "-path" "${blacklist[0]}" )
		for ((i=1; i<${#blacklist[@]}; i++ )); do
			find_excludes+=("-o" "-path" "${blacklist[i]}")
		done
		find_excludes+=( "-prune" ")" )
	}

	# Create file list
	[ -v D_no_files ] || {
		files=()  # Drop current list on reread.
		while IFS= read -r -d $'\0'; do
			files+=("$REPLY")
		done < <(find -P "${dirs[@]}" "${find_excludes[@]}" -type f \( "${exts[@]}" \) -mtime +$older_than -print0)
		[ ${#files[@]} -eq 0 ] \
		&& echo 'No files! Will return now…' >&2 \
		&& exit
	}
	echo "Total files found: ${#files[@]}"
	[ -v D ] && {
		echo >"$mydir/file_list"
		for file in "${files[@]}"; do
			echo "$file" >>"$mydir/file_list"
		done
	}
}

find_an_image() {
	local mode="$@" mime='' newline=''
	case "$mode" in
		image|'') local mode=image; mime='image';;
		webm)  local mime='video' webm_hashtag='#webm';;
		all) local mime='.*';;
	esac
	echo "    Finding a file of type ‘$mode’…"
	unset image_found file split_path show_name show_name_hashtag middle_hashtags filename
	[ -v D -a -r "$D" ] && {
		# Simulate file, show how it’s going to be parsed
		image_found=t
		file="$D"
	}
	iter=0
	until [ -v image_found ]; do
		sleep 1  # Avoiding strange behaviour
		[ $((++iter)) -eq $remember_files ] && return  # Something went wrong
		chosen_idx=`shuf -i 0-$((${#files[@]}-1)) -n 1`
		echo -e "    `date +%Y-%m-%d\ %H:%M`    iter: $iter;    idx: $chosen_idx"
		file=${files[chosen_idx]}
		[ -r "$file" ] || {
			echo -e "        Dropped $file: is not readable." >&2
			continue
		}
		file --mime-type "$file" | sed -rn "s~.* ($mime/\S+)$~\1~;T;Q1" \
			&& echo -e "        Dropped $file: mime type mismatch." >&2 \
			&& continue
		unset match_found
		for ((i=0; i<${#used_cache[@]}; i++)); do
			[ "$file" = "${used_cache[i]}" ] && {
				echo -e "        Dropped $file: it was used in the past $remember_files." >&2
				match_found=t && break
			}
		done
		[ -v match_found ] || {
			used_cache+=("$file")
			image_found=t
			echo "    Found $file."
			[ $((iter-1)) -eq 0 ] || echo "    …after $((iter-1)) unsuccessful attempt(s)."
		}
	done

	for dir in "${dirs[@]}"; do
		stripped="${file##$dir}"
		[ "$stripped" != "$file" ] && middle_tags=$stripped && break
	done
	readarray -t split_path < <(echo "$stripped" | sed -r 's~^/~~;s~/~\n~g')
	[ ${#split_path[@]} -gt 1 ] && {
		show_name=`make_name "${split_path[0]}"`
		show_name_hashtag=`make_hashtag "$show_name"`
		unset middle_hashtags
		for ((i=1; i< $(( ${#split_path[@]}-1 )); i++)); do
			middle_hashtags+=(`make_hashtag "${split_path[i]}"`)  # #macro, #art, #misc
		done
	}
	filename="${split_path[-1]}"
	[ -v D -a -r "$D" ] && {
		declare -p stripped split_path show_name show_name_hashtag middle_hashtags filename
		# exit 0
	}
	# declare -p show_name show_name_hashtag middle_hashtags
	declare -g _message
	[ "$show_name_hashtag" -o "$webm_hashtag" ] && newline=$'\n'
	# Middle hashtags may exist only is show_name_hashtag is set
	[ "$middle_hashtags" ] && middle_hashtags=" $middle_hashtags"
	[ "$show_name_hashtag" ] && webm_hashtag=" $webm_hashtag"

	[ -v special_message ] || {
		read -r -d '' _message <<-EOF
		$filename${newline:-}${show_name_hashtag:-}${middle_hashtags:-}${webm_hashtag:-}
		EOF
	}
}

 # Keep spaces and capitalize first letters.
#
make_name() { sed -r 's/(^.)/\U\1/g; s~[\(\)\&\;]~~g' <<<"$@"; }

 # Removing spaces and adding ‘#’ in front.
#
make_hashtag() {
	local var="$@" prepare=$2
	[ "$prepare" ] && var=`make_name "$var"`
	var=${var// /_}
	echo "#${var//[,.\'\"\&\^\°\!\?\#\$\%\;\+\(\)\{\}]/}"
}

 # Final cleaning of the message for GNU Social
#  For some reason, GNU Social doesn’t like ampersands.
#  &ampl; is not an option. Maybe that’s curl? Too lazy to check.
#
cleanmsg4gs() {
	declare -g message=${message//&/}
}

upload_file() {
	echo "    Uploading file: $file"
	media_upload=`curl -u "$username:$password" --form "media=@$file" $proto$server$media_upload_url 2>/dev/null` && {
		media_id=`sed -rn '3 s~.*<mediaid>([0-9]+)</mediaid>.*~\1~p;T;Q1'<<<"$media_upload"` \
			&& {
				echo "        Error: media id is not a valid number." | tee -a "$problem_files" >&2
				return 1
			}||{
				message="${message:+$message$'\n'$'\n'}$_message $proto$server$attachment_url/$media_id"
				echo -e "    Uploaded with media id $media_id."
			}
		:
	}||	echo "    Error while uploading file $file" | tee -a "$problem_files" >&2
	return 0
}

 # Main algorithm starts here
#
update_file_list
while :; do
	# Update file list once per day
	new_time=`date +%s`
	[ "$((new_time-start_time))" -gt $((60*60*24)) ] && {
		read_rc_file
		update_file_list
		start_time=$new_time
	}
	echo -en "\n`date +%Y-%m-%d\ %H:%M`\nGoing a make a post!"
	# 1/5 chance to attach a webm/mp4
	unset attach_video
	[ -r "$D" ] || {
		[ `shuf -i 0-4 -n 1` -eq 0 ] && {
			echo ' …with a video!'
			attach_video=t
		}|| echo
	}
	unset message
	find_an_image
	[ -v D_no_upload ] || upload_file
	[ -v attach_video ] && {
		find_an_image webm
		[ -v D_no_upload ] || upload_file
	}
	# special_message is set when in ‘repetitive mode’,
	# see the explanation in the example rc file.
	[ -v special_message ] && unset message_additional_text
	message="${message:+$special_message$message$message_additional_text}"
	[ -v D_no_upload ] || {
		echo -e "\n`date +%Y-%m-%d\ %H:%M`\nSending the post…"
		[ "$message" ] && {
			cleanmsg4gs
			curl -u "$username:$password" \
		         --data "status=$message${in_reply_to_status_id:+&in_reply_to_status_id=$in_reply_to_status_id}${source:+&source=$source}" \
		         $proto$server$making_post_url &>"$log"
		}
		reply_to=`sed -nr 's/^\s*<id>([0-9]+)<\/id>\s*$/\1/p;T;Q1' "$log"`
		[[ "$reply_to" =~ ^[0-9]+$ ]] || {
			echo '    Cannot get our last post id.' >&2
			exit 5
		}
		[ -v in_reply_to_status_id ] && in_reply_to_status_id=$reply_to
		echo -e "\n`date +%Y-%m-%d\ %H:%M`\nMade post №$reply_to:\n    ---"
		echo "$message" | sed -r 's/.*/    &/g; $s/.*/&\n    ---/'

		# Write new used_files from cache
		[ -v D ] || {
			overhead=$((${#used_cache[@]} - remember_files))
			[ $overhead -gt 0 ] && {
				for ((i=0; i<overhead; i++)); do
					unset used_cache[i]
				done
			}
			IFS=$'\n'
			echo "${used_cache[*]}" >"$used_files"
		}
	}
	[ -v do_once ] && break || sleep $pause_secs
done