#!/bin/bash

cec-group-ssh.sh "cd /usr/nagios/libexec && perl check_connections.pl -w 300 -c 320 -u super" frontends
