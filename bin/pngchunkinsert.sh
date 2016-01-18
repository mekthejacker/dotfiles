#!/usr/bin/env bash

# pngchunkinsert.sh
# This script injects some data into a PNG file without breaking its structure.
# pngchunkinsert.sh © deterenkelt 2013,2014

# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3 of the License,
# or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but without any warranty; without even the implied warranty
# of merchantability or fitness for a particular purpose.
# See the GNU General Public License for more details.

# Requires:
# GNU bash-4.2 or higher
# GNU grep-2.9 or higher
# GNU sed-4.2.1 or higher

# PNG file looks like this
#
# ┌─────────────────────────────────┐
# │     89 50 4e 47 0d 0a 1a 0a     │ Header
# ├────────────┬────────┬───────────┤
# │      IHDR  │  PLTE  │   IDAT    │ Critical chunks
# ├─────────┬──┴────┬───┴──┬────────┤
# │   cHRM  │ gAMA  │ iCCP │ etc.   │ Ancillary chunks
# ├─────────┴───────┴──────┴────────┤
# ┊                                 ┊ Possible place for a new chunk
# ├────────────┬────────┬───────────┤
# │      sRGB  │  bKGD  │   tEXt    │ Some other ancillary chunks
# ├────────────┴────────┴───────────┤
# │         [new chunk here]        │ Preferable place for a new chunk
# ├─────────────────────────────────┤
# │               IEND              │ ‘EOF’ chunk
# └─────────────────────────────────┘
#
show_usage() {
cat <<EOF
Usage:
./pngchunkinsert.sh <source_file> <inject_file> <chunk_name> [output_file]

All parameters are required and you must be familiar with requirements to
chunk naming (see comments), if you really want your own chunk name.
EOF
}

[ "$#" -eq 1 ] && [ "$1" = '-h' -o "$1" = '--help' ] || [ "$#" -eq 0 ] && show_usage && exit 0

# You can convert any image to png with ‘convert’ util from imagemagick package
# `convert source.gif output.png`
#
# After all, how will this script combine the new file?
#
# New file will consist of 6 parts:
#  Part                            │ Length, in bytes
# ─────────────────────────────────┼─────────────────
#  1. Old file till the IEND chunk │  sourcefile size minus 12 bytes
#  2. Length  ┐                    │  4
#  3. Name*   ├ of the new chunk.  │  4
#  4. Data    │                    │  value stored in ‘Length’
#  5. CRC     ┘                    │  4
#  6. IEND
#
# *Name chunk is also know as Type

source_file="$1"
inject_file="$2"
output_file="$4"

for file in "$source_file" "$inject_file"; do
	[ -r "$file" ] || {	echo "Can’t read file: “$file”." >&2; exit 1; }
done
[ "`stat --format %s "$inject_file"`" -gt 4294967295 ] && {
	echo "The maximum allowed size for inject file is 4GiB - 1 byte." >&2
	exit 2
}
tstamp=`date +%s | sed -r 's/.*(.{5})$/\1/'`
[ "$output_file" ] || output_file=inj_$tstamp

# 1st part. Copying the source file except for the last 12 bytes with IEND
dd  bs=1 if="$source_file" of="$output_file" count=$((`stat --format %s "$source_file"`-12))

# 2nd part. Putting the length of the file we want to inject.
echo -en "$(printf %.8X\\n $(stat --format %s "$inject_file") \
	| sed 's/\([0-9A-F][0-9A-F]\)/\\x\1/g')" >> "$output_file"

# 3rd part. Choosing a chunk name

# Requirements to chunk naming:
#  1st letter must be _lowercase_ meaning it is ancillary, slave, and can be
#                                 ignored by the other programs which are not
#                                 able to recognize it;
#  2nd letter must be _lowercase_ meaning this is a private nowhere standartized
#                                 section of data;
#  3rd letter must be _UPPERCASE_ just because lowercase is reserved for future
#                                 use, at least now;
#  4th letter can be _UPPERCASE_  if you want to complicate modification of the
#                                 image for others. In that case, if the editing
#                                 software doesn’t recognize your private chunk,
#                                 and some of critical (primary) chunks were mo-
#                                 dified, then your private chunk will not be
#                                 added to the modified image. But if you want
#                                 this chunk to be saved by editors, you’d bet-
#                                 ter choose lowercase letter here.

[[ "$3" =~ ^[a-zA-Z]{4}$ ]] && chunkname=$3 || {
	echo "Invalid chunk name: ‘$3’. Using ‘prON’ instead." >&2
	chunkname="prON"
	}
# The name and the file for injection need to be placed in a file together
#   in order to get their overall checksum. Yes, checksum of both of them.
inj="/tmp/pnkchunkinsert_injection.$tstamp"
echo -n "$chunkname" > $inj

# 4th part. Copying file for injection into the new file as data of the new chunk.
cat "$inject_file" >> $inj

# 5th part. Adding the CRC-32 of the new chunk.
# cksum neither does print a CRC-32 sum, nor is it convertable to CRC-32,
#   so we use cksfv http://zakalwe.fi/~shd/foss/cksfv/
# chunkCRC="\x00\x00\x00\x00"  # this is a dummy.
chunkCRC=`cksfv $inj | sed -rn '${s/.*\s(\S+)$/\1/;s/[0-9A-F]{2}/\\\x&/g;p}'`
cat $inj >> "$output_file"
rm -f $inj
echo -en "$chunkCRC" >> "$output_file"

# 6th part. Appending kind of EOF in PNG language
echo -ne $"\x00\x00\x00\x00IEND\xae\x42\x60\x82" >> "$output_file"

# Further reading: http://www.w3.org/TR/PNG-Structure.html
