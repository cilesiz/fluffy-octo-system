prw ${1+"$@"} |
   tr -cd 'a-zA-Z-\n' |
       sort |
           uniq -c |
              sort -n
