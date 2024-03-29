check_HTTP_server ()
{
LINX="/usr/local/bin/lynx"  # Define the location of the linx program
URL=$1                      # Capture the target URL in the $1 position
URLFILE=/tmp/HTTP.$$        # Define a file to hold the URL output

###########################################

$LINX "$URL" > $URLFILE     # Attempt to reach the target URL

if (($? != 0))              # If the URL is unreachable - No Connection
then
     echo "\n$URL - Unable to connect\n"
     cat $URLFILE
else                        # Else the URL was found

     while read VER RC STATUS  # This while loop is feed from the bottom
                               # after the "done" using input redirection
     do
          case $RC in       # Check the return code in the $URLFILE

          200|401|301|302)  # These are valid return codes!

                            echo "\nHTTP Server is OK\n"
                            ;;
                        *)  # Anything else is not a valid return code

                            echo "\nERROR: HTTP Server Error\n"
                            ;;
          esac

     done < $URLFILE
fi

rm -f $URLFILE
}

