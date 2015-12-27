#!/bin/bash

# Directory containing host files 
host_dir='/Users/bender/servers/cec/etc/hosts/'

# check for required arguements

[ $# -gt 2 ] || {
	echo "usage: $0 \"local files(s)\" remote_dir hostgroup ...." >&2
	exit 1
}

# take the local and remote files off the param stack

lfile="$1"
shift
rdir="$1"
shift

# Place full paths to each host file in $hostfiles
# This loop will loop once for each (remaining) parameter

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
	scp -r "$lfile" "root@"$host":"$rdir"" || {
		echo "ERROR: Could not copy  $lfile to $host:$rdir" >&2
}
done
