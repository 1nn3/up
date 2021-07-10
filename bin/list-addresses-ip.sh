#!/bin/sh
# just a demo used ip(8)
# see also lsip(1p)

ip -f inet -br a | awk '$1!="lo" && $2!="DOWN" {print $NF}' | sort -u

