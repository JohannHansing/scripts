#!/bin/sh

#  plot_D_over_k.sh
#  
#
#  Created by Johann on 18/6/13.
#
#input: plot_D_over_b_vary_aop_constU.sh U type aop1 aop2  ..
#
#********************************************************
#********************************************************
#Maybe include "Filename_addition_string" in args of script
#so one can include "attractive_" or "repulsive_" in the filename
#********************************************************
#********************************************************
#
#
if [ $# -eq 0 ]
then
	echo ""
    echo "$0:Error command arguments missing!"
    echo "Usage: plot_D_over_b_vary_aop_constU.sh U type aop1 aop2  .."
    echo " p HAS TO ALWAYS BE 1 HERE!!!"
    exit 1
fi

cd /Users/jh/Documents/workspace-cpp/gnuplot
#
#
#
#Create plotdata file and plot
#

U=$1
type=$2
typename=$(echo $type | sed 's;/;;g' )
sa=2  # number of parameters before first of the final arguments in 'args'-array

#this stores the arguments in an array
declare -a args=("$@")


#outfile is file to save plot to
outfile="D_over_b_at_u$U"
# outfile="D_over_p_NOLUB_at_u$U"  # NOLUB
outfile+="_$typename"
outfile+="_aOverp"


# load default color spectrum
color=($( head -1 /Users/jh/Documents/workspace-cpp/gnuplot/colors/default.txt )) 

# Load default plot parameters
cp -f gp_defaultPlot.txt tmp/plot.gp

# SET SPECIAL PLOT PARAMETERS
echo "set xlabel \"b/p\"" >> tmp/plot.gp
echo "set xrange [0:1]" >> tmp/plot.gp
echo "set autoscale" >> tmp/plot.gp
#echo "set title \"$title\"" >> tmp/plot.gp #add $1 und $1 for d and potmod!
#echo "set key off" >> tmp/plot.gp
#echo "set logscale y" >> tmp/plot.gp
#echo "set yrange [0:1.2]" >> tmp/plot.gp



echo "plot \\" >> tmp/plot.gp

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1


#$3/dt0.0005/t200/d$1/b10
folder=/Users/jh/Documents/workspace-cpp/SPS/Release/sim_data/noreset/backflow/$type/dt0.001/t200

#loop to recursively write plot commands to plot D over U_0  ----------------------------------------
j=0
for (( i=$sa;$i<$#;i=$i+1 ))
do
	j=$(( j + 1 ))
    aop=${args[$i]}
    a=$aop
    k=1.000
    #frac=$(echo "scale=3;$k/10" | bc )
    #create tmp files for plotdata for different u values
    touch tmp/plotdata_$i.txt
    echo "#" > tmp/plotdata_$i.txt
    #recursively find all D values for different U_0
    find $folder/a$a -name b* -type d | while read line
    do
        b=$( echo "$line" | sed 's/.*b//g' | sed 's:/.*::'  )
        file=$line/d0/b$b/p1/k$k/u$U/InstantValues/linear_fit_parametersMSD.txt
        if [ -f $file ]
            then
            #afrac=$( echo "$a $b" | awk '{printf "%g", $1/$2}'  ) #scale a such that it gives the fraction of b
            m=$(grep m $file | sed 's/m//')
            echo "$b $m" >> tmp/plotdata_$i.txt
        fi
    done
    #echo "\"tmp/plotdata_$i.txt\" u 1:(\$2/6):(\$3/6) ls 1 pt $j lc rgb ${color[$j-1]} ti \"$name\", \\" >> tmp/plot.gp #THIS IS THE CORRECT ONE FOR LINESPOINTS!!!
	echo "\"tmp/plotdata_$i.txt\" u 1:(\$2/6):(\$3/6) w linespoints ls 1 pt 5 lc rgb ${color[$j-1]} ti \"\$a/p = $aop \\\\\\\\, b\$\", \\" >> tmp/plot.gp
    outfile+="_$aop"
    echo "$(sort -n tmp/plotdata_$i.txt)" > tmp/plotdata_$i.txt
done
#---------------------------------------------------------------------------- end of loop

outfile="$outfile.tex"

echo " " >> tmp/plot.gp
echo "set output \"/Users/jh/Documents/workspace-cpp/gnuplot/figures/epslatex/$outfile\"" >> tmp/plot.gp
echo "replot" >> tmp/plot.gp

echo "set term aqua" >> tmp/plot.gp
echo "replot" >> tmp/plot.gp

gnuplot tmp/plot.gp; echo $outfile

