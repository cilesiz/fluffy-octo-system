#!/bin/bash
# 30addescalation.sh
# Description: Adds escalation chains and contacts based on skeleton files and host level 
# Date: 5-10-10
# Version 2.0
# Ross O. Fomerand

declare -rx SCRIPT=${0##*/}

# set the tmp dir
declare -rx TMP="/usr/local/nagios/DNA/tmp"

# set the skel direrctory
declare -rx SKEL="/usr/local/nagios/DNA/skel/vips/31addescalations"

# source all the functions needed
for function in `ls /usr/local/nagios/DNA/lib`; do
. /usr/local/nagios/DNA/lib/$function
done
# ensure the script is being run by root 
chk_root

if [ $# != 4 ]; then
        echo -e "\n./$SCRIPT requires at least 4 args"
        echo -e "\nSyntax: ./$SCRIPT <hostgroupname> <hostlevel (1 or 2)> <owner(ldap username)> <syseng(ldap username)>" 
        echo -e "\nExample: ./$SCRIPT ssf_prod_hg 1 sculver jlederma"
	echo -e "\nAnother Example: ./$SCRIPT ssf_prod_pub_hg 2 sculver jlederma\n"
        exit 1
fi

# lock file

lockfile="/usr/local/nagios/DNA/var/$SCRIPT.lock"
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
#echo -n "enter hostgroup name (example: ssf_prod_hg) : "
hostgroup=$1
if ! [ `echo ${hostgroup} | grep "_hg$"` ]; then
	echo "-ERROR- you must put _hg at the end of the hostgroup name, exiting"	
	exit 1
fi

# ensure the host group itself exists
	grep -ql $hostgroup /usr/local/nagios/etc/hostgroups/*

if [ $? -eq 1 ]; then
        echo -e "\n-ERROR- the hostgroup $hostgroup doesnt exist yet, please create it under the directory /usr/local/nagios/etc/hostgroups\n"
        exit 1
fi

hostlevel=$2

# ensure that the hostlevel is either 1 or 2 (level 3 is not escalated)
#echo -n "enter Tech Owner (must be ldap username): "
owner=$3
# ensure the owner exists

/usr/local/nagios/bin/show_contacts.sh | grep -qo ^$owner$
if [ $? -eq 1 ]; then
	echo "-ERROR- $owner doesnt exist in /usr/local/nagios/etc/contacts/contacts.cfg, exiting"
	echo "-INFO- You may want to run /usr/local/nagios/bin/show_contacts.sh to find out the username you want to specify"
	exit 1
fi

#echo -n "enter Systems Engineer (must be ldap username): "
syseng=$4
	/usr/local/nagios/bin/show_contacts.sh | grep -qo ^$syseng$
if [ $? -eq 1 ]; then
	echo "-ERROR- $syseng doesnt exist in /usr/local/nagios/etc/contacts/contacts.cfg, exiting"
	echo "-INFO- You may want to run /usr/local/nagios/bin/show_contacts.sh to find out the username you want to specify"
	exit 1
fi

case "$hostlevel" in
1) cat $SKEL/level1_vip_escalation.skel $SKEL/level1_service_escalation.skel $SKEL/31addescalations/level1_cg.skel | sed -e "s/HOSTGROUP/$hostgroup/g" -e "s/TOWNER/$owner/g" -e "s/SYSENG/$syseng/g"  >> /usr/local/nagios/DNA/tmp/$hostgroup.vip.escalations.cfg ;;
2) cat $SKEL/evel2_vip_escalation.skel $SKEL/level2_service_escalation.skel $SKEL/31addescalations/level3_cg.skel | sed -e "s/HOSTGROUP/$hostgroup/g" -e "s/TOWNER/$owner/g" -e "s/SYSENG/$syseng/g" >> /usr/local/nagios/DNA/tmp/$hostgroup.vip.escalations.cfg ;;
*) printf "%s\n" "please choose either 1 or 2 for a host level"; exit 1 ;;
esac
	echo
	printf "%s\n" "OK - /usr/local/nagios/DNA/tmp/$hostgroup.vip.escalations.cfg created succesfully"
	printf "%s\n" "please review the file and then issue the following command:"
	printf "%s\n" "cp /usr/local/nagios/DNA/tmp/$hostgroup.vip.escalations.cfg /usr/local/nagios/etc/escalations/"
	echo
	# no longer running, remove stale lock file
                rm -f "$lockfile"
	exit 0
