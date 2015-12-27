function all__varied__on__pdisks
{
trap 'kill -9 $TWIRL_PID; return 1' 1 2 3 15

cat /dev/null > $HDISKFILE

echo "\nGathering a list of Varied on system SSA disks...Please wait...\c"

VG_LIST=$(lsvg -o) # Get the list of Varied ON Volume Groups

for VG in $(echo $VG_LIST) 
do
        lspv | grep $VG >> $HDISKFILE # List of Varied ON PVs
done

twirl & # Gives the user some feedback during long processing times...

TWIRL_PID=$!

echo "\nTranslating hdisk(s) into the associated pdisk(s)...Please Wait... \c"

for DISK in $(cat $HDISKFILE) # Translate hdisk# into pdisk#(s)
do
     # Checking for an SSA disk
        /usr/sbin/ssaxlate -l $DISK # 2>/dev/null 1>/dev/null 
        if (($? == 0))
        then
              /usr/sbin/ssaxlate -l $DISK >> $PDISKFILE # Add to pdisk List
        fi
done

kill -9 $TWIRL_PID # Kill the user feedback function...
echo "\b  "


echo "\nTurning $STATE all VARIED- ON system pdisks...Please Wait...\n"

for PDISK in $(cat $PDISKFILE)
do # Act on each pdisk individually...
    echo "Turning $STATE ==> $PDISK"
    /usr/sbin/ssaidentify -l $PDISK -${SWITCH} || echo "Turning $STATE $PDISK Failed"
done

echo "\n\t...TASK COMPLETE...\n"

}

