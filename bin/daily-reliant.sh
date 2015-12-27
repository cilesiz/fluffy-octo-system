#!/bin/bash
# Name: daily-reliant.sh 
# Description: create a new file to keep track of the days activities within ~/reliant/daily-notes
# Date: 5/23/13
# Version 0.1

# variables

# Date
DATE=`date +%m.%d.%y`

# edit the file, will be created if it doesnt exist already 

/opt/local/bin/vim $HOME/reliant/daily-notes/$DATE.txt
if [ $? -eq "0" ]; then
	exit 0
else
	echo "an error occurred, please consult your local derka"
fi
