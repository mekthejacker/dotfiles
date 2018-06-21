#! /usr/bin/env bash

#  convert-jpeg-to-pdf-testing.sh

set -eEuT
#  Error handling and messages (warn/err/info)
. ~/repos/bahelite/bahelite.sh

cd $TMPDIR
jpegs=( "$@" )
size_jpegs_bytes=0
for jpeg in "${jpegs[@]}"; do
	[ -e "$jpeg" ] || err "No such jpeg: $jpeg"
	size_jpegs_bytes=$(( size_jpegs_bytes + $(stat --format '%s' "$jpeg") ))
done
size_jpegs_human=$(du -hck "${jpegs[@]}" | sed -rn '$s/^(\S+).*/\1/p')
pdf=${jpegs[0]%.*}.pdf

echo Command line
echo "$(basename "$0")" "$@"
convert -version | head -n1

echo

table_columns=$(
	echo -n "ALGO,"
	for ((i=0; i<${#jpegs[*]}; i++)); do
		echo -n "P.$((i+1)) SSIM,"
	done
	echo -n "% OF ⅀ ORIG SIZE,SIZE in KiB,SIZE in Bytes"
)
total_columns=$(( 1 + ${#jpegs[*]} + 3 ))
algos=( $(convert -list compress) ) || :
# algos=( JPEG )
{
	echo -en  "<SOURCE>\t"
	echo -en "$(for i in $(seq 1 ${#jpegs[*]}); do echo -ne '–\t'; done)"
	echo -en "100\t"
	echo -en "$size_jpegs_human\t"
	echo -e "$size_jpegs_bytes"
	for algo in ${algos[@]}; do
		ssim_results=() ssim_vals=() size_pdf=0 size_pdf_pct=0
		rm -f "$pdf"
		rm -rf ./*
		convert "$@" -compress $algo "$pdf"
		for ((i=0; i<${#jpegs[*]}; i++)); do
			#  GLOB pattern has to be used, because the suffix after “testpage”
			#  cannot be predicted. Hence before testing each page, the previous
			#  one has to be removed.
			rm -f testpage*
			pdfimages  -f $((i+1))  -l $((i+1))  -j  "$pdf"  testpage
			ls testpage* &>/dev/null || {
				milinc
				err 'Extraction failed.'
				mildec
			}
			# info "SSIM comparison with the original…"
			milinc
			ssim_val[i]=$(ssim.sh "${jpegs[i]}"  testpage*  \
			           |& sed -rn '$ s/ssim=(\S+) .*/\1/p')
			[[ "${ssim_val[i]}" =~ ^[0-9\.]+$ ]] \
				|| err "Couldn’t compute SSIM for test with $algo."
			if [ "${ssim_val[i]}" = 1 ];	then
				ssim_res[i]='OK'
				# info 'SSIM is OK!'
			else
				ssim_res[i]='FAIL'
				# err 'SSIM differs!'
			fi
		done
		size_pdf_human=$(du -hk "$pdf" | sed -r 's/^(\S+).*/\1/')
		size_pdf_bytes=$(stat --format '%s' "$pdf" )
		size_pdf_pct=$(echo "scale=0; $size_pdf_bytes*100/$size_jpegs_bytes" | bc -q)

		echo -en  "$algo\t"
		for ((i=0; i<${#jpegs[*]}; i++)); do
			echo -en "${ssim_res[i]} (${ssim_val[i]})\t"
		done
		echo -en "$size_pdf_pct\t"
		echo -en "$size_pdf_human\t"
		echo -e  "$size_pdf_bytes"
	done
} | column -t  -c $TERM_COLS  -o '    '  -s $'\t' \
           --table-columns "$table_columns" \
           -R $((total_columns-2)),$((total_columns-1)),$total_columns

echo
exit 0