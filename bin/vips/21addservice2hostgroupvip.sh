#!/bin/bash
# 20addservices2hostgroup.sh
# Date: 5-10-10
# Version 1.2

shopt -s -o nounset 

# set the script name in a var
declare -rx SCRIPT=${0##*/}
declare -rx TMP=/usr/local/nagios/DNA/tmp
declare -rx SKEL=/usr/local/nagios/DNA/skel/vips/21addservice2hostgroup
declare -rx VAR=/usr/local/nagios/DNA/var
# source all the functions needed
for function in `ls /usr/local/nagios/DNA/lib`; do
	. /usr/local/nagios/DNA/lib/$function
done

# ensure the script is being run by root 
chk_root

# lock file

lockfile="$VAR/$SCRIPT.lock"
if test -e "$lockfile"; then
        pid="$(cat "$lockfile")"
        if ps $pid >/dev/null ; then
       		 # still running
       		 echo "ABORTING: Another instance of $SCRIPT is running ($pid)" >&2
	else   

        # no longer running, remove stale lock file
	        rm -f "$lockfile"
	fi
fi

# we can proceed ...write our pid to the lockfile 

	echo "$$" > "$lockfile"

# ensure that the tmp dir exists

if test -d "$TMP" ; then
        if test ! -w "$TMP"; then
                printf "ERROR, $SCRIPT: the temp directory $TMP exists but is not writable, exiting"
                exit 1
        fi
fi

# now we check the vars passed 

if [ $# != 3 ]; then
        echo -e "$SCRIPT requires at least 3 args"
        echo -e "\nSyntax: ./$SCRIPT <hostgroup> <severity level 1,2 or 7> <port number>"
        echo -e "\nExample: ./$SCRIPT ssf_vip_hg 1 80"
	echo -e "\nAnother Example: ./$SCRIPT oas_db_hg 2 3306 "
	echo -e "\nAnother example: ./$SCRIPT mt_shared_dev_hg 7 80"
        exit 1
fi
hostgroup=$1
# sanity check
# ensure that the suffix _hg exists in the parameter (thanks for the tip sking ;)
if ! [ `echo ${hostgroup} | grep "_hg$"` ]; then
        echo -e "\n-ERROR- you must put _hg at the end of the hostgroup name, exiting\n"       
        exit 1
fi

# ensure that the hostgroup exists before we start creating definitions for it

	grep -ql $hostgroup /usr/local/nagios/etc/hostgroups/*

if [ $? -eq 1 ]; then
	echo -e "\n-ERROR- the hostgroup $hostgroup doesnt exist yet, please create it under the directory /usr/local/nagios/etc/hostgroups"
	exit 1
fi

hostlevel=$2

port=$3
cat $SKEL/level$2_vip_svc.skel | sed -e "s/HOSTGROUP/$hostgroup/" -e "s/PORT/$port/" > $TMP/$hostgroup.vip.services.cfg

	echo
        printf "%s\n" "OK - $TMP/$hostgroup.vip.services.cfg created successfully"
	printf "%s\n" "please review the file for accuracy and issue the following command:"
	printf "%s\n" "cp $TMP/$hostgroup.vip.services.cfg /usr/local/nagios/etc/services"
	echo
	
	# no longer running, remove the lock file
        rm -f "$lockfile"
	exit 0
