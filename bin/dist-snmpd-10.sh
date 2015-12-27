#!/bin/bash

# script to distro snmpd.conf to solaris 10 zones
# make sure we recieve at least one positional parameter, if not print a usage msg
# variables
ZONEIP=ifconfig -a | /usr/local/bin/grep -o -m 1 "10.10.6.[0-9][0-9][0-9]*" | head -1
SVCA="/usr/sbin/svcadm"
SNMPD="/Users/bender/bin/datafiles/snmpd.conf"

scp $SNMPD root@$1.internal.upoc.com:/etc/sma/snmp/

ssh root@$1.internal.upoc.com "$SVCA enable sma"
