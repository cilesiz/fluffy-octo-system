#!/bin/bash

# this file should have one host per line


host_list='/Users/bender/servers/qwest/etc/all_hosts'

# check for required arg

[ $# -gt 0 ] || {
    echo "usage: $0 command ..." >&2
    exit 1
}

# Execute the command on each host

for host in `cat "$host_list"` ; do
    echo " ** $host **"
    ssh "root@$host" "$@" || {
	echo "ERROR: Could not execute $* on $host!" >&2
}
done
