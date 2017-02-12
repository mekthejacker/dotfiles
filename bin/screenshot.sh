#!/usr/bin/env bash

# screenshot.sh
# A wrapper for scrot.
# screenshot.sh © 2015 deterenkelt

# Besides the usual features of scrot like
#
# - taking screenshots in PNG and JPEG formats (PNG is by default);
# - using delay which is helpful with taking screenshots of hover windows;
# - taking an area on the screen;
# - using only focused window;
#
# it aims at additional tasks
#
# - delete taken screenshot after ten minutes (helps to not mess the $XDG_DESKTOP_DIR);
# - run pngcrush on PNG screenshots to reduce their size;
# - add -indexed key to automatically convert PNG image to indexed (if you don’t
#   want to run GIMP afterwards to do it; though, scrot seems to convert black
#   and white images to indexed automatically, at least that was the behaviour
#   I’ve seen when taking shots from manga);

# NOTE
#   It’d be really helpful to have a WM that recognizes key codes (numeric codes)
# and not only symbolic ones. For example, i3 WM. This allows to use
#   Super+R_Control
# and
#   Super+L_Control
# as two separate keybindings.
# See https://github.com/deterenkelt/dotfiles/blob/master/.i3/config.template
#  for examples of use.

# DEPENDENCIES
#	bash >=4.2
#	scrot
#	pngcrush
#	notify-send
#	    (I use tinynotify-send, it’s a bit incompatible with libnotify’s
#	     notify-send key names).
#	pngtopam, pnmcolormap, pnmremap and pnmtopng
#	    which are usually found in the netpbm package.
#	viewnior, gimp
#	atd
#	    that is already set up and running.

set -x
# exec &>/tmp/envlogsscr

# for scrot exec command
export FORMAT INDEXED DISPLAY OPEN_IN_GIMP

pushd `xdg-user-dir DESKTOP` # defaults to $HOME
while [ "$1" ]; do
	case "$1" in
		-delay) delay='-d 5' ;; # seconds
		-area)
			area='-s' && sleep 1  # sleep is for the WM
			OPEN_IN_GIMP=t
			;;
		-window) window='-u' ;;
		-indexed) INDEXED=t ;;
		-jpeg) FORMAT='jpeg -q 92' ;; # JPEG quality
		*)
			notify-send --hint int:transient:1 -t 3500 -i error "$0" "Unknown option: ‘$1’."
			exit 5;;
	esac
	shift
done
[ -v area -a -v window ] \
	&& echo '-area and -window cannot be given simultaneously.' >&2 && exit 4
[ -v area -a -v delay ] \
	&& echo '-area and -delay cannot be given simultaneously.' >&2 && exit 5
[ -v INDEXED -a -v jpeg ] \
	&& echo '-indexed and -jpeg cannot be given simultaneously.' >&2 && exit 6

# characters preceded with
#    $  are interpreted as scrot internals
#    %  are passed to strftime
# so $=$$, %=%%, \=\\.
scrot ${area:-} ${window:-} ${delay:-} %s.${FORMAT:=png} -e '
	[ "$$FORMAT" = png ] && {
		pngcrush -reduce -ow -nofilecheck $f \\
			|| notify-send -l -t 3000 -i error "Failed to pngcrush screenshot" "“$f”"
		[ -v INDEXED ] && {
			pngtopam $f | tee /tmp/$n.ppm | pnmcolormap 256 >/tmp/$n_palette.ppm
			pnmremap -map=/tmp/$n_palette.ppm /tmp/$n.ppm | pnmtopng >$f
			rm /tmp/$n.ppm /tmp/$n_palette.ppm
		}
	}
	[ -v OPEN_IN_GIMP ] && gimp $f || {
		viewnior --class="screenshot_preview" $f
		at "`date --date="+10 minutes" +"%%H:%%M"`" <<<"rm $f"
	}
'
popd
