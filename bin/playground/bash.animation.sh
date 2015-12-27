#! /bin/bash
trap "clear" 0 3 9 15
put() { tput cup $1 $2; echo -n "$3"; }
set -a X Y DX DY SHAPE
set -i i q
W=$((COLUMNS-2))
H=$((LINES-2))
for d in . o o o o o o o o o o @ ; do
  q=$((q+1)); DX[q]=1; DY[q]=1; X[q]=$((q+4)); Y[q]=$((q+9)); SHAPE[q]="$d"
done
clear
while true ; do
  put ${Y[1]} ${X[1]} ' '
  for i in $(seq $q) ; do
    [ ${X} -gt $W -o ${X} -lt 1 ] && DX=-${DX}
    [ ${Y} -gt $H -o ${Y} -lt 1 ] && DY=-${DY}
    X=$((X+DX))
    Y=$((Y+DY))
    put ${Y} ${X} ${SHAPE}
  done
  tput cup 0 0
  usleep 50000
done
