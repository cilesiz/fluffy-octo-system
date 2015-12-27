#!/bin/bash
# function name: sanity_check_file_exists.sh
# description a function to ensure the file we plan on using exists
# Author: Ross O. Fomerand
# Date 1/21/10
# Version 0.5

declare -rx SCRIPT=${0##*/}
declare -rx TMP="/tmp/temp.$$"
declare -rx FILE=$1

# test to make sure we have exactly one positional parameter - the file to search for

if [ "$#" -ne "1" ];
	then
	printf "%s\n" "$SCRIPT:$LINEO you must specify a file as positional parameter number 1"
	exit 1
fi

# test to make sure the function exists

function sanity_check_file_exists {
	
	if test ! -f "$FILE" ; then
			printf "%s\n" "$SCRIPT:$FUNCNAME:$LINEO: $file doesnt exist, exiting" &>2
			exit 1
	fi
}

# example 