#!/bin/sh
# script for settingup a openvz container and starting it

vzctl set $1 --applyconfig max-limits --save
#sh -c 'echo OSTEMPLATE="debian-6.0-x86" >> /etc/vz/conf/$1.conf'
vzctl set $1 --ipadd $2 --save
vzctl set $1 --nameserver 10.250.250.5 --save
vzctl start $1
vzctl enter $1