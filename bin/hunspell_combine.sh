#! /usr/bin/env bash

# hunspell_combine.sh
# Combines two hunspell dictionaries (two .aff and .dic parts) into one (pair).
# © deterenkelt

# Requires
# GNU bash-4.4
# GNU sed-4.2.1 to parse files
# uchardet-0.0.6 to detect dictionary encoding
# Some dictionaries with their affix files,
#   look into /usr/share/hunspell?


# About hunspell syntax format see ‘man 5 hunspell’.

# $1 – path to the first .dic file.
#      Corresponding .aff will be picked by throwing off extension.
# $2 – path to the second .dic file

# I leave code for debugging. It’s mainly aimed at two dictionaries:
#    russian-aot from hunspell-1.6.1
#    en_GB-ise from SCOWL (see the links at the end of the file)
# Prepend the script filename with D=t to enable debugging features. Like
#   D=t ./hunspell_combine.sh


set -eE
shopt -s dotglob
VERSION='20171026'
oldpwd=$PWD

show_error() {
	local file=$1 line=$2 lineno=$3
	echo -e "$file: An error occured!\nLine $lineno: $line" >&2
}

show_help() {
	cat <<-"EOF"
	Usage
	./hunspell_combine.sh  dictionary.dic  another_dictionary.dic
	EOF
	exit
}

# NB single quotes – to prevent early expansion
trap 'show_error "$BASH_SOURCE" "$BASH_COMMAND" "$LINENO"' ERR

[ $# -eq 0 ] && show_help

if [ -v D ]; then
	tmpdir=/tmp/tmp.1111; mkdir "$tmpdir" || :
	rm -rf $tmpdir/*
else
	tmpdir=`mktemp -d`
fi
cd "$tmpdir"

dic1="$1"
aff1="${dic1%.*}.aff"
dic2="$2"
aff2="${dic2%.*}.aff"

for file in dic1 aff1 dic2 aff2; do
	declare -n fileval=$file
	test -r "$fileval"
	file_enc=`uchardet "$fileval"`
	if [ "$file_enc" = ASCII -o "$file_enc" = UTF-8 ]; then
		cp "$fileval" "$tmpdir"
	else
		iconv -f "$file_enc" -t utf-8 "$fileval" > "$tmpdir/${fileval##*/}"
		sed -ri 's/^\s*SET\s+\S+\s*$/SET UTF-8/g' "$tmpdir/${fileval##*/}"
	fi
	declare local_$file="${fileval##*/}"
done

if [ -v D ]; then
	dicname='ru-GB'
else
	# Firefox .xpi addons require the basename of the dictionaries
	# to be in format ‘locale-variant’. Keep in mind.
	read -p "Name the new dictionary. Like ‘pt’ or ‘en-GB’ > "
	dicname=${REPLY%.aff}
	dicname=${dicname%.dic}
fi
newflag=1
for file in local_aff1 local_aff2; do
	unset multichar numeric
	declare -n fileval=$file
	flag_type=$(sed -rn 's/\s*FLAG\s+(\S+)\s*$/\1/p' "$fileval")
	unset sort_in_numeric
	case "$flag_type" in
		'num')
			# 0…65000, comma separated
			flag_type=numeric
			sort_in_numeric=t
			;;
		'long')
			# Two characters. Like aa Az G5 H? I_ and so on. Not separated
			flag_type=twochar
			;;
		'')
			# One unicode character. Not separated. The default.
			flag_type=onechar
			echo -e "File $fileval has FLAG type ‘long’, but I cannot work with that type yet!" >&2
			exit 3
			;;
		*)
			echo "Unknown FLAG type ‘$flag_type’ in file $fileval." >&2
			exit 3
	esac
	perfile_flaglist=( `sed -rn 's/^(PFX|SFX)\s+(\S+)\s+.*/\2/p' "$fileval" \
	                    | sort ${sort_in_numeric:+-n} \
	                    | uniq` )
	for ((i=0; i<${#perfile_flaglist[@]}; i++)); do
		# Later you can find all the affix FLAGs from $fileval here.
		echo ${perfile_flaglist[i]} >> ${file}_flaglist
	done
	# For each file we use clear flag_list, but we keep newflag with its
	# old value. Thus we guarantee, that flags of the same name between
	# two files will be parsed separately and each assigned its own number
	declare -A flag_list=()
	unset aff_sed_templ dic_sed_templ
	echo "$fileval has ${#perfile_flaglist[@]} flags."
	# Counter to show processing for slow computers.
	c=0
	for ((i=0; i<${#perfile_flaglist[@]}; i++)); do
		echo -en "\r\e[KProcessing flag №$((++c)): ${perfile_flaglist[i]}"
		key=${perfile_flaglist[i]}
		flag_list+=( [$key]="$newflag" )
		echo "$key – ${flag_list[$key]}" >> new_flag_list
		[ $((++newflag)) -eq 65000 ] && {
			echo "Cannot combine more: reached the limit of 65000 for affix flags." >&2
			exit 3
		}
	done
	echo -e "\r\e[KProcessing finished."

	for key in ${!flag_list[@]}; do
		# We add currency mark for the lines that we have edited.
		# Otherwise some of our numeric flags will match and get replaced
		# over and over again.

		# You must check that ‘+’ FLAG isn’t replaced with a space (or a null
		# terminator in the resulting .aff file.
		# This may do the trick ↓ but currently is not needed.
		# [ "$key" = '+' ] && key=$'\+'

		aff_sed_templ+=" s/^(PFX|SFX)\s+$key\s+(.*)$/¤\1 ${flag_list[$key]} \2/g;"
		case flag_type in
			'numeric')
				# We suppose that dictionary words cannot have slashes,
				# slash may be used only for flags.
				dic_sed_templ+=" s/(\/|,)$key(\/|,|\s|$)/\1¤${flag_list[$key]}\2/g;"
				;;
			'onechar')
				# Here we convert a single-char flag list to a multichar with commas.
				# ‘+’ FLAG is really a pain here. Sed treats ‘+’ speciallly with -r,
				# but without -r requires () {} + and | to be backslashed. Arghhh.
				# NB: $key left unescaped here, otherwise ‘+’ FLAG will get replaced
				# with an empty string (i.e. removed) in the resulting .aff.
				dic_sed_templ+=" s/\/([a-zA-Z+-]*)$key([a-zA-Z+-]*|$)/\/\1,¤${flag_list[$key]},\2/g;"
				;;
			'twochar')
				: # to be done
		esac
	done

	# Sadly, sed takes its time, ~15 seconds on i5-2500k to parse
	# the files. Do not use ‘(sed…) &’ here!
	echo "Replacing affix flags in $fileval. This may take a while…"
	sed -r "$aff_sed_templ" "$fileval" >>"$dicname.aff"
	echo "Replacing affix flags in ${fileval%.aff}.dic. This may take a while…"
	sed -r "$dic_sed_templ /^$/d; /^\s*[0-9]+\s*$/d" \
		"${fileval%.aff}.dic" >>"$dicname.dic"
done

# Updating the number of entries in the dictionary.
sed -ri "1 i `sed -n '$=' "$dicname.dic"`" "$dicname.dic"
# Removing our marks, spaces at the end of the lines.
sed -ri 's/¤//g; s/\s*$//g'  "$dicname.aff"
# Removing our marks and excessive commas.
sed -ri 's/¤//g; s/,+/,/g; s/\/,/\//g; s/,?\s*$//g'  "$dicname.dic"


 # It would be better to combine variables like TRY, KEY and WORDCHARS
#    instead of removing them. But it requires some delving into the
#    analisys on what may and may not be there.
#  Also you might want to replace the values from the dictionary with
#    your own. For example, KEY may have more neighbour keys than just
#    those to the right and to the left in the row.
#    Run ‘man -P "less -p '^\s*KEY'" 5 hunspell’ for more details.
#
#  1. Removing flags that may cause a clash, leaving only safe ones.
#     This may affect some dictionary features, but it’s the price
#     of combining. Some of them may coexist, but you better pick
#     those yourself and test, test, test…
#  2. Setting the new FLAG type as numeric
#  3. Setting UTF-8 encoding.
#
sed -ri "/^(PFX|SFX|REP|MAP|TRY|KEY|WORDCHARS|BREAKS|ICONV)/!d
         1 i FLAG num
         1 i SET UTF-8
        "  "$dicname.aff"

if cp "$dicname"{.aff,.dic} "$oldpwd/"; then
	[ -v D ] || rm -rf "$tmpdir"
else
	echo "Cannot copy files from $tmpdir to $oldpwd." >&2
	exit 3
fi

 # What should be proper tests starts here
#
# [ -v D ] && echo -e '\n\n'


 # FLAG replacement check
#  new_flag_list contains pairs, so we check, that FLAG 45 became what it
#  should have become according to new_flag_list.
#  Lines 853–867 are those having SFX parts for the new flag in the
#  newly built dictionary.
#
# [ -v D ] && {
# 	grep -n -E "^45\s" /tmp/tmp.1111/new_flag_list
# 	grep -n -E "\s45\s" /tmp/tmp.1111/russian-aot.aff
# 	sed -rn '853,867 p' /tmp/tmp.1111/$dicname.aff
# }


 # Check for correctness of FLAG replacement in .dic files.
#  The first grep shows the /FLAGs. In en_GB.dic from hunspell,
#    that I used at the time of writing this check, ‘beautiful’
#    had only one ‘Y’ flag.
#  The second shows what the flag (Y) is translated to in the new
#    dictionary. Should be some number.
#  The third grep shows what flags the word has in the new dictionary,
#    number(s) must correspond to the original flags.
#  * en_GB.dic is the one from hunspell, once I finished checks and still
#    was unsatisfied with the result, I changed the dictionary for SCOWL.
#
# [ -v D ] && {
# 	grep beautiful /tmp/tmp.1111/en_GB.dic
# 	grep ^Y /tmp/tmp.1111/new_flag_list
# 	grep beautiful /tmp/tmp.1111/$dicname.dic
# }


 # Check for the ‘+’ FLAG.
#  In the en_GB.aff from hunspell they use ‘+’ as an affix flag,
#    which is irritating and because of sed we must make sure, that
#    it didn’t treat ‘+’ as a regex symbol. Hence this check.
#  I recommend looking at ${file}_flaglist to see if your dictionaries
#    use ‘+’ as a flag to see, if you need this kind of check.
#
#[ -v D ] && {
#	grep -F 'tizable a' /tmp/tmp.1111/en_GB.aff
#}


 # For English language I recommend using SCOWL dictionaries:
#  Page: http://wordlist.aspell.net/dicts/
#  README: http://wordlist.aspell.net/hunspell-readme/
#  Hunspell dictionaries: https://sourceforge.net/projects/wordlist/files/speller/