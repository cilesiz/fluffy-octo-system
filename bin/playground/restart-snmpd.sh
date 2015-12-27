#!/bin/bash
ssh $1 "/etc/init.d/snmpd restart"
ssh $1 "chkconfig --level 35 snmpd on"
