# Clear Zombie process 
#!/bin/ksh

###
### Korn shell script for clear zombie processes. 
### Run at command line with 'nohup zombie_clear.ksh' or use crontab.
###

### Respond to hardware signals
trap '' 1 2 15
while :
do
	### Use 'ps -el' and pull out the status
	for x in `ps -el | awk '$2 ~ /Z/ {print $4}'`
	do
		### Force defunct process to be reaped by its parent
		preap $x
	done
sleep 86400 # every 24 Hrs.
done

trap 1 2 15

exit 0;



##############################################################################
### This script is submitted to BigAdmin by a user of the BigAdmin community.
### Sun Microsystems, Inc. is not responsible for the
### contents or the code enclosed. 
###
###
### Copyright 2008 Sun Microsystems, Inc. ALL RIGHTS RESERVED
### Use of this software is authorized pursuant to the
### terms of the license found at
### http://www.sun.com/bigadmin/common/berkeley_license.html
##############################################################################
