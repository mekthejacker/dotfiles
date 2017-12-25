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
shopt -s extglob
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
VERSION='20171128'
[[ "$REP" =~  ^[0-9]+$ ]] && in_reply_to_status_id="$REP"
[ -v source ] || source='Anibot.sh'

read_rc_file() {
	local var trash_found lostnfound_found
	. "$rc"
	for var in username password proto server media_upload_url \
	           making_post_url attachment_url older_than \
	           pause_secs dirs remember_files; do
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

[ -v pause_secs ] || max_runs=1

exts=(
	-iname *.jpg
	-o -iname *.jpe
	-o -iname *.jpeg
	-o -iname *.png
	-o -iname *.gif
	-o -iname *.tiff
	-o -iname *.webm
	-o -iname *.mp4
	)
start_time=`date +%s`

[ -v D ] && {
	[[ -v D_max_runs && "$D_max_runs" =~ ^[0-9]+$ ]] \
		&& max_runs=$D_max_runs \
		|| max_runs=1  # Make it one shot for debugging.
	[[ -v D_pause_secs && "$D_pause_secs" =~ ^[0-9]+$ ]] \
		&& pause_secs=$D_pause_secs
	[ -r "$D" ] && {
		# If we debug and pass a file name,
		# print out the data, not upload anything.
		echo "Enabling debugging with file=$D"
	}
	# There is also D_dont_upload and D_dont_post
}


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
		while IFS= read -r -d ''; do
			files+=("$REPLY")
		done < <(find -P "${dirs[@]}" "${find_excludes[@]}" \
		              -type f \( "${exts[@]}" \) \
		              -mtime +$older_than -print0)
		[ ${#files[@]} -eq 0 ] \
		&& echo 'No files! Will return now…' >&2 \
		&& exit
	}
	echo "Total files found: ${#files[@]}"
	echo >"$mydir/file_list"
	for file in "${files[@]}"; do
		echo "$file" >>"$mydir/file_list"
	done
}

find_a_file() {
	local mode="$@" mime='' file_basename file_basedir image_found \
	      video_hashtag hashtags=() special_hashtags=() \
	      local_hashtags_to_remove=() hashtag_space \
	      first_newline second_newline third_newline \
	      author_file author_data
	case "$mode" in
		image|'') mode='image' mime='image';;
		video)  mime='video' video_hashtag='#webm';;
		all) mime='.*';;
	esac
	echo "    Finding a file of type ‘$mode’…"
	unset image_found
	[ -v D -a -r "$D" ] && {
		# Simulate file, show how it’s going to be parsed
		image_found=t
		declare -g file="$D"
		[[ "$file" =~ ^.*(webm|mp4)$ ]] && {
			mime=video
			declare -g video=video
			video_hashtag='#webm'
		}
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
		[ "$stripped" != "$file" ] && done_stripping=t && break
	done
	[ -v done_stripping ] || {
		echo 'File not in the specified folders? Wrong path?' >&2
		exit 3
	}
	# If what we pass to readarray would be an empty string, then
	# then readarray forcibly create single – and empty – array element,
	# which will result in a ghost hashtag later.
	[ "${stripped%/*}" ] \
		&& readarray -t hashtags < <( sed -r 's~^/~~;s~/~\n~g' <<<"${stripped%/*}" )
	file_basename=${stripped##*/}
	file_basedir=${file%/*}
	declare -g file

	[ -v D ] && declare -p file file_basename file_basedir hashtags \
	         && echo "Hashtags: ${#hashtags[@]}"

	 # 1. Stripping hashtags from bad characters
	#     and replacing spaces with underscores
	#
	[ -v D ] && echo $'\n'Stripping hashtags from bad characters…
	for ((i=0; i<${#hashtags[@]}; i++)); do
		for prefix in ${hashtags_prefixes_to_strip[@]}; do
			hashtags[$i]="${hashtags[i]#$prefix}"
		done
		hashtags[$i]="${hashtags[i]//+([[:space:][:punct:]])/_}"
		hashtags[$i]="${hashtags[i]//[^[:word:]]/}"
		hashtags[$i]="${hashtags[i]#+(_)}"
		hashtags[$i]="${hashtags[i]//+(_)/_}"
	done
	[ -v D ] && declare -p hashtags && echo "Hashtags: ${#hashtags[@]}"

	 # 2. Capitalise hashtags
	#
	[ -v D ] && echo $'\n'Capitalising hashtags…
	for ((i=0; i<${#hashtags[@]}; i++)); do
		for capit_mark in "${hashtags_capitalise_after[@]}"; do
			[ "${hashtags[i]}" = "$capit_mark" -a -v hashtags[$((i+1))] ] && {
				if [ -v dont_put_each_capitalised_tag_on_a_separate_line ]; then
					# keep capitalised tags in line and treat like regular tags
					hashtags[$((i+1))]=${hashtags[$((i+1))]^}
				else
					# move them to a separate array, from which they’ll be printed
					# each on a separate line
					special_hashtags+=( "${hashtags[$((i+1))]^}" )
					# since we don’t need this tag in the common array,
					# mark it for removal by adding to the unwanted tags array
					local_hashtags_to_remove+=( "${hashtags[$((i+1))]}" )
				fi
				break
			}
		done
	done
	[ -v D ] && declare -p hashtags special_hashtags \
	         && echo "Hashtags: ${#hashtags[@]}"

	 # 3. Move to the back less important tags
	#
	[ -v D ] && echo $'\n'Moving less important tags to the back
	items_to_check=${#hashtags[@]}
	for ((i=0; i<items_to_check; i++)); do
		for less_important_tag in "${hashtags_to_the_back[@]}"; do
			[ "${hashtags[i]}" = "$less_important_tag" ] && {
				buf=${hashtags[i]}
				for ((j=i+1; j<${#hashtags[@]}; j++)); do
					hashtags[$((j-1))]=${hashtags[j]}
				done
				hashtags[-1]="$buf"
				let items_to_check--
				break
			}
		done
	done
	[ -v D ] && declare -p hashtags \
	         && echo "Hashtags: ${#hashtags[@]}"

	 # 4. Removing unneeded tags
	#     (we do it in the last step, because otherwise we would need
	#     to catch the holes in the array somehow).
	#
	[ -v D ] && echo $'\n'Removing unneeded tags…
	hashtags_arrlength=${#hashtags[@]}
	for ((i=0; i<hashtags_arrlength; i++)); do
		for unneeded_tag in "${hashtags_to_remove[@]}" \
		                    "${local_hashtags_to_remove[@]}"; do
			[ "${hashtags[i]}" = "$unneeded_tag" ] \
				&& unset hashtags[$i] \
				&& break
		done
	done
	[ -v D ] && declare -p hashtags \
	         && echo "Hashtags: ${#hashtags[@]}"

	 # 5. Adding a hash sign to tags
	#
	[ -v D ] && echo $'\n'Adding hash signs to what is left…
	for ((i=0; i<hashtags_arrlength; i++)); do
		[ -v hashtags[$i] ] \
			&& hashtags[$i]="#${hashtags[i]}"
	done
	for ((i=0; i<${#special_hashtags[@]}; i++)); do
		[ -v special_hashtags[$i] ] \
			&& special_hashtags[$i]="#${special_hashtags[i]}"
	done
	[ -v D ] && declare -p hashtags special_hashtags

	 # 6. Composing the message
	#
	[ -v D ] && echo $'\n'Composing the message
	 # Message looks like this:
	#
	#  File_name.jpeg <$first_newline>
	#  #Capitalised_tag1
	#  #Capitalised_tag2 <$second_newline>
	#  #various #common #tags <$hashtags_space> <$video_hashtag> <$third_newline>
	#
	#  author data from the file named ‘author’. This file must reside
	#  in the same folder as the image. First line is the name, others
	#  whatever, put there URL to their blogs/homepages/pawoo and pixiv.
	[ -v D ] && set -x
	[ ${#special_hashtags[@]} -gt 0 ] && first_newline=$'\n'
	[ ${#hashtags[@]} -gt 0  -o  -v video_hashtag ] && second_newline=$'\n'
	[ ${#hashtags[@]} -gt 0  -a  -v video_hashtag ] && hashtags_space=' '
	[ -v D ] && set +x
	author_file="$file_basedir/author"
	[ -r "$author_file" ] && {
		third_newline=$'\n'$'\n'
		author_data="$( sed -r '1 {s/.*/Author: &/}' "$author_file" )"
	}

	[ -v special_message ] || {
		message="$file_basename"
		message+="${first_newline:-}$(IFS=$'\n'; echo "${special_hashtags[*]}")"
		message+="${second_newline:-}${hashtags[*]}${hashtags_space:-}${video_hashtag:-}"
		message+="$third_newline$author_data"
	}
}


upload_file() {
	local file media_upload media_id
	for file in "$@"; do
		echo "    Uploading file: $file"
		if media_upload=`curl -u "$username:$password" \
			                  --form "media=@$file" \
			                  $proto$server$media_upload_url 2>/dev/null`
		then
			if media_id=`sed -rn '3 s~.*<mediaid>([0-9]+)</mediaid>.*~\1~p;T;Q1'<<<"$media_upload"`; then
				echo "        Error: media id is not a valid number." | tee -a "$problem_files" >&2
				return 1
			else
				media_ids+=("$media_id")
				echo -e "    Uploaded with media id $media_id."
			fi
		else
			echo "    Error while uploading file $file" | tee -a "$problem_files" >&2
			return 1
		fi
	done
	return 0
}

 # Main algorithm starts here
#
update_file_list
runs=0
while :; do
	# Update file list once per day
	new_time=`date +%s`
	[ "$((new_time-start_time))" -gt $((60*60*24)) ] && {
		read_rc_file
		update_file_list
		start_time=$new_time
	}
	echo -en "\n`date +%Y-%m-%d\ %H:%M`\nGoing a make a post!"

	unset message video file media_ids
	declare -g message video file media_ids
	#            ^       ^    ^        ^
	#            |       |    |        IDs of uploaded attachments
	#            |       |    Absolute path to the file for upload
	#            |       Mark of the videofile upload (not an image)
	#            What will be sent in the --data of the request
	#
	[ -r "$D" ] || {
		# 1/5 chance to attach a webm/mp4
		[ ! -v no_media -a `shuf -i 0-4 -n 1` -eq 0 ] && {
			echo ' …with a video!'
			video=video
		}|| echo
	}
	find_a_file ${video:-}
	[ -v D_dont_upload ] || {
		[ -r "$mydir/$pic_to_attach_with_video" ] \
			&& pic="$mydir/$pic_to_attach_with_video"
		upload_file ${video:+"$pic"} "$file"
	}
	# special_message is set when in ‘repetitive mode’,
	# see the explanation in the example rc file.
	[ -v special_message ] && unset message_additional_text
	message="${message:+$special_message$message$message_additional_text}"
	for media_id in ${media_ids[@]}; do
		message+=" $proto$server$attachment_url/$media_id"
	done
	declare -p message
	[ -v D_dont_post ] || {
		echo -e "\n`date +%Y-%m-%d\ %H:%M`\nSending the post…"
		[ "$message" ] && {
			# Final cleaning of the message for GNU Social
			# For some reason, GNU Social doesn’t like ampersands.
			# &amp; is not an option. Maybe that’s curl? Too lazy to check.
			message="status=${message//&/}"
			message+="${in_reply_to_status_id:+&in_reply_to_status_id=$in_reply_to_status_id}"
			message+="${source:+&source=$source}"
			curl -u "$username:$password" \
		         --data "$message" \
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
			(IFS=$'\n';	echo "${used_cache[*]}" >"$used_files")
		}
	}
	[ $((++runs)) -eq ${max_runs:-0} ] && break || sleep $pause_secs
done