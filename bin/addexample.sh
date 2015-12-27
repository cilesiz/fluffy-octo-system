#!/bin/bash

newexample=$1

# skel
example=$HOME/.examples
skel="alias $newexample=\"\$example/$newexample /usr/bin/less"

echo "$skel" >> $HOME/.bashrc
. $HOME/.bashrc
