#!/bin/bash
# Script name: 01mkhost_group.sh
# Author: Ross O. Fomerand
# Date 1-31-11
# Version 1.0

# set some variables

declare -rx SCRIPT=${0##*/}
declare -rx HOSTGROUP=$1
declare -rx TMP=/usr/local/nagios/DNA/tmp
declare -rx HOSTGROUPFILE=/usr/local/nagios/DNA/skel/hosts/01mkhost_group/hostgroup_generic.skel

# test to see if the hostgroup exists
#grep -lq $HOSTGROUP /usr/local/nagios/etc/hostgroups/*.cfg

#if [ $? -eq 0 ]; then
#        echo "-ERROR- the hostgroup $HOSTGROUP already exists, no need to create it, exiting"
#        exit 1
#fi

if [ $# != 1 ]; then
        echo -e "\n-ERROR- $SCRIPT exactly 1 argument"
        echo -e "\nSyntax: ./$SCRIPT <hostgroup>"
        echo -e "\nExample: ./$SCRIPT mt_prod_web_hg\n"
        exit 1
fi

# make sure the suffix _hg exists in the hostgroup passed to keep things uniform

if ! [ `echo ${HOSTGROUP} | grep "_hg$"` ]; then
        echo -e "\n-ERROR- you must put _hg at the end of the hostgroup name, exiting\n"       
        exit 1
fi

# ensure the hostgroup doesnt already exist in $TMP

#if grep -ql $HOSTGROUP $TMP/*.cfg; then
#        echo -e "\n-ERROR- the file \"$TMP/$HOSTGROUP.host.cfg\" already exists please remove it then attempt to run the script again\n"
#        exit 1
#fi

cat $HOSTGROUPFILE | sed "s/HOSTGROUP/$HOSTGROUP/g" > $TMP/$HOSTGROUP.cfg
if [ $? -eq 0 ]; then
 	echo
        printf "%s\n" "OK - Created the hostgroup the file $TMP/$HOSTGROUP.cfg successfully"
	printf "%s\n" "please review the file for accuracy and then issue the following command:"
	printf "%s\n" "cp $TMP/$HOSTGROUP.cfg /usr/local/nagios/etc/hostgroups"
        echo
else
	echo
	printf "%s\n" "There was an error creating the file $TMP/$HOSTGROUP.cfg successfully"
fi
