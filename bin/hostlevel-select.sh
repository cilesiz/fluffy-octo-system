#!/bin/bash
echo >&2
echo "Select which hostlevel you want the host to be in"
select HL in production production-internal other
do
case $REPLY in
  1 ) HOSTLEVEL="1";;
  2 ) HOSTLEVEL="2";;
  3 ) HOSTLEVEL="3";;
  * ) echo "please sleect 1 2 or 3";;
esac
   if [[ -n $HL ]] ; then
      echo "You selected the host level: $HOSTLEVEL"
      break
   fi
done

