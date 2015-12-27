#!/bin/bash
MAXCOUNT=500000000
count=1
STRING="mmmk"
echo
echo "$MAXCOUNT random numbers:"
echo "-----------------"
while [ "$count" -le $MAXCOUNT ]      # Generate 10 ($MAXCOUNT) random integers.
do
  number=$RANDOM
    echo $number $STRING
      let "count += 1"  # Increment count.
      done
      echo "-----------------"


