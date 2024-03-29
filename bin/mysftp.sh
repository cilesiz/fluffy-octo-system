#!/bin/sh

# mysftp - Makes sftp start up more like ftp

echo -n "User Account: "
read account

if [ -z $account ] ; then
	exit 0;		# changed their mind, presumably
fi

if [ -z "$1" ] ; then 
	echo -n "Remote host: "
	read host 
	if [ -z $host ] ; then 
		exit 0
	fi
else
	host=$1
fi

# end by switching to sftp. The -C flag enables compression here.

exec /usr/bin/sftp -C $account@$host
