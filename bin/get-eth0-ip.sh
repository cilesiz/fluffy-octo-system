#!/bin/sh
#
# ********** VARIABLE DEFINITIONS **********
#
# External interface
EXTIF="eth0"
# Internal interface
INTIF="eth1"
# Loop device/localhost
LPDIF="lo"
LPDIP="127.0.0.1"
LPDMSK="255.0.0.0"
LPDNET="$LPDIP/$LPDMSK"
# Text tools variables
IPT="/sbin/iptables"
IFC="/sbin/ifconfig"
G="/bin/grep"
SED="/bin/sed"
AWK="/usr/bin/awk"
ECHO="/bin/echo"
# Setting up external interface environment variables
# Set LC_ALL to "en" to avoid problems when awk-ing the IPs etc.
export LC_ALL="en"
EXTIP="`$IFC $EXTIF|$AWK /$EXTIF/'{next}//{split($0,a,":");split(a[2],a," ");print a[1];exit}'`"

