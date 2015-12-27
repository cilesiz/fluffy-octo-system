function load_Solaris_FS_data
{
   df -k | tail +2 | egrep -v '/dev/fd|/etc/mnttab|/proc'\
         | awk '{print $1, $2, $4, $5, $6}' > $WORKFILE
}

