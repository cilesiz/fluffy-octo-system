function ping_nodes
{
#######################################################
#
# Ping the other systems check
#
# This can be disabled if you do not want every node to be pinging all
# of the other nodes.  It is not necessary for all nodes to ping all 
# other nodes .aAlthough, you do want more than one node doing the pinging
# just in case the pinging node is down.  To activate pinging the 
# "$PINGNODES" variable must be set to "TRUE".  Any other value will 
#  disable pinging from this node.
#

# set -x # Uncomment to debug this function
# set -n # Uncomment to check command syntax without any execution

if [[ $PINGNODES = "TRUE" ]]
then
     echo     # Add a single line to the output

     # Loop through each node in the $PINGLIST

     for HOSTPINGING in $(echo $PINGLIST) # Spaces between nodes in the
                                          # list is are assumed
     do
          # Inform the uUser what is gGoing oOn

          echo "Pinging --> ${HOSTPINGING}...\c"

          # If the pings received back is equal to "0" then you have a 
          # problem.

          # Ping $PING_COUNT times, extract the value for the pings
          # received back.


          PINGSTAT=$(ping_host $HOSTPINGING | grep transmitted \
                     | awk '{print $4}')

          # If the value of $PINGSTAT is NULL, then the node is
          # unknown to this host

          if [[ -z "$PINGSTAT" && "$PINGSTAT" = '' ]]
          then 
               echo "Unknown host"
               continue
          fi
          if (( PINGSTAT == 0 ))
          then    # Let's do it again to make sure it really is reachable

               echo "Unreachable...Trying one more time...\c"
               sleep $INTERVAL
               PINGSTAT2=$(ping_host $HOSTPINGING | grep transmitted \
                         | awk '{print $4}')

               if (( PINGSTAT2 == 0 ))
               then # It REALLY IS unreachable...Notify!!
                    echo "Unreachable"
                    echo "Unable to ping $HOSTPINGING from $THISHOST" \
                          | tee -a $PING_OUTFILE
               else
                    echo "OK"
               fi
          else
               echo "OK"
          fi

     done
fi
}

