#!/bin/sh

# bbcnews - report the top stories on the BBC World Service

url="http://sports.yahoo.com/mlb;_ylt=AmAYwVuQ1OM0GJxNS718Isc5nYcB"

lynx -source $url | \
sed -n '/Last Updated:/,/newssearch.bbc.co.uk/p' | \
sed 's/</\
</g;s/>/>\
/g' | \
grep -v -E '(<|>)' | \
fmt | \
uniq
