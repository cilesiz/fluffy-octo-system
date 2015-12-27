set terminal svg enhanced size 640 480 fname "Helvetica" fsize 12
set output "MLB_slugging_history.svg"
set style line 1 linetype 1 pointtype 0 linewidth 2 linecolor 6
set style line 2 linetype 1 pointtype 0 linewidth 2 linecolor 7
set style line 3 linetype 1 pointtype 0 linewidth 2 linecolor 8
set style line 4 linetype 1 pointtype 0 linewidth 2 linecolor 2 
set style line 5 linetype 1 pointtype 0 linewidth 2 linecolor 21
set style line 6 linetype 1 pointtype 0 linewidth 2 linecolor 11
set style line 7 linetype 1 pointtype 0 linewidth 2 linecolor 17
set style line 8 linetype 1 pointtype 0 linewidth 2 linecolor 9
set xrange [1890:2008]
set yrange [0:0.5]
set format y "%.3f"
set xlabel "Year"
set ylabel "Contribution to slugging average"
set key top center horizontal 
plot \
"[datafile1]" u 1:(4*$15+3*$14+2*$13+$12) t "HR"   w filledcurves x1 linestyle 1, \
"[datafile1]" u 1:(      3*$14+2*$13+$12) t "3B"   w filledcurves x1 linestyle 2, \
"[datafile1]" u 1:(            2*$13+$12) t "2B"   w filledcurves x1 linestyle 3, \
"[datafile1]" u 1:(                  $12) t "1B "  w filledcurves x1 linestyle 4, \
"[datafile2]" u 1:(4*$15+3*$14+2*$13+$12) notitle w filledcurves x1 linestyle 5, \
"[datafile2]" u 1:(      3*$14+2*$13+$12) notitle w filledcurves x1 linestyle 6, \
"[datafile2]" u 1:(            2*$13+$12) notitle w filledcurves x1 linestyle 7, \
"[datafile2]" u 1:(                  $12) notitle w filledcurves x1 linestyle 8
