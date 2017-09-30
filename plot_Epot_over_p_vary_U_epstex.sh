#!/bin/sh

#  
#
#  Created by Johann on 18/6/13.
#
#input: plot_Epot_over_p_vary_U.sh TODO
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
    echo "Usage: plot_Epot_over_p_vary_U.sh d k trigger u1 u2 .."
	echo "NOTE 2: type can be: LJ, steric, steric2"
    exit 1
fi


cd /Users/jh/Documents/workspace-cpp/gnuplot
#
#
#
#Create plotdata file and plot
#

#this stores the arguments in an array
declare -a args=("$@")


#outfile is file to save plot to
outfile="Epot_over_p_at_d$1_k$2"
if  [ $3 != "off" ] && [ $3 != "no" ]
	then
	trigger=/$3
    outfile="Epot_over_p_at_d$1_k$2_$3"
fi

outfile+="_for_u"


# load default color spectrum
color=($( head -1 /Users/jh/Documents/workspace-cpp/gnuplot/colors/default.txt )) 

# Load default plot parameters
cp -f gp_defaultPlot.txt tmp/plot.gp

# SET SPECIAL PLOT PARAMETERS
echo "set ylabel \"\$ \\\\\\\\langle E_\\\\\\\\text{pot} \\\\\\\\rangle /\\\\\\\\kT \$\"" >> tmp/plot.gp
echo "set xlabel \"\$U_0/k_B T\$\"" >> tmp/plot.gp
echo "set xrange [0:1]" >> tmp/plot.gp
echo "set yrange [*:*]" >> tmp/plot.gp        #autoset yrange
echo "set key bottom right width -6" >> tmp/plot.gp

echo "plot \\" >> tmp/plot.gp
folder=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset$trigger/dt0.0005/t200/d$1/b10


#loop to recursively write plot commands to plot Epot over U_0  ----------------------------------------
j=0
for (( i=3;$i<$#;i=$i+1 ))
do
	j=$(( j + 1 ))
    u=${args[$i]}
    #frac=$(echo "scale=3;$k/10" | bc )
    #create tmp files for plotdata for different u values
    touch tmp/plotdata_$i.txt
    echo "#" > tmp/plotdata_$i.txt
    #recursively find all Epot values for different U_0
	find $folder -name k$2 -type d | while read line
	do
			if [ -f $line/u$u/InstantValues/linear_fit_parameters.txt ]
                then 
	            p=$(echo "$line" | sed 's/.*p//g' | sed 's:/.*::') #assign p value to variable p
	            p=$(bc <<< "scale=3;$p/10") #scale p such that it gives the fraction of b
	            #if [ $(bc <<< "$u > -11") -eq 1 ]  #this is quite slow! comparing floating point numbers
	            #then
			    c=$(grep c $line/u$u/InstantValues/average_Epot.txt | sed 's/c//')
			    echo "$p $c" >> tmp/plotdata_$i.txt
	            #fi
		    fi
	done
    echo "\"tmp/plotdata_$i.txt\" u 1:2:3 ls 1 pt $j lc rgb ${color[$j-1]} ti \"\$U_0/k_B T = $u\$\", \\" >> tmp/plot.gp
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