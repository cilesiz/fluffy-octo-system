#!/bin/bash 

usage="\n\nUsage: ./404_monitor.sh ae[d]
  -a AI Affiliate abbreviation (e.g., njo, bama, etc.)
  -e Contact email address
  -d Date to process, in the format DDMon (01Jan). Default is yesterday.
\n"


if [ $# -eq 0 ]; then
  echo -e "$usage"
  exit
fi

while getopts ":a:e:d:" options
  do
    case $options in
        a) aff="$OPTARG";;
        e) contact="$OPTARG";;
        d) date="$OPTARG";;
        h) echo -e "$usage"
          exit 1;;
        \?) echo -e "$usage"
          exit 1;;
        *) echo -e "$usage"
          exit 1;;
    esac
  done

if [ "${date}" == "" ]; then
date=$(date --date="1 day ago" +%d%b)
fi

logdir="/var/www/${aff}/logs"
htdocs="/var/www/${aff}/htdocs"

outdir="/tmp"
tt4="top-ten-404s.txt"

echo -e "Following are the top ten most frequent 404 requests on ${aff}-1.live.advance.net.
The number to the left of each file path is the number of occurrances during this time frame. 

Below the top ten listing is a list of most frequent referring URLs for each item.\n\n" > ${outdir}/${tt4}

if ! cd ${logdir}; then
quit
else
zgrep "File does not exist" error.${date}.gz | awk -F "File does not exist: " ' { print $2 } ' | sort | uniq -c | sort -n | tail >> ${outdir}/${tt4}
fi

for i in $(awk -F "${htdocs}" ' { print $2 } ' /${outdir}/${tt4})
do
outfile=$(basename ${i})
echo -e "\n${outfile}" >> ${outdir}/${tt4}
zgrep "GET ${i}" access.${date}.gz | awk -F '"' ' { print $6 } ' | sort | uniq -c | sort -n | tail >> ${outdir}/${tt4}
done

mail -c support@advance.net -b sculver@advance.net -s "Top ten 404 errors for ${aff}: ${date}" ${contact} < ${outdir}/${tt4}

rm  ${outdir}/${tt4}
