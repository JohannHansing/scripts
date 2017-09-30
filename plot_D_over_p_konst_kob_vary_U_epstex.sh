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
    echo "Usage: sh plot_D_over_b_vary_U_epstex.sh p k trigger u1 u2 .."
	echo "NOTE 2: type can be: LJ, steric, steric2"
	echo "p k need to be given in  units as in simulation"
    exit 1
fi


cd /Users/jh/Documents/workspace-cpp/gnuplot
#
#
#
#Create plotdata file and plot
#
type="$3"
p=$1
k=$2
koverp=$( echo "$k $p" | awk '{printf "%g", $1/$2}' )

#this stores the arguments in an array
declare -a args=("$@")


#outfile is file to save plot to
outfile="D_over_p_at_poverk$koverp"
outfile+="_$type"
if [ $type == "off" ] || [ $type == "no" ]
    then
	outfile="D_over_p_at_poverk$koverp"
	type=""
fi
outfile+="_for_u"

# load default color spectrum
color=($( head -1 /Users/jh/Documents/workspace-cpp/gnuplot/colors/default.txt )) 

# Load default plot parameters
cp -f gp_defaultPlot.txt tmp/plot.gp

# SET SPECIAL PLOT PARAMETERS
echo "set xlabel \"\$p/b\$\"" >> tmp/plot.gp
echo "set xrange [*:*]" >> tmp/plot.gp
echo "set key top right horiz width -2" >> tmp/plot.gp
#echo "set title \"$title\"" >> tmp/plot.gp #add $1 und $1 for d and potmod!
#echo "set key top right" >> tmp/plot.gp
#echo "set logscale y" >> tmp/plot.gp
#echo "set yrange [0:1.2]" >> tmp/plot.gp



echo "plot \\" >> tmp/plot.gp
folder=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset/$type/dt0.0001/t200/d0


#loop to recursively write plot commands to plot D over U_0  ----------------------------------------
j=0
for (( i=3;$i<$#;i=$i+1 ))
do
    j=$(( j + 1 ))
    u=${args[$i]}
    #frac=$(echo "scale=3;$k/10" | bc )
    #create tmp files for plotdata for different u values
    touch tmp/plotdata_$i.txt
    echo "#" > tmp/plotdata_$i.txt
    #recursively find all D values for different U_0
    find $folder -name b* -type d | while read bla
	do
	line="$bla/p$p/k$k/u$u/InstantValues"
	b=$( echo "$bla" | sed 's/.*b//g' | sed 's:/.*::') #assign value to variable b
	poverb=$( echo "$b $p" | awk '{printf "%f", $2/$1}' ) #$(bc <<< "scale=3;$p/10") #scale p such that it gives the fraction of b
	       #if [ $(bc <<< "$u > -11") -eq 1 ]  #this is quite slow! comparing floating point numbers
		#then
	m=$(grep m $line/linear_fit_parameters.txt | sed 's/m//')
	echo "$poverb $m" >> tmp/plotdata_$i.txt
	#fi
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

echo "set term aqua" >> tmp/plot.gp
echo "replot" >> tmp/plot.gp

gnuplot tmp/plot.gp

echo $outfile