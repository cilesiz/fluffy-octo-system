function load_HP_UX_FS_data
{
   bdf | tail +2 | egrep -v '/mnt/cdrom' \
       | awk '{print $1, $2, $4, $5, $6}' > $WORKFIL
 }

