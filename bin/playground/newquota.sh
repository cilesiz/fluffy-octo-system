#!/bin/sh

# newquota - a front end to quota that works with full-word flags a la GNU

# quota has three possible flags, -g, -v, and -q, but this script
# allows them to be '--group', '--verbose', and '--quiet' too:

flags=""
realquota="/usr/bin/quota"

while [ $# -gt 0 ]
do 

	case $1
	in 
	--help 		) echo "Usage: $0 [--group --verbose --quiet -gvq]" >&2
			  exit 1 ;;
	--group | -group) flags="$flags -g";	shift ;;
	--verbose | -verbose) flags="$flags -v"; 	shift ;;
	--quiet | -quiet) flags="$flags -q";	shift ;;
	--		) shift; 	break ;;
	*		) break; 	# done with 'while' loop
	esac
done

exec $realquota $flags "$@"
