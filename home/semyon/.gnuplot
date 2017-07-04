set macros

font = "-benis-lemon-mono-medium-R-normal--10-110-75-75-P-50-ISO10646-1"
font_color = "#f7bc7a"
mgrid_color = "#111111"
grid_color = "#333333"
border_color = "#666666"

set style line 100 lt 1 lw 1 lc rgb border_color
set style line 101 lt 1 lw 1 lc rgb grid_color
set style line 102 lt 1 lw 1 lc rgb mgrid_color

set terminal x11 font font size 640,480
set title 'Plotting' tc rgb font_color
set tics tc rgb border_color
set key tc rgb font_color

set border 0 ls 100
set zeroaxis ls 100

set ytics axis 5 nomirror; set mytics 5
set grid mytics ytics ls 101, ls 102
set xtics axis 5 nomirror; set mxtics 5
set grid mxtics xtics ls 101, ls 102

set samples 1000
