#!/bin/sh
kill -QUIT `svstat /service/upoc-resin | awk '{print $4}' | cut -f1 -d")"`
sleep 45
mv /var/archive/`hostname`/dumps/dump-resin.txt  /var/archive/`hostname`/dumps/dump-auto`date +%Y%m%d-%H%M%S`.txt
