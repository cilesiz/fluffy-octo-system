#!/bin/bash

[ $# -gt 0 ] || {
        echo "usage: `basename $0` <hostname>" >&2
	echo "example: `basename $0` us16"
        exit 1
}

TARGET_HOST="$1.admarketplace.net"

# ping check
ping -c 3 $TARGET_HOST>/dev/null 2>&1
if [ "$?" = "0" ]; then
    echo -e "\n[OK] $TARGET_HOST is replying to our ping attempts\n"
else
    echo -e "\nHOST DOWN $TARGET_HOST is not replying to our ping attempts, time to check out ilo"
exit 1
fi

# ssh check
echo -e "Attempting to ssh to $TARGET_HOST\n"
ssh root@$TARGET_HOST "echo echo &> /dev/null"
if [ "$?" -eq "1" ]; then
    echo -e "[ERROR] unable to ssh to the host....\n"
else
    echo -e "[OK] $TARGET_HOST passed ssh check\n"
fi

# gather some information about the host

LOAD_AVERAGE=`ssh root@$TARGET_HOST "/usr/local/nagios/libexec/check_load -w 5,5,5 -c 10,10,10"`
MEM_USAGE=`ssh root@$TARGET_HOST "/usr/local/nagios/libexec/check_mem -c 2% -w 5%"`
NUM_OF_PROCS=`ssh root@$TARGET_HOST "/usr/local/nagios/libexec/check_procs -w 150 -c 200"`
NUMONLY=`echo "$TARGET_HOST" | grep -o [1-9][1-9]`
echo -e "LOAD AVERAGE IS:\n"
echo -e "$LOAD_AVERAGE\n"
echo -e "Memory Usage IS:\n"
echo -e "$MEM_USAGE\n"
echo -e "Number of proccesses running:\n"
echo -e "$NUM_OF_PROCS"
echo -e "\nDeterming CPU Usage through vmstat..."
ssh root@$TARGET_HOST "/usr/local/nagios/libexec/vmstat_loadmon.ksh"
echo -e "Detecting what kind of host this is....\n"
ssh root@$TARGET_HOST "ps aux | grep -m 2 apache | grep -v grep" &> /dev/null
if [ "$?" -eq 0 ]; then
    echo -e "APACHE DETECTED....testing how many connections apache is currently handling\n"
    ssh root@$TARGET_HOST "cd /usr/local/nagios/libexec && perl check_connections.pl -w 300 -c 400 -u super" 
else
    ssh root@$TARGET_HOST "ps aux | grep -m 2 memcache | grep -v grep" &> /dev/null
    if [ "$?" -eq 0 ]; then
	echo -e "memcached DETECTED....testing how many connections memcache is currently handeling"
	ssh root@$TARGET_HOST "cd /usr/local/nagios/libexec && perl check_connections.pl -w 3000 -c 5000 -u 102"
	
	echo -e "checking to see if the memcached process is running correctly on each port"
	echo -e "checking memcached port 11211"
	ssh root@us16.dadanoc.com "/usr/local/nagios/libexec/check_memcached 192.168.128.$NUMONLY 11211"
	echo -e "checking memcached port 11212"
	ssh root@us16.dadanoc.com "/usr/local/nagios/libexec/check_memcached 192.168.128.$NUMONLY 11212"
	echo -e "checking memcached port 11213"
	ssh root@us16.dadanoc.com "/usr/local/nagios/libexec/check_memcached 192.168.128.$NUMONLY 11212"
    else
	ssh root@$TARGET_HOST "ps aux | grep -m 2 mysql | grep -v grep" &> /dev/null
	if [ "$?" -eq 0 ]; then
	    echo -e "checking the number of connections to mysql:"
	    ssh root@$TARGET_HOST "cd /usr/local/nagios/libexec && perl check_connections.pl -w 200 -c 400 -u mysql"
	fi
    fi
fi

echo -e "Host Checkup Complete Exiting\n"
