#!/bin/sh

#  plot_D_over_k.sh
#  
#
#  Created by Johann on 18/6/13.
#
#input: plot_D_over_b_vary_U_epstex.sh TODO
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
    echo "$0:Error command arguments missing!"
    echo "Usage: sh plot_D_over_b_vary_U_epstex.sh p/k trigger u1 u2 .."
	echo "NOTE 2: type can be: LJ, steric, steric2"
	echo "p/k means p divided by k and should be an integer. FOR NOW IT HAS TO BE 1 !!!"
    exit 1
fi


cd /Users/jh/Documents/workspace-cpp/gnuplot
#
#
#
#Create plotdata file and plot
#
type="$2"


#this stores the arguments in an array
declare -a args=("$@")


#outfile is file to save plot to
outfile="D_over_b_at_pok$1_$type"
outfile+="_for_u"
if [ $type != "LJ" ] && [ $type != "steric" ] && [ $type != "steric2" ]
    then
	echo "Error: Trigger has to be: LJ or steric or steric2" 
	exit 1
fi


# load default color spectrum
color=($( head -1 /Users/jh/Documents/workspace-cpp/gnuplot/colors/default.txt )) 

# Load default plot parameters
cp -f gp_defaultPlot.txt tmp/plot.gp

# SET SPECIAL PLOT PARAMETERS
echo "set xlabel \"\$b/p\$\"" >> tmp/plot.gp
echo "set xrange [0:21]" >> tmp/plot.gp
echo "set key top right horiz width -2" >> tmp/plot.gp
#echo "set title \"$title\"" >> tmp/plot.gp #add $1 und $1 for d and potmod!
#echo "set key top right" >> tmp/plot.gp
#echo "set logscale y" >> tmp/plot.gp
#echo "set yrange [0:1.2]" >> tmp/plot.gp



echo "plot \\" >> tmp/plot.gp
folder=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset/$type


#loop to recursively write plot commands to plot D over U_0  ----------------------------------------
j=0
for (( i=2;$i<$#;i=$i+1 ))
do
	j=$(( j + 1 ))
    u=${args[$i]}
    #frac=$(echo "scale=3;$k/10" | bc )
    #create tmp files for plotdata for different u values
    touch tmp/plotdata_$i.txt
    echo "#" > tmp/plotdata_$i.txt
    #recursively find all D values for different U_0
    find $folder -name d0 -type d | while read bla
	do
		find $bla -name 'p*' -type d | while read line2
		do
			p=$(echo "$line2" | sed 's/.*p//g' | sed 's:/.*::')
			#k=$( echo "scale=3;$p/$1" | bc | awk '{printf "%.3f", $0}' )  Does the same as the thing below
			k=$( echo "$p $1" | awk '{printf "%.3f", $1/$2}' )
			#find "$line2/k$k" -name u$u -type d | while read line
            #do
			if [ -f $line2/k$k/u$u/InstantValues/linear_fit_parameters.txt ]
	            then 
		        b=$( echo "$p" | awk '{printf "%f", 10/$1}' ) #$(bc <<< "scale=3;$p/10") #scale p such that it gives the fraction of b
		        #if [ $(bc <<< "$u > -11") -eq 1 ]  #this is quite slow! comparing floating point numbers
		        #then
		        m=$(grep m $line2/k$k/u$u/InstantValues/linear_fit_parameters.txt | sed 's/m//')
		        echo "$b $m" >> tmp/plotdata_$i.txt
		        #fi
			fi
        done
	done
    echo "\"tmp/plotdata_$i.txt\" u 1:(\$2/6):(\$3/6) ls 1 pt $j lc rgb ${color[$j-1]} ti \"\$U_0/k_B T = $u\$\", \\" >> tmp/plot.gp
    outfile+="_$u"
    echo "$(sort -n tmp/plotdata_$i.txt)" > tmp/plotdata_$i.txt
done
#---------------------------------------------------------------------------- end of loop

outfile="$outfile.tex"

echo " " >> tmp/plot.gp
echo "set output \"/Users/jh/Documents/workspace-cpp/gnuplot/figures/epslatex/$outfile\"" >> tmp/plot.gp
echo "replot" >> tmp/plot.gp


gnuplot tmp/plot.gp

echo $outfile