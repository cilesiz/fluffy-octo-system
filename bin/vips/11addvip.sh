#!/bin/bash 
# 10addhost.sh 
# 5-9-10
# Version 2.0

shopt -s -o nounset 

# set the script name in a var
declare -rx SCRIPT=${0##*/}

# set the tmp dir
declare -rx TMP="/usr/local/nagios/DNA/tmp"

# set the skel dir
declare -rx SKEL="/usr/local/nagios/DNA/skel/vips/11addhost" 

# set the functions dir
declare -rx LIBDIR="/usr/local/nagios/DNA/lib"

# set the var dir
declare -rx VARDIR="/usr/local/nagios/DNA/var"

# source all the functions needed
for function in `ls $LIBDIR`; do
. $LIBDIR/$function
done
# ensure the script is being run by root 
chk_root

# lock file

lockfile="$VARDIR/$SCRIPT.lock"
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

# ensure that the tmp dir exists and is writable
if test -d "$TMP" ; then
	if test ! -w "$TMP"; then
		printf "-ERROR- $SCRIPT: the temp directory $TMP exists but is not writable, exiting"
		exit 1
	fi
fi

# global vars

declare -rx BINDIR=/usr/local/nagios/DNA/bin

# now we check the params passed 

if [ $# != 6 ]; then
	echo -e "\n-ERROR- $SCRIPT requires exactly 6 args"
	echo -e "\nSyntax: ./$SCRIPT <shortname> <domainname> <hostlevel> <hostgroup> <techowner> <syseng>"
	echo -e "\nExample: ./$SCRIPT mt-prod-web-1 host.cdc.advance.net 1 mt_prod_web_hg sculver@advance.net jlederma@advance.net\n"
	exit 1
fi

declare -rx NAME=$1
# make sure that the config file doesnt already exist in TMP so we dont overwrite it 
#if grep -q $NAME $TMP/*.host.cfg; then 
#	echo -e "\n-ERROR- the file \"$TMP/$NAME.host.cfg\" already exists please remove it then attempt to run the script again\n"
#	exit 1
#fi

declare -rx DOMAIN=$2

# write test to ensure HOSTLEVEL = 1 or 2 or 3
declare -rx HOSTLEVEL=$3
declare -rx HOSTGROUP=$4 
# check to see if the hostgroup variable has been defined
if [ -z "$HOSTGROUP" ]; then
echo "-ERROR- hostgroup parameter must be defined, exiting"
exit 1
fi

# test to see if the hostgroup exists
grep -lq $HOSTGROUP /usr/local/nagios/etc/hostgroups/*.cfg
if [ $? -eq 1 ]; then
	echo "-ERROR- the hostgroup $HOSTGROUP doesn't exist yet, you must use the script $BINDIR/01mkhost_group.sh to create it, exiting"
	exit 1
fi

# make sure the suffix _hg exists in the hostgroup passed to keep things uniform
if ! [ `echo ${HOSTGROUP} | grep "_hg$"` ]; then
        echo -e "\n-ERROR- you must put _hg at the end of the hostgroup name, exiting\n"       
        exit 1
fi

####### end of $HOSTGROUP Tests #########


declare -rx TOWNER=$5
# test to make sure that $TOWNER actually exists
	grep -qo "$TOWNER" /usr/local/nagios/etc/contacts/contacts.cfg
if [ $? -eq 1 ]; then
	echo -e "\n-ERROR- The email address the TechOwner $TOWNER doesnt exist in /usr/local/nagios/etc/contacts/contacts.cfg\n"
	exit 1
fi

####### end of $TOWNER tests #########

declare -rx SYSENG=$6

# ensure that the SYSENG email exists in contacts.cfg
#	grep -qo "$SYSENG" /usr/local/nagios/etc/contacts/contacts.cfg 
#if [ $? -eq 1 ]; then 
#	echo -e "\n-ERROR- The email address specified for the Systems Engineer $SYSENG doesnt exist in /usr/local/nagios/etc/contacts/contacts.cfg\n"
#	exit 1
#fi

####### end of $SYSENG tests #########

##### This is where the real work begins #######
# concatinate the corresponding skel file specified in the $HOSTLEVEL var
case "$HOSTLEVEL" in
1) cat $SKEL/11addhost/level1_host.skel | sed -e "s/NAME/$NAME/" -e "s/DOMAIN/$DOMAIN/" -e "s/HLEVEL/$HOSTLEVEL/" -e "s/HOSTGROUP/$HOSTGROUP/" -e "s/TOWNER/$TOWNER/" -e "s/SYSENG/$SYSENG/"  > $TMP/$NAME.vip.host.cfg ;;
2) cat $SKEL/11addhost/level2_host.skel | sed -e "s/NAME/$NAME/" -e "s/DOMAIN/$DOMAIN/" -e "s/HLEVEL/$HOSTLEVEL/" -e "s/HOSTGROUP/$HOSTGROUP/" -e "s/TOWNER/$TOWNER/" -e "s/SYSENG/$SYSENG/"  > $TMP/$NAME.vip.host.cfg ;;
3) cat $SKEL/level3_host.skel | sed -e "s/NAME/$NAME/" -e "s/DOMAIN/$DOMAIN/" -e "s/HLEVEL/$HOSTLEVEL/" -e "s/HOSTGROUP/$HOSTGROUP/" -e "s/TOWNER/$TOWNER/" -e "s/SYSENG/$SYSENG/" > $TMP/$NAME.vip.host.cfg ;;
*) printf "%s\n" "please choose either 1 2 or 3 for a host level"; exit 1; rm -f "$lockfile" ;;
esac

# get rid of pv

sed -i 's/,PV//' $TMP/$NAME.vip.host.cfg

	echo
	printf "%s\n" "OK - Created the VIP host file $TMP/$NAME.vip.host.cfg successfully"
	printf "%s\n" "please review the file and then issue the following command to make it live"
	printf "%s\n" "cp /usr/local/nagios/DNA/tmp/$NAME.vip.host.cfg /usr/local/nagios/etc/hosts"
	echo
# remove the lockfile
rm -f "$lockfile"
exit 0
