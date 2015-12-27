
proc_watch ()
{
# set -x # Uncomment to debug this function
# This function does all of the process monitoring!

while :     # Loop Forever!!
do
    case $RUN in
    'Y')
          # This will run the startup_event_script, which is a function

          if [[ $RUN_STARTUP_EVENT = 'Y' ]]
          then
             echo "STARTUP EVENT: Executing Startup Event Script..."\
                  > $TTY
             echo "STARTUP EVENT: Executing Startup Event Script..."\
                  >> $LOGFILE

             startup_event_script # USER DEFINED FUNCTION!!!
             RC=$?  # Check the Return Code!!
             if (( "RC" == 0 ))
             then
                 echo "SUCCESS: Startup Event Script Completed RC -
 ${RC}" > $TTY
                  echo "SUCCESS: Startup Event Script Completed RC -
 ${RC}" >> $LOGFILE

             else
                  echo "FAILURE: Startup Event Script FAILED RC -
 ${RC}" > $TTY
                  echo "FAILURE: Startup Event Script FAILED RC -
 ${RC}" >> $LOGFILE
             fi
          fi
          integer PROC_COUNT='-1' # Reset the Counters
          integer LAST_COUNT='-1'
          # Loop until the process(es) end(s)

          until (( "PROC_COUNT" == 0 ))
          do
               # This function is a Co-Process. $BREAK checks to see if
               # "Program Interrupt" has taken place. If so BREAK will
               # be 'Y' and we exit both the loop and function.

               read BREAK
               if [[ $BREAK = 'Y' ]]
               then
                     return 3
               fi
               PROC_COUNT=$(ps -ef | grep -v "grep $PROCESS" \
                           | grep -v $SCRIPT_NAME \
                           | grep $PROCESS | wc -l) >/dev/null 2>&1

               if (( "LAST_COUNT" > 0 && "LAST_COUNT" != "PROC_COUNT" ))
               then
                    # The Process Count has Changed...
                    TIMESTAMP=$(date +%D@%T)
                    # Get a list of the PID of all of the processes
                    PID_LIST=$(ps -ef | grep -v "grep $PROCESS" \
                           | grep -v $SCRIPT_NAME \
                           | grep $PROCESS | awk '{print $2}')

                    echo "PROCESS COUNT: $PROC_COUNT $PROCESS\
 Processes Running ==> $TIMESTAMP" >> $LOGFILE &
                    echo "PROCESS COUNT: $PROC_COUNT $PROCESS\
 Processes Running ==> $TIMESTAMP" > $TTY
            
                    echo ACTIVE PIDS: $PID_LIST >> $LOGFILE &
                    echo ACTIVE PIDS: $PID_LIST > $TTY
               fi
               LAST_COUNT=$PROC_COUNT
               sleep $INTERVAL # Needed to reduce CPU load!
          done

          RUN='N' # Turn the RUN Flag Off

          TIMESTAMP=$(date +%D@%T)
          echo "ENDING PROCESS: $PROCESS END time  ==>\
 $TIMESTAMP" >> $LOGFILE &
          echo "ENDING PROCESS: $PROCESS END time  ==>\
 $TIMESTAMP" > $TTY

          # This will run the post_event_script, which is a function

          if [[ $RUN_POST_EVENT = 'Y' ]]
          then
              echo "POST EVENT: Executing Post Event Script..."\
                    > $TTY
              echo "POST EVENT: Executing Post Event Script..."\
                    >> $LOGFILE &
 
              post_event_script # USER DEFINED FUNCTION!!!
              integer RC=$?
              if (( "RC" == 0 ))
              then
                  echo "SUCCESS: Post Event Script Completed RC -
 ${RC}" > $TTY
                  echo "SUCCESS: Post Event Script Completed RC -
 ${RC}" >> $LOGFILE
              else
                  echo "FAILURE: Post Event Script FAILED RC - ${RC}"\
                        > $TTY
                  echo "FAILURE: Post Event Script FAILED RC - ${RC}"\
                        >> $LOGFILE
              fi
          fi  
     ;;

     'N')
          # This will run the pre_event_script, which is a function

          if [[ $RUN_PRE_EVENT = 'Y' ]]
          then
             echo "PRE EVENT: Executing Pre Event Script..." > $TTY
             echo "PRE EVENT: Executing Pre Event Script..." >> $LOGFILE

             pre_event_script # USER DEFINED FUNCTION!!!
             RC=$?   # Check the Return Code!!!
             if (( "RC" == 0 ))
             then
                  echo "SUCCESS: Pre Event Script Completed RC - ${RC}"\
                        > $TTY
                  echo "SUCCESS: Pre Event Script Completed RC - ${RC}"\
                        >> $LOGFILE
             else
                  echo "FAILURE: Pre Event Script FAILED RC - ${RC}"\
                        > $TTY
                  echo "FAILURE: Pre Event Script FAILED RC - ${RC}"\
                        >> $LOGFILE
             fi
          fi

          echo "WAITING: Waiting for $PROCESS to
 startup...Monitoring..."

          integer PROC_COUNT='-1' # Initialize to a fake value

          # Loop until at least one process starts

          until (( "PROC_COUNT" > 0 ))
          do
               # This is a Co-Process. This checks to see if a "Program
               # Interrupt" has taken place. If so BREAK will be 'Y' and
               # we exit both the loop and function

               read BREAK
               if [[ $BREAK = 'Y' ]]
               then
                     return 3
               fi

               PROC_COUNT=$(ps -ef | grep -v "grep $PROCESS" \
                     | grep -v $SCRIPT_NAME | grep $PROCESS | wc -l) \
                       >/dev/null 2>&1

               sleep $INTERVAL # Needed to reduce CPU load!
          done

          RUN='Y' # Turn the RUN Flag On

          TIMESTAMP=$(date +%D@%T)

          PID_LIST=$(ps -ef | grep -v "grep $PROCESS" \
                     | grep -v $SCRIPT_NAME \
                     | grep $PROCESS | awk '{print $2}')

          if (( "PROC_COUNT" == 1 ))
          then
               echo "START PROCESS: $PROCESS START time ==>
 $TIMESTAMP" >> $LOGFILE &
               echo ACTIVE PIDS: $PID_LIST >> $LOGFILE &
               echo "START PROCESS: $PROCESS START time ==>
 $TIMESTAMP" > $TTY
               echo ACTIVE PIDS: $PID_LIST > $TTY
          elif (( "PROC_COUNT" > 1 ))
          then
               echo "START PROCESS: $PROC_COUNT $PROCESS
 Processes Started: START time ==> $TIMESTAMP" >> $LOGFILE &
               echo ACTIVE PIDS: $PID_LIST >> $LOGFILE &
               echo "START PROCESS: $PROC_COUNT $PROCESS
 Processes Started: START time ==> $TIMESTAMP" > $TTY
               echo ACTIVE PIDS: $PID_LIST > $TTY
          fi
     ;;
   esac
done
}

