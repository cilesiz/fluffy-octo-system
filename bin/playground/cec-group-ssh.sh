#!/bin/bash

# Directory containing hosts files

host_dir='/Users/bender/servers/cec/etc/hosts/'

# Check for required args

[ $# -gt 1 ] || {
    echo "usage: $0 \"command(s)\" hostgroup ..." >&2
    exit 1
}

# pop commands off the stack
cmd="$1"
shift

# place full paths to each hostfile in $hostfiles
# this will lop once for every (remaining) argument
for hostfile ; do
    if [ -r "$host_dir/$hostfile" ] ; then
	hostfiles="$hostfiles $host_dir/$hostfile"
    else
	echo "INVALID GROUP: $hostfile" >&2
    fi
done

# make sure we actually have hosts to operate on 

[ -n "$hostfiles" ] || exit 1

# execute the command(s) on each host

for host in `sort $hostfiles | uniq` ; do
    echo " ** $host **"
    ssh "root@$host" "$cmd" || {
	echo "ERROR: Could not execute $cmd on $host!" >&2
}
done