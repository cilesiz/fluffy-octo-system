function rotate
{
# PURPOSE: This function is used to give the end user some feedback that 
# 	"something" is running.  It gives a line twirling in a circle.
#	This function is started as a background process. Assign its' PID
#    to a variable using:
#
#             rotate &      # To start 
#             ROTATE_PID=$! # Get the PID of the last background job
#
#       At the end of execution just break out by killing the $ROTATE_PID
#       process. We also need to do a quick "cleanup" of the left over 
#       line of rotate output. 
#
#           FROM THE SCRIPT:
#             kill -9 $ROTATE_PID
#             echo "\b\b   "

INTERVAL=1     # Sleep time between "twirls"
TCOUNT="0"	    # For each TCOUNT the line twirls one increment

while :        # Loop forever...until this function is killed
do
	TCOUNT=`expr $TCOUNT + 1`   # Increment the TCOUNT

	case $TCOUNT in
		"1")	echo -e '-'"\b\c"
			sleep $INTERVAL
			;;
		"2")	echo -e '\\'"\b\c"
			sleep $INTERVAL
			;;
		"3")	echo -e "|\b\c"
			sleep $INTERVAL
			;;
		"4")	echo -e "/\b\c"
			sleep $INTERVAL
			;;
		*)	TCOUNT="0" ;;  # Reset the TCOUNT to "0", zero.
	esac
done
} # End of Function - rotate

