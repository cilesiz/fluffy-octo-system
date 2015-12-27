#!/bin/bash

newexample=$1

# skel
skel="alias $newexample=\"\$example/$newexample \$doless\""

echo "$skel" >> $HOME/.bashrc
. $HOME/.bashrc
svn add $HOME/.examples/$newexample
