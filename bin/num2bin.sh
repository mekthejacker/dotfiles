# num2bin.sh

# DESCRIPTION:
#     Read a decimal number and output it in binary format.
# TAKES:
#     $1 – number in decimal
#     $2 – number of bytes for output
function num2bin() {
	printf $(printf %.$(($2*2))x\\n $1 \
		| sed 's/\([0-9a-f][0-9a-f]\)/\\x\1/g') \
		| awk -F '' '{ printf $1$2$3$4 }'
		# To get reverse output of bytes
		# awk -F '' '{ printf $4$3$2$1 }'
}

# Examples:
# num2bin 1 4 | hexdump -C
# num2bin 16 4 | hexdump -C
# num2bin 548658 4 | hexdump -C
