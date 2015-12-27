#!/bin/ksh
#
# SCRIPT: findlarge.ksh
#
# AUTHOR: Randy Michael
#
# DATE: 11/30/2000
#
# REV: 1.0.A
#
# PURPOSE: This script is used to search for files that
# are larger than $1 Meg. Bytes.  The search starts at
# the current directory that the user is in, `pwd`, and
# includes files in and below the user's current directory.
# The output is both displayed to the user and stored
# in a file for later review.
#
# REVISION LIST:
#
#
# set -n   # Uncomment to check syntax without ANY execution
# set -x   # Uncomment to debug this script


############################################

function usage
{
echo -e "\n***************************************"
echo -e "\n\nUSAGE:    findlarge.ksh  [Number_Of_Meg_Bytes]"
echo -e "\nEXAMPLE:  filelarge.ksh  5"
echo -e "\n\nWill Find Files Larger Than 5 Mb in, and Below, the Current Directory..."
echo -e "\n\nEXITING...\n"
echo -e "\n***************************************"
exit
}

############################################

function cleanup
{
echo -e "\n********************************************************"
echo -e "\n\nEXITING ON A TRAPPED SIGNAL..."
echo -e "\n\n********************************************************\n"
exit
}

############################################

# Set a trap to exit.  REMEMBER - CANNOT TRAP ON kill -9 !!!!

trap 'cleanup' 1 2 3 15

############################################

# Check for the correct number of arguments and a number
# Greater than zero

if [ $# -ne 1 ]
then
        usage
fi

if [ $1 -lt 1 ]
then
	usage
fi

############################################

# Define and initialize files and variables here...

THISHOST=`hostname` 	# Hostname of this machine

DATESTAMP=`date +"%h%d:%Y:%T"`

SEARCH_PATH=`pwd`	# Top level directory to search

MEG_BYTES=$1		# Number of Mb for file size trigger

DATAFILE="/tmp/filesize_datafile.out" # Data storage file
>$DATAFILE		# Initialize to a null file

OUTFILE="/tmp/largefiles.out" # Output user file
>$OUTFILE		# Initialize to a null file

HOLDFILE="/tmp/temp_hold_file.out" # Temporary storage file
>$HOLDFILE		# Initialize to a null file

############################################

# Prepare the output user file

echo -e "\n\nSearching for Files Larger Than ${MEG_BYTES}Mb starting in:"
echo -e "\n==> $SEARCH_PATH"
echo -e "\n\nPlease Standby for the Search Results..."
echo -e "\n\nLarge Files Search Results:" >> $OUTFILE
echo -e "\nHostname of Machine: $THISHOST" >> $OUTFILE
echo -e "\nTop Level Directory of Search:" >> $OUTFILE
echo -e "\n==> $SEARCH_PATH" >> $OUTFILE
echo -e "\nDate/Time of Search: `date`" >> $OUTFILE
echo -e "\n\nSearch Results Sorted by Time:" >> $OUTFILE

############################################

# Search for files > $MEG_BYTES starting at the $SEARCH_PATH

find $SEARCH_PATH -type f -size +${MEG_BYTES}000000c \
	 -print > $HOLDFILE

# How many files were found?

if [ -s $HOLDFILE ]
then
    NUMBER_OF_FILES=`cat $HOLDFILE | wc -l`

    echo -e "\n\nNumber of Files Found: ==> $NUMBER_OF_FILES\n\n" >> $OUTFILE

    # Append to the end of the Output File...

    ls -lt `cat $HOLDFILE` >> $OUTFILE

    # Display the Time Sorted Output File...

    more $OUTFILE

    echo -e "\n\nThese Search Results are Stored in ==> $OUTFILE"
    echo -e "\n\nSearch Complete...EXITING...\n\n\n"
else
    cat $OUTFILE # Show the header information
    echo -e "\n\nNo Files were Found in the Search Path that"
    echo -e "are Larger than ${MEG_BYTES}Mb\n\n"
    echo -e "\nEXITING...\n\n"
fi
