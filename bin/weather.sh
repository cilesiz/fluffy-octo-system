#!/bin/sh

# weather - Reports the weather forecast, including lat/long. for a zip code.

llurl="http://www.census.gov/cgi-bin/gazetteer?city=&state=&zip="
wxurl="http://wwwa.accuweather.com"
wxurl="$wxurl/adcbin/public/local_index_print.asp?zipcode="

if [ "$1" = "-a" ] ; then
	size=100; shift 
else
	size=5
fi

if [ $# -eq 0 ] ; then
	echo "Usage: $0 [-a] zipcode" >&2
	exit 1
fi

if [ $size -eq 5 ] ; then
	echo ""

	# Get some information on the zip code from the Census Bureau

lynx -source "${llurl}$1" | \
	sed -n '/^<li><strong>/,/^Location:/p' | \
	sed 's/<[^>]*>//g;s/^ //g'
fi


# The weather forecast itself at accuweather.com

lynx -source "${wxurl}$1" | \
	sed -n '/<font class="sevendayten">/,/[^[:digit:]]<\/font>/p' | \
	sed 's/<[^>]*>//g;s/^ [ ]*//g' | \
	uniq | \
	head -n $size

exit 0
