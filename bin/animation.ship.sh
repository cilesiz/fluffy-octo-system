#!/bin/bash

bull1=' *        * '
bull2='            '

ship1=' ^   /\   ^ '
ship2=' !__/()\__! '
ship3=' /==:  :==\ '
ship4='   (/\/\)   '

tput clear
((line1 = $(tput lines) - 6))
((line2 = line1 + 1))
((line3 = line2 + 1))
((line4 = line3 + 1))

((maxcol = $(tput cols) - 15))
((bullline = 1))
((bullcol = 1))
((curcol = 1))
((coldir = 1))
while true ; do
tput cup $bullline $bullcol ; echo "$bull2"
    if [[ $bullline -le 2 ]] ; then
        ((bullline = line1 - 1))
        ((bullcol = curcol))
    else
        ((bullline = bullline - 2))
    fi
    tput cup $bullline $bullcol ; echo "$bull1"

    tput cup $line1 $curcol ; echo "$ship1"
    tput cup $line2 $curcol ; echo "$ship2"
    tput cup $line3 $curcol ; echo "$ship3"
    tput cup $line4 $curcol ; echo "$ship4"
((curcol = curcol + coldir))
    if [[ $curcol -eq $maxcol ]] ; then
        ((coldir = -coldir))
    else
        if [[ $curcol -eq 1 ]] ; then
            ((coldir = -coldir))
        fi
    fi
    sleep 0.1
done
