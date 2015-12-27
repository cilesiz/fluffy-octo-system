#!/usr/bin/bash
# taken from the book "sage" starting at page 9
# this script requires that you have cfegine already installed

# as root...
# create the basic structure of the cfengine work directory tree
target=$1.internal.upoc.com
scp root@$target "mkdir /var/cfengine"
scp root@$target "mkdir /var/cfengine/bin"
scp root@$target "mkdir /var/cfengine/inputs"
scp /Documentation/cfengine
bwprefix="/Documentation/cfengine/bin"

cp $bwprefix/cfagent /var/cfengine/bin
cp $bwprefix/cfexecd /var/cfengine/bin
cp $bwprefix/cfservd /var/cfengine/bin
chown -R root:0 /var/cfengine
chmod -R 700 /var/cfengine

# create a trivial agent policy

# see in this same dir triv/cfagent.conf


