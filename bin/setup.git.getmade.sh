#!/bin/bash

# script to create a user getmade and set up his environment in his home dir according to what is in github
# ensure you are running this script as root

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Vars

NAME="getmade"
EMAILADDY="getmade@nym.hush.com"


yum -y install git

git config --global user.name "$NAME"
git config --global user.email "$EMAILADDY" 
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=3600'

# set up the editor you want to use

git config --global core.editor vim

# set the tool to resolve merge conflicts vimdiff
# acceptable diff tools are kdiff3, tkdiff, meld, xxdiff emerge, vimdiff, gvimdiff, ecmerge, opendiff
git config --global merge.tool vimdiff

# colorized output of git

git config --global color.ui auto

#Colorized output:

git config --global color.branch auto
git config --global color.diff auto
git config --global color.interactive auto
git config --global color.status auto

mkdir ~/.ssh
touch ~/.ssh/authorized_keys

chmod 0700 ~/.ssh
chmod 0600 ~/.ssh/authorized_keys

echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA1N2Bq2Aeywl3EnBBmZRbBx3oMEp3Eg/PW+WWUSG8NCyvtSz8YJS+6kdb6biK57BnuLOMUctJyZFmoBcUPKSrfBCc9p0ZP64lw/DfzqSHACQIs6dA5YM7BGOUYfFowrdYGrV3jJbGteJGF5Szi7vqxXbt24V16EVvyvYD+PZBOFgP4La+8lEG5tlxWWr79usrKouLtl/WsFQcC2Tpd9vFRma1n3sDU4NOcL+5mVqDwbV6HGiIWqmr2P//WagTk+oW8d+kOu/ppkYb8lWm804Y9txQdNk10R918RuUgadzb
ZilqQ8QLJsRuA+S/g5PAd7iq5tZk/O1e2NTRtZ2Wnf6PQ== getmade@nym.hush.com' > ~/.ssh/authorized_keys

ssh-agent git clone git@github.com:getmade/personalenv.git


