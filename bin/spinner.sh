#!/bin/bash

logfile=/tmp/mylog

echo >$logfile
trap "rm -f $logfile" EXIT

# Output message to log file.
function log_msg()
{
    echo "$*" >>$logfile
}


# Start spinner
sh spinner.sh &

# Perform really long task.
i=0
log_msg "Starting a really long job"
while [[ $i -lt 100 ]]
do
    sleep 1
    let i+=5
    log_msg "$i% complete"
done

sleep 1
echo

