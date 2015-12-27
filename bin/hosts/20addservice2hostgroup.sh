#!/bin/bash 
# 20addservices2hostgroup.sh
# Date: 2-10-11
# Version 1.4

shopt -s -o nounset 

# set the script name in a var
declare -rx SCRIPT=${0##*/}
declare -rx TMP=/usr/local/nagios/DNA/tmp
declare -rx SKEL=/usr/local/nagios/DNA/skel/hosts/20addservice2hostgroup
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
        echo -e "\nSyntax: ./$SCRIPT <hostgroup> <hostlevel> <servertype>"
        echo -e "\nExample: ./$SCRIPT ssf_prod_hg 1 apache"
	echo -e "\nAnother Example: ./$SCRIPT oas_db_hg 2 mysql "
	echo -e "\nAnother Example: ./$SCRIPT mt_qa_sphinx_hg 3 sphinx\n"
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

case "$hostlevel" in
1) cat $SKEL/level1/level1_host_generic_svc.skel | sed "s/HOSTGROUP/$hostgroup/g" > $TMP/$hostgroup.services.cfg ;;
2) cat $SKEL/level2/level2_host_generic_svc.skel | sed "s/HOSTGROUP/$hostgroup/g" > $TMP/$hostgroup.services.cfg ;;
3) cat $SKEL/level3/level3_host_generic_svc.skel | sed "s/HOSTGROUP/$hostgroup/g" > $TMP/$hostgroup.services.cfg ;;
*) printf "%s\n" "please choose either 1 2 or 3 for a host level"; exit 1 ;;
esac

list=`ls $SKEL/level$hostlevel* | cut -d '_' -f 3 | sort | uniq`
servertype=$3

# ensure the file skel exists

if  [ ! -f $SKEL/level$hostlevel/level$2_host_$servertype\_svc.skel ]; then
	echo -e "\n-ERROR-\n\nservertype: "$servertype" doesnt exist at hostlevel $hostlevel\n\nplease select from the following servertypes available at hostlevel $hostlevel: \n\n$list\n\n-INFO-\n\nuse /usr/local/nagios/bin/clone2skel.sh to create the needed skel template file for servertype: $servertype at hostlevel: $hostlevel\n"; exit 1
fi

case "$servertype" in
#list=`ls $SKEL/level* | cut -d '_' -f 3`
$servertype ) cat $SKEL/level$hostlevel/level$2_host_$servertype\_svc.skel | sed "s/HOSTGROUP/$hostgroup/g" >> $TMP/$hostgroup.services.cfg ;;
* ) echo -e "\nplease select from one of the following server types: \n$list"; exit 1;;
#postgres) cat $SKEL/level$2_host_postgres_svc.skel | sed "s/HOSTGROUP/$hostgroup/g" >> $TMP/$hostgroup.services.cfg ;;
#mysql) cat $SKEL/level$2_host_mysql_svc.skel | sed "s/HOSTGROUP/$hostgroup/g" >> $TMP/$hostgroup.services.cfg ;;
#apache) cat $SKEL/level$2_host_apache_svc.skel | sed "s/HOSTGROUP/$hostgroup/g" >> $TMP/$hostgroup.services.cfg ;;
#rpt) cat $SKEL/level$2_host_sphinx_svc.skel | sed "s/HOSTGROUP/$hostgroup/g" >> $TMP/$hostgroup.services.cfg ;; 
#tomcat) cat $SKEL/level$2_host_squid_svc.skel | sed "s/HOSTGROUP/$hostgroup/g" >> $TMP/$hostgorup.services.cfg ;;
#oasde) cat $SKEL/level$2_host_oasde_svc.skel | sed "s/HOSTGROUP/$hostgroup/g" >> $TMP/$hostgroup.services.cfg ;;
#oastrans) cat $SKEL/level$2_host_oastrans_svc.skel | sed "s/HOSTGROUP/$hostgroup/g" >> $TMP/$hostgroup.services.cfg ;;
#memcached) cat $SKEL/level$2_host_memcached_svc.skel | sed "s/HOSTGROUP/$hostgroup/g" >> $TMP/$hostgroup.services.cfg ;;
#sphinx) cat $SKEL/level$2_host_sphinx_svc.skel | sed "s/HOSTGROUP/$hostgroup/g" >> $TMP/$hostgroup.services.cfg;;
#scaler) cat $SKEL/skel/level$2_host_scaler_svc.skel | sed "s/HOSTGROUP/$hostgroup/g" >> $TMP/$hostgroup.services.cfg;;
#winad) cat $SKEL/level$2_host_winad_svc.skel | sed "s/HOSTGROUP/$hostgroup/g" >> $TMP/$hostgroup.services.cfg;;
#* ) echo "for servertype (the 3rd and final parameter) please select one of the following: mysql, apache rpt, tomcat, oasde, oasextractor, memcached, sphinx, winad, postgres or default"; exit 1
esac
	echo
        printf "%s\n" "OK - $TMP/$hostgroup.services.cfg created successfully"
	printf "%s\n" "please review the file for accuracy and issue the following command:"
	printf "%s\n" "cp $TMP/$hostgroup.services.cfg /usr/local/nagios/etc/services"
	echo
	
	# no longer running, remove the lock file
        rm -f "$lockfile"
	exit 0
