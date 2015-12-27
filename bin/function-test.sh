#!/bin/bash
echo " " > /Users/bender/test.log
function pingc { 
SERVER=$1
FELOG=$2
ping -c 3 $SERVER >/dev/null 2>&1



if [ "$?" = "0" ]; then
    msg="\n[OK] $SERVER is replying to our ping attempts\n"
    echo $msg >> $FELOG
else
    msg="\n[ERROR]HOST DOWN $SERVER is not replying to our ping attempts, time to check out ilo"
    echo $msg >> $FELOG
exit 1
fi
}
# ssh check
function sshc {
SERVER=$1
FELOG=$2                                                                                                                                                 
ssh root@$SERVER "echo echo &> /dev/null"
if [ "$?" -eq "1" ]; then
     msg="[ERROR] unable to ssh to the host....\n"
     echo -e $msg >> $FELOG
     exit 1
else
    msg="[OK] $SERVER passed ssh check\n"
    echo -e $msg >> $FELOG
fi
}

pingc "199.117.44.24" "/Users/bender/test.log"
sshc "199.117.44.24" "/Users/bender/test.log"
