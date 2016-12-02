#! /bin/bash

set -f
mydir=`dirname "$0"`
used_files="$mydir/used"
problem_files="$mydir/problems"
touch "$used_files"
# Number of files to remember in used_files
remember_files=1000
readarray -t used_cache < "$used_files"
username='ywic'
password='OrraOrraOrra~~! You shits better respect your waifus!'
proto='https://'
server='gs.smuglo.li'
media_upload_url='/api/statusnet/media/upload'
making_post_url='/api/statuses/update.xml'
attachment_url='/attachment'
# Comment pause to run once
# Leave uncommented to run in cycle.
pause_secs=$((60*83))
[ -v pause_secs ] || do_once=t
# Found files must be older than this number of days
older_than=40
older_than_secs=$((60*60*24*$older_than))
file=''
message=''
message_additional_text=$'\n'$'\n''!anipics'
# Exclude patterns for `grep -E`
blacklist=(
	# Template:
	# '*pattern*'
	'*/.Trash-*'
	'*/lost+found*'
	'*toradora*'
	'*binbougami*'
	'*durara*'
	)
# Absolute paths
dirs=(
	'/home/picts/manga'
	'/home/picts/animu'
	'/home/picts/screens'
	)
# 1/5 chance to attach a webm
[ `shuf -i 0-4 -n 1` -eq 0 ] && addwebm=t
exts="-iname *.jpg -o -iname *.jpeg -o -iname *.png -o -iname *.gif -o -iname *.tiff -o -iname *.webm"
start_time=`date +%s`

[ -v D -a -r "$D" ] && {
	# If we debug and pass a file name, print out the data, not upload anything.
	echo "Enabling debugging with file=$D"
	D_no_upload=t
	D_no_files=t
}

[ -v D ] && unset pause_secs  # Make it one shot for debugging.


update_file_list() {
	[ ${#blacklist[@]} -eq 0 ] || {
		find_excludes+=( "-not ( -path ${blacklist[0]}" )
		for ((i=1; i<${#blacklist[@]}; i++ )); do
			find_excludes+=("-o -path ${blacklist[i]}")
		done
		find_excludes+=( "-prune )" )
	}

	# Create file list
	[ -v D_no_files ] || {
		while IFS= read -r -d $'\0'; do
			files+=("$REPLY")
		done < <(find -P "${dirs[@]}" ${find_excludes[@]} -type f \( $exts \) -print0)
		[ ${#files[@]} -eq 0 ] \
		&& echo 'No files! Will return now…' >&2 \
		&& exit
	}
}

find_an_image() {
	local mode="$@" mime=''
	case "$mode" in
		image|'') mode=image; mime='image';;
		webm)  mime='video' webm_hashtag='webm';;
		all) mime='.*';;
	esac

	unset image_found
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
		file=${files[chosen_idx]}
		[ -r "$file" ] || {
			echo -e "Selected file:\n  $file\nis not a readable file! Retrying…" >&2
			continue
		}
		file --mime-type "$file" | sed -rn "s~.* ($mime/\S+)$~\1~;T;Q1" \
			&& echo 'Mime type mismatch! Retrying…' >&2 \
			&& continue
		[ $((`date --date="now" +%s` - `stat --format %Y "$file"`)) -lt $older_than_secs ] \
			&& echo 'File is too fresh! Retrying…' >&2 \
			&& continue
		unset match_found
		for ((i=0; i<${#used_cache[@]}; i++)); do
			[ "$file" = "${used_cache[i]}" ] && match_found=t && break
		done
		[ -v match_found ] || {
			used_cache+=("$file")
			image_found=t
		}
	done

	for dir in "${dirs[@]}"; do
		stripped="${file##$dir}"
		[ "$stripped" != "$file" ] && middle_tags=$stripped && break
	done
	unset MAPFILE; readarray -t < <(echo "$stripped" | sed -r 's~^/~~;s~/~\n~g')
	[ ${#MAPFILE[@]} -gt 1 ] && {
		show_name=`make_name "${MAPFILE[0]}"`
		show_name_hashtag=`make_hashtag "$show_name"`
		unset middle_hashtags
		for ((i=1; i< $(( ${#MAPFILE[@]}-1 )); i++)); do
			middle_hashtags+=(`make_hashtag "${MAPFILE[i]}"`)  # #macro, #art, #misc
		done
	}
	filename="${MAPFILE[-1]}"
	[ -v D -a -r "$D" ] && {
		declare -p stripped MAPFILE show_name show_name_hashtag middle_hashtags filename
		exit 0
	}
	# declare -p show_name show_name_hashtag middle_hashtags
	declare -g _message
	[ "$show_name_hashtag" -o "$webm_hashtag" ] && newline=$'\n'
	# Middle hashtags may exist only is show_name_hashtag is set
	[ "$middle_hashtags" ] && middle_hashtags=" $middle_hashtags"
	[ "$show_name_hashtag" ] && webm_hashtag=" $webm_hashtag"

	read -r -d '' _message <<-EOF
	Name: $filename${newline:-}${show_name_hashtag:-}${middle_hashtags:-}${webm_hashtag:-}
	EOF
}

 # Keep spaces and capitalize first letters.
#
make_name() { sed -r 's/(^.)/\U\1/g' <<<"$@"; }

 # Removing spaces and adding ‘#’ in front.
#
make_hashtag() {
	local var="$@" prepare=$2
	[ "$prepare" ] && var=`make_name "$var"`
	var=${var// /_}
	echo "#${var//[,.\'\"\&\^\°\!\?\#\$\%\;]/}"
}

upload_file() {
	media_upload=`curl -u "$username:$password" --form "media=@$file" $proto$server$media_upload_url 2>/dev/null` && {
		media_id=`sed -rn '3 s~.*<mediaid>([0-9]+)</mediaid>.*~\1~p;T;Q1'<<<"$media_upload"` \
			&& {
				echo "Error: media id is not a valid number." | tee -a "$problem_files" >&2
				return 1
			}||{
				message="${message:+$message$'\n'$'\n'}$_message $proto$server$attachment_url/$media_id"
				echo "Uploaded file $file\n  with media id $media_id."
			}
		:
	}||	echo "Error while uploading file $file" | tee -a "$problem_files" >&2
	return 0
}

 # Main algorithm starts here
#
update_file_list
while :; do
	# Update file list once per day
	new_time=`date +%s`
	[ "$((new_time-start_time))" -gt $((60*60*24)) ] && {
		update_file_list
		start_time=$new_time
	}
	unset message
	find_an_image
	[ -v D_no_upload ] || upload_file

	[ -v addwebm ] && {
		echo 'Going to add a webm!'
		find_an_image webm
		[ -v D_no_upload ] || upload_file
	}
	message="${message:+$message$message_additional_text}"
	[ -v D_no_upload ] || {
		[ "$message" ] && curl -u "$username:$password" --form "status=$message" $proto$server$making_post_url &>/dev/null
		# Write new used_files from cache
		[ -v D ] && echo -e "\n\n\nMessage:\n\n$message" || {
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