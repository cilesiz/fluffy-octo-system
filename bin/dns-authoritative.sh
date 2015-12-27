#!/bin/bash
#----------------------------------------------------------------
# Copyright &#169; 2006 - Philip Howard - All rights reserved
#

# script  a, aaaa, cname, mx, ns, ptr, soa, txt
#
# purpose Perform direct DNS lookups for authoritative DNS
#         data. This lookup bypasses the local DNS cache
#         server.
#
# syntax  a       [ names ... ]
#         aaaa    [ names ... ]
#         any     [ names ... ]
#         cname   [ names ... ]
#         mx      [ names ... ]
#         ns      [ names ... ]
#         ptr     [ names ... ]
#         soa     [ names ... ]
#         txt     [ names ... ]
#
# author  Philip Howard
#----------------------------------------------------------------

# For use with ptr query.
function inaddr {
    awk -F. '{print $4 "." $3 "." $2 "." $1 ".in-addr.arpa.";}'
}


query_type=$( exec basename "${0}" )

# Get and query for each host.
for hostname in "$@" ; do
    if [[ "${query_type}" == ptr ]] ; then
    # A typical scripting trick: when a case can begin
    # with a numeral, place a dummy character such as x in
    # front because the case syntax expects an alphanumeric
    # character.
    case "x${hostname}y" in
        ( x[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*y )
        hostname=$( echo "${hostname}" | inaddr )
        ;;
        ( * )
        ;;
    esac
    fi

    # Execute the query.
    dig +trace +noall +answer "${query_type}" "${hostname}" | \
        egrep "^${hostname}"
done
exit
