#!/bin/sh
# valid-date -- Validates a date, taking into account leap year rules

exceedsDaysInMonth()
{
# Given a month name, return 0 if the specified day value is 
# less than or equal to the max adays in the mont; 1 otherwise

case $(echo $1|tr '[:upper:]' '[:lower:]') in
	jan* ) days=31	;;	feb* ) days=28	;;
	mar* ) days=31	;;	apr* ) days=30 	;;
	may* ) days=31	;;	jun* ) days=30	;;
	jul* ) days=31	;;	aug* ) days=31	;;
	sep* ) days=30	;;	oct* ) days=31	;;
	nov* ) days=30	;;	dec* ) days=31	;;
	* ) echo "$0: Unknown month name $1" >&2; exit 1
	esac

	if [ $2 -lt 1 -o $2 -gt $days ] ; then
		return 1
	else
		return 0	# the day number is valid
	fi
}

isLeapYear()
{
	# this function returns 0 if a leap year; 1 otherwise
	# the formula for checking whether a year is a leap year is:
	# 1. Years not divisble by 4 are not leap years.
	# 2. Years divisible by 4 and by 400 are leap years.
	# 3. Years divisible by 4, not divisble by 400, and divisible by 100, 
	# are not leap years
	# 4. all other years divisible by 4 are leap years 
year=$1
if [ "$((year % 4))" -ne 0 ] ; then 
	return 1 # nope, not a leap year
elif [ "$((year % 400))" -eq 0 ] ; then
	return 0
elif [ "$((year % 100))" -eq 0 ] ; then
	return 1
else
	return 0
fi
}

## Begin Main script

if [ $# -ne 3 ] ; then
	echo "Usage: $0 month day year" >&2
	echo "Typical input formats are August 3 1962 and 8 3 2002" >&2
	exit 1
fi

# Normalize date and split back out returned values

newdate="$(normdate "$@")"

if [ $? -eq 1 ] ; then
	exit 1	# error condition already reported by normdate
fi

month="$(echo $newdate | cut -d\  -f1)"
day="$(echo $newdate | cut -d\  -f2)"
year="$(echo $newdate | cut -d\  -f3)"

# now that we have a normalized date, let's check to see if the 
# day value is logical

if ! exceedsDaysInMonth $month "$2" ; then
	if [ "$month" = "Feb" -a "$2" -eq "29" ] ; then 
		if ! isLeapYear $3 ; then
			echo "$0: $3 is not a leap year, so Feb doesn't have 29 days" >&2
			exit 1
		fi
	else
		echo "$0: bad day value: $month doesn't have $2 days" >&2
			exit 1
		fi
	fi
	echo "Valid date: $newdate"

	exit 0
