#!/bin/ksh
#
# SCRIPT: get_ftp_files_pw_var.ksh
# AUTHOR: Randy Michael
# DATE: July 15, 2002 
# REV: 1.1.P
#
# PLATFORM: Not Platform Dependent
#
# PURPOSE: This shell script uses FTP to get a one or more remote
#          files from a remote machine. this shell script uses a
#          remotely defined password variable.
#
# set -n # Uncomment to check the script syntax without any execution
# set -x # Uncomment to debug this shell script
#
###################################################################
################## DEFINE VARIABLES HERE ##########################
###################################################################

REMOTEFILES=$1

THISSCRIPT=$(basename $0)
RNODE="wilma"
USER="randy"
LOCALDIR="/scripts/download"
REMOTEDIR="/scripts"

###################################################################
################## DEFINE FUNCTIONS HERE ##########################
###################################################################

pre_event ()
{
# Add anything that you want to execute in this function. You can
# hardcode the tasks in this function or create an external shell
# script and execute the external function here.

:  # No-Op: The colon (:) is a No-Op character. It does nothing and
   # always produces a 0, zero, return code.
}

###################################################################

post_event ()
{
# Add anything that you want to execute in this function. You can
# hardcode the tasks in this function or create an external shell
# script and execute the external function here.

:  # No-Op: The colon (:) is a No-Op character. It does nothing and
   # always produces a 0, zero, return code.
}

###################################################################

usage ()
{
echo "\nUSAGE: $THISSCRIPT \"One or More Filenames to Download\" \n"
exit 1
}

###################################################################

usage_error ()
{
echo "\nERROR: This shell script requires a list of one or more
       files to download from the remote site.\n"

usage
}

###################################################################
##################### BEGINNING OF MAIN ###########################
###################################################################

# Test for exactly one command-line argument. This should contain a
# list of one or more files to act on.

(($# != 1)) && usage_error

# Get a password

. /usr/sbin/setlink.ksh

pre_event

ftp -i -v -n $RNODE <<END_FTP

user $USER $RANDY
binary
lcd $LOCALDIR
cd $REMOTEDIR
mget $REMOTEFILES
bye

END_FTP

post_event

