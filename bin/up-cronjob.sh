#!/bin/sh
# See also https://nmap.org/book/ndiff-man-periodic.html

set -e

dir="/var/tmp/up-cronjob"
mkdir -p $dir && cd $dir

targets="`list-addresses 2>/dev/null`"

if [ ! -n "$targets" ]; then
	# no targets; are u offline?
	exit
else
	nmap -oA scan -Pn -A $targets > /dev/null
fi

if [ ! -e "scan-prev.xml" ]; then
	# first run, no diff given
	exit
else
	ndiff scan-prev.xml scan.xml
fi

ln -sf scan.xml scan-prev.xml

