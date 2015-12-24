#! /usr/bin/env bash

[ "$1" = 'period-changed' ] && {
	[ "$3" = 'daytime' ] && {
		xbacklight -set 55
		:
	}||{ xbacklight -set 25; }
}
