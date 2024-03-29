#!/bin/bash -x
#Filename: tweets.sh
#Description: Basic twitter client

USERNAME="stickballtv"
PASSWORD="K3b3rtx3la"
COUNT="5"


if [[ "$1" != "read" ]] && [[ "$1" != "tweet" ]];
then 
  echo -e "Usage: $0 send status_message\n   OR\n      $0 read\n"
  exit -1;
fi

if [[ "$1" = "read" ]];
then 
  #curl --silent -u $USERNAME:$PASSWORD  http://twitter.com/statuses/friends_timeline.rss | \
  curl -u $USERNAME:$PASSWORD  http://twitter.com/statuses/friends_timeline.rss | \
grep title | \
tail -n +2 | \
head -n $COUNT | \
  sed 's:.*<title>\([^<]*\).*:\n\1:'

elif [[ "$1" = "tweet" ]];
then 
  status=$( echo $@ | tr -d '"' | sed 's/.*tweet //')
  curl --silent -u $USERNAME:$PASSWORD -d status="$status" http://twitter.com/statuses/update.xml > /dev/null
  echo 'Tweeted :)'
fi
