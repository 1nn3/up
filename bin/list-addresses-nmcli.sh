#!/bin/sh
# just a demo used nmcli(1)
# see also lsip(1p)

export LC_ALL=C # Damit der reguläre Ausdruck s.u. korrekt ist

nmlsip () {
	nmcli -g uuid,device connection show --active \
	| awk -F ':' '$2!="lo" {print $1}' \
	| xargs nmcli -t connection show \
	| sed -n -E "/^IP4.ADDRESS\[[0-9]+\]:/{s///;p}"
}

nmlsip | sort -u

