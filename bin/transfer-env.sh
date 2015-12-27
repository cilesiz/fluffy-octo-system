#!/bin/bash
# small script to transfer environment settings to a new host

if [ $# -ne 1 ] ; then
        echo "Usage: $(basename $0) targethost" >&2
        exit 1
fi

TARGET=$1
scp -r $HOME/.bashrc $HOME/.vimrc $HOME/.tmux.conf $TARGET@:.
