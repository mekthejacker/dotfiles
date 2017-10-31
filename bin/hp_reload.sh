#! /usr/bin/env bash

# hp_reload.sh
# Disables SmartInstall on HP printers and recreates them in CUPS.
# © deterenkelt

# The issue concerns HP printers using HPLIP interface.
# HPLIP is better than foomatic, because of two reasons:
#   - Foomatic doesn’t use printer’s actual dpi.
#   - Foomatic prints without aligning text on the page,
#     i.e. the resulting page is skewed.

# It is possible to attach an HP printer once using hp-setup.
# But after a restart or a power loss (when PC is on UPS and
# the printer is not), CUPS will be unable to print:
# it will throw backend (=hplip) error like
#   > error: prnt/backend/hp.c 745: cups ERROR: open device failed stat=12 hp:/…
# or
#   > cups hp m_Job initialization failed with error = 48
# When you’ll try to run hp-setup again, the command would
# say, that it cannot find any printers:
#   > Using connection type: usb
#   > error: No device selected/specified or that supports this functionality.
# While hp-makeuri USBBUS:USBDEVICE (see lsusb) will show for example:
#   > $ hp-makeuri 007:015
#   > CUPS URI: hp:/usb/HP_LaserJet_Professional_P1102w?serial=SMART_INSTALL_ENABLED
# Note, that when you installed a printer successfully back then,
# the URI would contain actual serial number:
#   > CUPS URI: hp:/usb/HP_LaserJet_Professional_P1102w?serial=000000000Q93A0TGPR1a
# That ‘nice’ feature – Smart Install – is a special thing for Windows machines,
# and it prevents HP Linux backend to see the printer, making it appear
# as a storage device. This script emulates the behaviour of
# SmartInstallDisable-Tool.run binary from HP – that is not accessible anywhere
# nowdays, because HP put a dick on Linux users.
# https://developers.hp.com/hp-linux-imaging-and-printing/howtos/other
# http://hplipopensource.com/hplip-web/smartinstall/SmartInstallDisable-Tool.run
# https://h30434.www3.hp.com/t5/Printer-Software-and-Drivers/Laserjet-CP1025-color-How-to-disable-smart-install/td-p/5659194

set -eE
show_error() {
	local file=$1 line=$2 lineno=$3
	echo -e "$file: An error occured!\nLine $lineno: $line" >&2
}
shopt -s extglob
VERSION='20171031'
[ $# -ne 0 ] && {
	cat <<-"EOF"
	Usage:
	./hp_reload.sh

	There should be only one HP device attached.
	EOF
	exit
}

[ "$UID" -ne 0 ] && {
	echo 'Run me as root: I need to use lpadmin.' >&2
}
which lsusb &>/dev/null
printer_attached() { lsusb |& grep -qE '\b(HP|Hewlett-Packard)\b'; }

get_dev_info() {
	# read quits with 1 on encountering EOF, so ||:
	read bus_id device_id vendor_id product_id \
		< <(lsusb |& sed -rn 's/^Bus\s+([0-9]+)\s+Device\s*([0-9]+):\s*ID\s+([^:]+):(\S+)\s+(HP|Hewlett-Packard)/\1 \2 \3 \4/p') || :
	read model < <(lsusb -vs $bus_id:$device_id |& sed -rn 's/^\s*iProduct\s+\S+\s+(.*)$/\1/p') || :
	[[ "$bus_id" =~ ^[0-9]+$ ]] || {
		echo 'Cannot obtain bus id.' >&2
		exit 3
	}
	[[ "$device_id" =~ ^[0-9]+$ ]] || {
		echo 'Cannot obtain device id.' >&2
		exit 3
	}
	[[ "$vendor_id" =~ ^[0-9a-f]+$ ]] || {
		echo 'Cannot obtain vendor id.' >&2
		exit 3
	}
	[[ "$product_id" =~ ^[0-9a-f]+$ ]] || {
		echo 'Cannot obtain product id.' >&2
		exit 3
	}
	[ "$model" ] || {
		echo 'iProduct field is an empty string.' >&2
		exit 3
	}
	return 0
}

delete_printer() {
	echo "Deleting printer ‘$model’ from CUPS."
	if lpadmin -x "$model"; then
		echo 'Printer deleted!'
	else
		echo 'Couldn’t delete printer' >&2
		exit 3
	fi
	# I also used this before, but it doesn’t seem to be needed.
	# hp-setup -r
	return 0
}

 # These two functions disable and enable SmartInstall,
#    a feature that makes it impossible for the Linux HP backend
#    to see the printer, making it appear as a USB storage.
#  Dudinea has read those strings in 2011 from grabbing usb port data
#    thanks be to him. https://bugs.launchpad.net/hplip/+bug/672134/comments/2
#
#  The strings we send are hex-coded. In the commented sections is the tab-padded
#    textual representation of the strings.
#
disable_smart_install() {
	echo 'Disabling SmartInstall.'
	# First portion (-M)
	#
	#	PUT /dev/featureStatus.xml HTTP/1.1
	#	CONTENT-LENGTH: 222
	#	USER-AGENT:hp Proxy/3.0
	#	HOST:localhost:3910
	#
	#	<?xml version="1.0" encoding="UTF-8"?>
	#	<featureStatus xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="featureStatus.xsd">
	# 	  <smartInstall>disabled</smartInstall>
	#	</featureStatus>
	#
	# Expected response(?) the part after ‘-n -2’
	#
	#	GET /dev/featureStatus.xml HTTP/1.1
	#	CONTENT-LENGTH: 0
	#	USER-AGENT:hp Proxy/3.0
	#	HOST:localhost:3910
	#
	usb_modeswitch -m 2 -r 2 -v 0x$vendor_id -p 0x$product_id \
	               -M 505554202F6465762F666561747572655374617475732E786D6C20485454502F312E310D0A434F4E54454E542D4C454E4754483A203232320D0A555345522D4147454E543A68702050726F78792F332E300D0A484F53543A6C6F63616C686F73743A333931300D0A0D0A3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D225554462D38223F3E0D0A3C6665617475726553746174757320786D6C6E733A7873693D22687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D612D696E7374616E636522207873693A6E6F4E616D657370616365536368656D614C6F636174696F6E3D22666561747572655374617475732E787364223E0D0A20203C736D617274496E7374616C6C3E64697361626C65643C2F736D617274496E7374616C6C3E0D0A3C2F666561747572655374617475733E0D0A0D0A \
	               -n -2 474554202F6465762F666561747572655374617475732E786D6C20485454502F312E310D0A434F4E54454E542D4C454E4754483A20300D0A555345522D4147454E543A68702050726F78792F332E300D0A484F53543A6C6F63616C686F73743A333931300D0A0D0A -n -R
	if [ $? -eq 0 ]; then
		echo 'Now power cycle the printer, usb reset is not enough!'
	else
		echo "Couldn’t disable SmartInstall on USB device $vendor_id:$product_id." >&2
		exit 3
	fi
	return 0
}
enable_smart_install(){
	echo 'Enabling SmartInstall.'
	# First portion, the argument to -M
	#
	#	PUT /dev/featureStatus.xml HTTP/1.1
	#	CONTENT-LENGTH: 221
	#	USER-AGENT:hp Proxy/3.0
	#	HOST:localhost:3910
	#
	#	<?xml version="1.0" encoding="UTF-8"?>
	#	<featureStatus xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="featureStatus.xsd">
	# 	  <smartInstall>enabled</smartInstall>
	#	</featureStatus>
	#
	# Expected response(?) the part after ‘-n -2’
	#
	#	GET /dev/featureStatus.xml HTTP/1.1
	#	CONTENT-LENGTH: 0
	#	USER-AGENT:hp Proxy/3.0
	#	HOST:localhost:3910
	#
	usb_modeswitch -m 2 -r 2 -v 0x$vendor_id -p 0x$product_id \
	               -M 505554202F6465762F666561747572655374617475732E786D6C20485454502F312E310D0A434F4E54454E542D4C454E4754483A203232310D0A555345522D4147454E543A68702050726F78792F332E300D0A484F53543A6C6F63616C686F73743A333931300D0A0D0A3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D225554462D38223F3E0D0A3C6665617475726553746174757320786D6C6E733A7873693D22687474703A2F2F7777772E77332E6F72672F323030312F584D4C536368656D612D696E7374616E636522207873693A6E6F4E616D657370616365536368656D614C6F636174696F6E3D22666561747572655374617475732E787364223E0D0A20203C736D617274496E7374616C6C3E656E61626C65643C2F736D617274496E7374616C6C3E0D0A3C2F666561747572655374617475733E0D0A0D0A \
	               -n -2 474554202F6465762F666561747572655374617475732E786D6C20485454502F312E310D0A434F4E54454E542D4C454E4754483A20300D0A555345522D4147454E543A68702050726F78792F332E300D0A484F53543A6C6F63616C686F73743A333931300D0A0D0A -n -R
	if [ $? -eq 0 ]; then
		echo 'Now power cycle the printer, usb reset is not enough!'
	else
		echo "Couldn’t enable SmartInstall on USB device $vendor_id:$product_id." >&2
		exit 3
	fi
	return 0
}

pgrep -x cupsd || {
	echo 'CUPS is not running. Please start it.'
	until pgrep -x cupsd; do
		sleep 1
	done
	echo -n 'CUPS started! Waiting 3 seconds for it to prepare.'
	sleep 1; echo -n '.'; sleep 1; echo -n '.'; sleep 1; echo '.'
}

printer_attached || echo 'Attach the printer to the PC.'
until printer_attached; do
	sleep 1
done
get_dev_info
echo "Found $model."
read -n1 -p "Does it look like the proper device? [Y/n] > "
[[ "$REPLY" =~ ^(|y|Y|)$ ]] || {
	echo Aborted. >&2
	exit 3
}
echo
delete_printer
echo
disable_smart_install
until ! printer_attached; do
	sleep 1
done
echo 'I see printer detached. Attach it again in 10 seconds.'
until printer_attached; do
	sleep 1
done
echo -e 'I see printer attached, continuing.\n\nRunning hp-setup -i -a'
if hp-setup -i -a; then
	echo -e '\nhp-setup returned OK'
	echo 'Now remember, that printer is better to be attached to UPS and PC 24/7.'
else
	echo -e '\nhp-setup returned bad result.' >&2
	exit 3
fi
exit