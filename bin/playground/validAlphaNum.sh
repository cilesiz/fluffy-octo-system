#!/bin/sh
# validAlphaNum - Ensures that input consists only of alphabetical
# and numeric characters

validAlphaNum()
{
	# Validate arg: returns 0 if all upper+lower+digits, 1 otherwise
	# Remove all unacceptable chars
compressed="$(echo $1 | sed -e `s/[^[:alnum:]]//g`)"

if [ "$compressed" != "$input" ] ; then
	return 1
else
		return 0
	fi
}

# sample usage of this function in a script

echo -n "Enter input: "
read input

if ! validAlphaNum "$input" ; then
	echo "Your input must consist of only letters and numbers." >&2
	exit 1
else
	echo "Input is valid."
fi 

exit 0
