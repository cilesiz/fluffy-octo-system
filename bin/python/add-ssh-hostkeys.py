#!/bin/bash -x
#
# $Id: add-ssh-hostkeys,v 1.5 2004/04/15 01:53:09 jmates Exp $
#
# The author disclaims all copyrights and releases this script into the
# public domain.
#
# Adds ssh known host keys to a specified host keys file.

BASENAME=`basename $0`

if [ -z $1 ]; then
  echo "usage: $BASENAME known_hosts-file" >&2
  exit 100
fi

KHF=$1

cleanup () {
  rm -f $TMPKEYS $TMPHOSTS
}

TMPKEYS=`mktemp /tmp/$BASENAME.XXXXXXXX` || exit 1
TMPHOSTS=`mktemp /tmp/$BASENAME.XXXXXXXX` || exit 1
trap "cleanup" 0 1 2 13 15

# need to do host-by-host as ssh-keyscan will abort if it cannot
# resolve a particular address
cat | while read hke; do
  # scan for all key types to avoid potential "MitM server runs DSA
  # instead of RSA" issue
  ssh-keyscan -t rsa,dsa,rsa1 $hke 2>/dev/null >> $TMPKEYS
done

ssh-hkutil -v $KHF - < $TMPKEYS > $TMPHOSTS || exit 1

if [ ! -s $TMPHOSTS ]; then
  echo "error: no keys in temporary file" >&2
  exit 1
fi

cmp -s $KHF $TMPHOSTS
STATUS=$?

if [ $STATUS -eq 1 ]; then
  # use cat to preserve perms that cp or mv might fuddle with
  cat $TMPHOSTS > $KHF
elif [ $STATUS -gt 1 ]; then
  echo "error: cmp failed: status=$STATUS" >&2
fi

cleanup

