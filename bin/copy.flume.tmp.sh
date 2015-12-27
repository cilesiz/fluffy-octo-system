#!/bin/bash 
# copy.flume.tmp.sh
# 3-10-14
# Version 1.1

shopt -s -o nounset 

# set the script name in a var
declare -rx SCRIPT=${0##*/}

# set the destination directory
declare -rx DESTDIR=/var/tmp/splunkPOC

if [ ! -d $DESTDIR ]; then
	mkdir -p $DESTDIR
fi

# check the param passed 

if [ $# != 1 ]; then
	echo -e "\n-ERROR- $SCRIPT requires exactly 1 arg"
	echo -e "\nSyntax: ./$SCRIPT <path to copy> destination dir will always be /var/tmp/splunkPOC"
	echo -e "\nExample: ./$SCRIPT /u/flume/infra/SITEMINDER/siteminder/siteminder-policysrv-2-SP6/PROD/kdias1000.ps.44441"
	exit 1
fi

declare -rx PATHTOCOPY=$1

cp -R $PATHTOCOPY $DESTDIR
if [ $? -eq 0 ]; then
	chmod -R 777 $DESTDIR
	echo -e "\n$PATHTOCOPY was successfully copied to $DESTDIR"
	exit 0
else
	echo -e "\nThere was an error copying $PATHTOCOPY to $DESTDIR"
	exit 1
fi
