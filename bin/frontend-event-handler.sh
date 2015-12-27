#!/bin/bash

#check for required positional parameters
[ $# -gt 0 ] || {
        echo "usage: `basename $0` <hostname>" >&2
	echo "example: `basename $0` us16"
        exit 1
}
feserver="us$1"
LDATE=`date +%F.%H.%M.%S`
FELOG=/tmp/$feserver.$LDATE
echo " " > $FELOG
TARGET_HOST="$feserver.dadanoc.com"

# ping check
ping -c 3 $TARGET_HOST>/dev/null 2>&1
if [ "$?" = "0" ]; then
    msg="\n[OK] $TARGET_HOST is replying to our ping attempts\n"
    echo -e "$msg" >> $FELOG
else
    msg="\n[ERROR]HOST DOWN $TARGET_HOST is not replying to our ping attempts, time to check out ilo"
    echo -e "$msg" >> $FELOG
exit 1
fi

# ssh check
ssh root@$TARGET_HOST "echo echo &> /dev/null"
if [ "$?" -eq "1" ]; then
     msg="\n[ERROR] unable to ssh to the host..."
     echo -e "$msg" >> $FELOG
     exit 1
else
    msg="\n[OK] $TARGET_HOST passed ssh check"
    echo -e "$msg" >> $FELOG
fi
# dependency 1 check the alteon 
ping -c 3 192.168.200.83>/dev/null 2>&1
if [ "$?" = "0" ]; then
    ssh root@192.168.200.83 "/usr/nagios/libexec/check_http -H us.dada.net -t 10 -u /video/zapping -e 200" &> /dev/null
    if [ "$?" = "0" ]; then
	msg="\n[OK] Frontend Dependency #1 the alteon is functioning correctly"
	echo -e "$msg" >> $FELOG
    else
	msg="\n[ERROR] Frontend Dependency #1 the alteon is down"
	echo -e "$msg" >> $FELOG
	exit 1
    fi
else
    msg="\n[WARNING] powerless is down skipping alteon check"
    echo -e "$msg" >> $FELOG
fi

# dependency #2 load balancer connectivity
ping -c 3 us92.dadanoc.com>/dev/null 2>&1
if [ "$?" = "0" ]; then
    msg="\n[OK] the primary load balancer is replying to our ping attempts"
    echo -e "$msg" >> $FELOG
else
    msg="\n[ERROR] us92 is down checking if the load balancer is in failover mode..."
    echo -e "$msg" >> $FELOG
    
    ping -c 3 us76.dadanoc.com >/dev/null 2>&1
    if [ "$?" = "0" ]; then
	msg="\n[OK] the secondary load balancer us76 is replying to our ping attempts continuing"
	echo -e "$msg" >> $FELOG
	ssh root@us76.dadanoc.com "touch k"
	if [ "$?" -eq "1" ]; then
	    msg="\n[ERROR] secondary load balancer is alive but the sshd daemon is down"
	    echo "$msg" >> $FELOG
	    exit 1
	else
	    ssh root@$TARGET_HOST "/usr/nagios/libexec/check_tcp -H 192.168.128.76 -p 3306 -w 10 -c 20" &> /dev/null 
	    if [ "$?" = "0" ]; then
		msg="\n[OK] Able to connect to us76 the secondary mysql load balancer through tcp port 3306"
		echo -e "$msg" >> $FELOG
	    else
		msg="\n[ERROR] Unable to connect to us76 the secondary mysql load balancer through tcp port 3306"
		echo -e "$msg" >> $FELOG
	       
	
		msg="\n[ERROR]us76 is down, both primary and secondary load balancers are down"
		echo -e "$msg" >> $FELOG
		exit 1
	    fi
	fi
	    
	ssh root@$TARGET_HOST "/usr/nagios/libexec/check_tcp -H 192.168.128.92 -p 3306 -w 10 -c 20" &> /dev/null
	if [ "$?" = "0" ]; then
	    msg="\n[OK] Able to connect to us92 the primary mysql load balancer through tcp port 3306"
	    echo -e "$msg" >> $FELOG
	else
	    msg="\n[ERROR] Unable to connect to us92 the primary mysql load balancer through tcp port 3306"
	    echo -e "$msg" >> $FELOG
	    exit 1
	fi
    fi
fi
# dependency #3 jenne cluster health
# jenna01
# check_mysql -H $HOSTADDRESS$ -u $ARG1$ -p $ARG2$ -S -w $ARG3$ -c $ARG4$
ssh root@us16.dadanoc.com "/usr/nagios/libexec/check_mysql -H 192.168.128.31 -u nagios -p maniaco -S -w 120 -c 600" &> /dev/null
if [ "$?" -eq "0" ]; then
    msg="\n[OK] jenna01's health seems to be ok"
    echo -e "$msg" >> $FELOG
else
    msg="\n[WARNING] jenna01's health is not ok"
    echo -e "$msg" >> $FELOG
fi

ssh root@us16.dadanoc.com "/usr/nagios/libexec/check_mysql -H 192.168.128.47 -u nagios -p maniaco -S -w 120 -c 600" &> /dev/null

if [ "$?" -eq "0" ]; then
    msg="\n[OK] jenna01's health seems to be ok"
    echo -e "$msg" >> $FELOG
else
    msg="\n[WARNING] jenna02's health is ok"
    echo -e "$msg" >> $FELOG
fi

ssh root@us16.dadanoc.com "/usr/nagios/libexec/check_mysql -H 192.168.128.79 -u nagios -p maniaco -S -w 120 -c 600" &> /dev/null

if [ "$?" -eq "0" ]; then
    msg="\n[OK] jenna03's health seems to be ok"
    echo -e "$msg" >> $FELOG
else
    msg="\n[WARNING] jenna03's health is not ok"
    echo -e "$msg" >> $FELOG
fi

# dependency #4 linda cluster - to do

# dependency #5 bull cluster us62 us39 check_nrpe -H $HOSTADDRESS$ -t 60 -c $ARG1$

ssh root@us16.dadanoc.com "/usr/nagios/libexec/check_nrpe -H 192.168.128.62 -t 60 -c check_mysql" &> /dev/null
if [ "$?" -eq "0" ]; then
    msg="\n[OK] bull01's health seems to be ok"
    echo -e "$msg" >> $FELOG
else
    msg="\n[WARNING] bull01's health is not ok"
    echo -e "$msg" >> $FELOG
fi

ssh root@us16.dadanoc.com "/usr/nagios/libexec/check_nrpe -H 192.168.128.39 -t 60 -c check_mysql" &> /dev/null
if [ "$?" -eq "0" ]; then
    msg="\n[OK] bull02's health seems to be ok"
    echo -e "$msg" >> $FELOG
else
    msg="\n[WARNING] bull02's health is not ok"
    echo -e "$msg" >> $FELOG
fi

# dependency #6 brauner11 - to do

# dependency #7 memcache servers us20 us36 us60
# check_memcached!11211 check_memcached!11212 check_memcached!11213

ssh root@us16.dadanoc.com "/usr/nagios/libexec/check_memcached 192.168.128.20 11211" &> /dev/null
#us20mem11212=`ssh root@us16.dadanoc.com "/usr/nagios/libexec/check_memcached 192.168.128.20 11212"`
#us20mem11213=`ssh root@us16.dadanoc.com "/usr/nagios/libexec/check_memcached 192.168.128.20 11213"`


if [ "$?" -eq "0" ]; then
    msg="\n[OK] memcache20's port 11211 health seems to be ok"
    echo -e "$msg" >> $FELOG
else
    msg="\n[WARNING] memcache20's port 11211 health is not ok"
    echo -e "$msg" >> $FELOG
fi

ssh root@us16.dadanoc.com "/usr/nagios/libexec/check_memcached 192.168.128.36 11211" &> /dev/null
if [ "$?" -eq "0" ]; then
    msg="\n[OK] memcache36's port 11211 health seems to be ok"
    echo -e "$msg" >> $FELOG
else
    msg="\n[WARNING] memcache36's port 11211 health is not ok"
    echo -e "$msg" >> $FELOG
fi

ssh root@us16.dadanoc.com "/usr/nagios/libexec/check_memcached 192.168.128.60 11211" &> /dev/null
if [ "$?" -eq "0" ]; then
    msg="\n[OK] memcache60's port 11211 health seems to be ok"
    echo -e "$msg" >> $FELOG
else
    msg="\n[WARNING] memcache60's port 11211 health is not ok"
    echo -e "$msg" >> $FELOG
fi

# server specific stats

LOAD_AVERAGE=`ssh root@$TARGET_HOST "/usr/nagios/libexec/check_load -w 5,5,5 -c 10,10,10"`
MEM_USAGE=`ssh root@$TARGET_HOST "/usr/nagios/libexec/check_mem -c 2% -w 5%"`
NUM_OF_PROCS=`ssh root@$TARGET_HOST "/usr/nagios/libexec/check_procs -w 150 -c 200"`
msg1="\nLOAD AVERAGE of $TARGET_HOST is $LOAD_AVERAGE"
echo -e "$msg1" >> $FELOG
msg2="\nMemory Usage IS $MEM_USAGE"
echo -e "$msg2" >> $FELOG
msg3="\nNumber of proccesses running is $NUM_OF_PROCS"
echo -e "$msg3" >> $FELOG
CONNECTIONS=`ssh root@$TARGET_HOST "cd /usr/nagios/libexec && perl check_connections.pl -w 300 -c 400 -u super"`
msg4="\nNumber of current connections for apache is $CONNECTIONS"
echo -e "$msg4" >> $FELOG
ssh root@$TARGET_HOST "/usr/nagios/libexec/vmstat_loadmon.ksh" >> $FELOG
less $FELOG
