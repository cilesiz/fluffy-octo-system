#!/bin/bash

ARGS=1

# 1 arguement required; the filename
if [ $# -ne "$ARGS" ]  
then
  echo -e "\nUsage: `basename $0` filename\n"
  exit 1
fi

# ensure the file exists
if [ ! -f "$1" ]
then
  echo "File \"$1\" does not exist, please try again"
  exit 1
fi

sed -e 's/\.//g' -e 's/\,//g' -e 's/ /\/g' "$1" | tr 'A-Z' 'a-z' | sort | uniq -c | sort -nr
sed -e 's/\.//g' -e 's/\,//g' # Filter out periods and commas

#                           =========================
#                            Frequency of occurrence

#  Filter out periods and commas, and
#+ change space between words to linefeed,
#+ then shift characters to lowercase, and
#+ finally prefix occurrence count and sort numerically.

#  Arun Giridhar suggests modifying the above to:
#  . . . | sort | uniq -c | sort +1 [-f] | sort +0 -nr
#  This adds a secondary sort key, so instances of
#+ equal occurrence are sorted alphabetically.
#  As he explains it:
#  "This is effectively a radix sort, first on the
#+ least significant column
#+ (word or string, optionally case-insensitive)
#+ and last on the most significant column (frequency)."
#
#  As Frank Wang explains, the above is equivalent to
#+       . . . | sort | uniq -c | sort +0 -nr
#+ and the following also works:
#+       . . . | sort | uniq -c | sort -k1nr -k
########################################################
if [ $? -eq 0 ]
then
  exit 0
else
  exit 1
fi
