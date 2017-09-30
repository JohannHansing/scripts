#!/bin/sh

#  plot_D_over_k.sh
#  
#
#  Created by Johann on 18/6/13.
#
#input: plot_D_over_p_vary_a_constU.sh U type a1 a2  ..
#
#
#
if [ $# -eq 0 ]
then
	echo ""
    echo "$0:Error command arguments missing!"
    echo "Usage: plot_D_over_p_vary_type_constU.sh U a type1 type2 .."
    exit 1
fi

cd /Users/jh/Documents/workspace-cpp/gnuplot
#
#
#
#Create plotdata file and plot
#

U=$1
a=$2
afrac=$( echo "$a" | awk '{printf "%g", $1/10}'  )
sa=2  # number of parameters before first of the final arguments in 'args'-array

#this stores the arguments in an array
declare -a args=("$@")


#outfile is file to save plot to
outfile="D_over_p_at_u$U"
outfile+="_a"


# load default color spectrum
color=($( head -1 /Users/jh/Documents/workspace-cpp/gnuplot/colors/default.txt )) 

# Load default plot parameters
cp -f gp_defaultPlot.txt tmp/plot.gp

# SET SPECIAL PLOT PARAMETERS
echo "set xlabel \"(p+a)/b\"" >> tmp/plot.gp
echo "set xrange [0:1]" >> tmp/plot.gp
#echo "set title \"$title\"" >> tmp/plot.gp #add $1 und $1 for d and potmod!
#echo "set key off" >> tmp/plot.gp
#echo "set logscale y" >> tmp/plot.gp
#echo "set yrange [0:1.2]" >> tmp/plot.gp



echo "plot \\" >> tmp/plot.gp

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1


#$3/dt0.0005/t200/d$1/b10


#loop to recursively write plot commands to plot D over U_0  ----------------------------------------
j=0
for (( i=$sa;$i<$#;i=$i+1 ))
do
	j=$(( j + 1 ))
    type=${args[$i]}
    typename=$(echo $type | sed 's;/;;g' )
    k="1.000"
    folder=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/Release/sim_data/noreset/$type/dt0.0005/t200/d0
    # folder=/Users/jh/Documents/workspace-cpp/SPS/sim_data/nolub/noreset/steric/dt0.001/t200/a$a/d0/b10 # NOLUB
	k="1.000"
    #frac=$(echo "scale=3;$k/10" | bc )
    #create tmp files for plotdata for different u values
    touch tmp/plotdata_$i.txt
    echo "#" > tmp/plotdata_$i.txt
    #recursively find all D values for different U_0
    find $folder -name k$k -type d | while read line
		do
            file=$line/u$U/InstantValues/linear_fit_parametersMSD.txt
			if [ -f $file ]
                then 
	            p=$(echo "$line" | sed 's/.*p//g' | sed 's:/.*::' | awk '{printf "%g", $1/10}' ) #assign p/10 value to variable p
	            #if [ $(bc <<< "$u > -11") -eq 1 ]  #this is quite slow! comparing floating point numbers
	            #then
	            m=$(grep m $file | sed 's/m//')
	            echo "$p $m" >> tmp/plotdata_$i.txt
	            #fi
		    fi
		done
    #echo "\"tmp/plotdata_$i.txt\" u 1:(\$2/6):(\$3/6) ls 1 pt $j lc rgb ${color[$j-1]} ti \"$name\", \\" >> tmp/plot.gp #THIS IS THE CORRECT ONE FOR LINESPOINTS!!!
	echo "\"tmp/plotdata_$i.txt\" u (\$1+$afrac):(\$2/6):(\$3/6) w linespoints ls 1 pt 5 lc rgb ${color[$j-1]} ti \"$typename\", \\" >> tmp/plot.gp
    outfile+="_$typename"
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

