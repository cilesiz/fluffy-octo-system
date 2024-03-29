#!/bin/sh

# scriptbc - Wrapper for 'bc' that returns the result of a caculation

if [ $1 = "-p" ] ; then
	precision=$2
	shift 2
	else 
		precision=2	# default
	fi

	bc -q << EOF
	scale=$precision
	$*
	quit
	EOF

	exit 0
