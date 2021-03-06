# We need this to make the script work on some versions of gnuplot
set term dumb

# derivative functions.  Return 1/0 for first point, otherwise delta y or (delta y)/(delta x)
d(y) = ($0 == 0) ? (y1 = y, 1/0) : (y2 = y1, y1 = y, y1-y2)
d2(x,y) = ($0 == 0) ? (x1 = x, y1 = y, 1/0) : (x2 = x1, x1 = x, y2 = y1, y1 = y, (y1-y2)/(x1-x2))

# Set length of time for the entire graph
day = 24*60*60
week = 7*day
fortnight = 2*week
month = 30*day
timespan = week

# Set tic width
tic_width = day

# We're going to be using comma-separated values, so set this up
set datafile separator ","

# 'Pre-plot' the two charts "invisibly" first, to get the bounds of the data
# Interestingly, if you have your terminal set up with 'sixel' output, that's where they'll appear! Neato.

# Set pre-plot settings common to each plot
set xrange [time(0) - timespan:]

# Plot 'usercount' of the past week and get bounds (for GRAPH 1 y1)
plot "diasporastats.csv" using 1:2
usercountlow = GPVAL_DATA_Y_MIN
usercounthigh = GPVAL_DATA_Y_MAX

# Plot derivative of 'usercount' of the past week and get bounds (for GRAPH 1 y2)
plot "diasporastats.csv" using ($1):(d($2))
uc_derivative_low = GPVAL_DATA_Y_MIN
uc_derivative_high = GPVAL_DATA_Y_MAX

# Plot derivative of 'postscount' of the past week and get bounds (for GRAPH 2 y1)
plot "diasporastats.csv" using ($1):(d($4))
postslow  = GPVAL_DATA_Y_MIN
postshigh = GPVAL_DATA_Y_MAX
postslast = GPVAL_DATA_X_MAX

###############################################################################
# SETUP
###############################################################################

# Set up our fonts and such
set terminal png truecolor size 1464,660 enhanced font "./fonts/RobotoCond.ttf" 17 background rgb "#f0f0f0"
set output 'graph.png'

# Set border colour and line width
set border linewidth 3 linecolor rgb "#444444"

# Set colours of the tics
set xtics textcolor rgb "#444444" font "./fonts/RobotoCond.ttf,12"
set ytics textcolor rgb "#444444"

# Set text colors of labels
set xlabel "X" textcolor rgb "#444444" 
set ylabel "Y" textcolor rgb "#444444"

# Set the text colour of the key
set key textcolor rgb "#444444"

# Draw tics after the other elements, so they're not overlapped
set tics front

# Set layout into multiplot mode (2 rows by 1 column = 2 plots)
set multiplot layout 2, 1 title ""
set label "a.grumpy.world" at screen 0.1, 0.94 font "./fonts/BlackAndWhitePicture-Regular.ttf,42"
set label strftime("%d %b %Y %H:%M", time(0)) at screen 0.85, 0.94 font "./fonts/RobotoCond.ttf,12"
# Make sure we don't draw tics on the opposite side of the graph
set xtics nomirror
set ytics nomirror



# Set margin sizes
tmarg = 1       # Top margin
cmarg = 0       # Centre margin
bmarg = 2.5     # Bottom margin

lmarg = 12      # Left margin
rmarg = 9       # Right margin



###############################################################################
# GRAPH 1 
# Current usercount & the derivative (rate of new users joining) (last 7 days)
###############################################################################

# Set top graph margins
set tmargin tmarg
set lmargin lmarg
set rmargin rmarg

# Set Y axis
set yr [usercountlow:usercounthigh]
# set ylabel "Number of users" textcolor rgb "#115050" offset 1,0,0
unset ylabel

# Set Y2 axis
set y2r [0:uc_derivative_high * 2]
# set y2tics 10 nomirror
# set y2label 'Hourly increase' textcolor rgb "#5B7C1A" 
unset y2label

# Set X axis
set xdata time
set xrange [time(0) - timespan:]
set timefmt "%s"
set xlabel ""
set autoscale xfix

# Make the tics invisible, but continue to show the grid
set tics scale 0
set xtics tic_width
set format x ""
set key left top samplen 0

# Overall graph style
set style line 12 linecolor rgb "#FEFEFE" linetype 1 linewidth 5
set grid

# Plot the graph
plot "diasporastats.csv" every ::1 using 1:2 with filledcurves \
        x1 title 'total users'  fillstyle transparent solid 0.65 linecolor rgb "#2e85ad", \
        '' using ($1):(d($2)) with filledcurves x1 title 'new users' axes x1y2 \
        fillstyle transparent solid 0.7 noborder linecolor rgb "#5B7C1A"



###############################################################################
# GRAPH 2
# Number of posts per hour
###############################################################################

# Unset things from the previous graph
unset y2tics        # Remove y2 tics (only one y axis on this graph)
unset y2label       # Remove y2 label (only one y axis on this graph)

# Set bottom graph margins
set tmargin cmarg
set bmargin bmarg
set lmargin lmarg
set rmargin rmarg

# Set Y axis
set yr [0:postshigh]
# set ylabel "posts per hour" textcolor rgb "#5A0303"
# set y2label "comments per hour" textcolor rgb "#808080"

# Set X axis
set xdata time 
set xrange [time(0) - timespan:]
set timefmt "%s"
set format x "%a\n%d %b"
set xtics tic_width

# Overall graph style
set style line 12 linecolor rgb "#FEFEFE" linetype 1 linewidth 5
set grid

# Plot the graph
plot "diasporastats.csv" every ::1 using ($1):(d($3)) \
        with filledcurves x1 title 'local posts' fillstyle transparent solid 0.7 linecolor rgb "#5A0303" ,\
        '' using ($1):(d($4)) with filledcurves x1 title 'local comments' \
        fillstyle transparent solid 0.7 linecolor rgb "#808080"


# I think this needs to be here for some reason
unset multiplot
