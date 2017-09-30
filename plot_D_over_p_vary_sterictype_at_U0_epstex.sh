#!/bin/sh

#  plot_D_over_k.sh
#  
#
#  Created by Johann on 18/6/13.
#
#input: plot_D_over_p_vary_sterictype_at_U0.sh d type1 type2 ..
#
#
#
if [ $# -eq 0 ]
then
    echo "$0:Error command arguments missing!"
    echo "Usage: plot_D_over_p_vary_sterictype_at_U0.sh d type1 type2 .."
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
outfile="D_over_p_stericOnly_at_U0_d$1_at"


# load default color spectrum
color=($( head -1 /Users/jh/Documents/workspace-cpp/gnuplot/colors/default.txt )) 

# Load default plot parameters
cp -f gp_defaultPlot.txt tmp/plot.gp

# SET SPECIAL PLOT PARAMETERS
echo "set xlabel \"\$p/b\$\"" >> tmp/plot.gp
echo "set xrange [0:1]" >> tmp/plot.gp
#echo "set title \"$title\"" >> tmp/plot.gp #add $1 und $1 for d and potmod!
echo "set key off" >> tmp/plot.gp
#echo "set logscale y" >> tmp/plot.gp
#echo "set yrange [0:1.2]" >> tmp/plot.gp



echo "plot \\" >> tmp/plot.gp

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1

folder=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/Release/sim_data/noreset/ranRod/
dt=dt0.0005
MSD="MSD"
#$3/dt0.0005/t200/d$1/b10


#loop to recursively write plot commands to plot D over U_0  ----------------------------------------
j=0
for (( i=1;$i<$#;i=$i+1 ))
do
	j=$(( j + 1 ))
    type=${args[$i]}
	if [ $type != "LJ" ] && [ $type != "steric" ] && [ $type != "steric2" ]
	    then
		echo "Error: type has to be: LJ or steric or steric2" 
		exit 1
	fi
	if [ $type = "steric" ] 
		then name="hardcore 1"
	elif [ $type = "steric2" ]
		then name="hardcore 2"
	else name="Lennard-Jones"
		type=""
	fi
    #frac=$(echo "scale=3;$k/10" | bc )
    #create tmp files for plotdata for different u values
    touch tmp/plotdata_$i.txt
    echo "#" > tmp/plotdata_$i.txt
    #recursively find all D values for different U_0
    find "$folder/$type/$dt" -name d$1 -type d | while read line1
	do
		find $line1 -name k1.000 -type d | while read line
		do
			if [ -f "$line/u0/InstantValues/linear_fit_parameters$MSD.txt" ]
                then 
	            p=$(echo "$line" | sed 's/.*p//g' | sed 's:/.*::' | awk '{printf "%g", $1/10}' ) #assign p/10 value to variable p
	            #if [ $(bc <<< "$u > -11") -eq 1 ]  #this is quite slow! comparing floating point numbers
	            #then
	            m=$(grep m $line/u0/InstantValues/linear_fit_parameters$MSD.txt | sed 's/m//')
	            echo "$p $m" >> tmp/plotdata_$i.txt
	            #fi
		    fi
		done
	done
    #echo "\"tmp/plotdata_$i.txt\" u 1:(\$2/6):(\$3/6) ls 1 pt $j lc rgb ${color[$j-1]} ti \"$name\", \\" >> tmp/plot.gp #THIS IS THE CORRECT ONE FOR LINESPOINTS!!!
	echo "\"tmp/plotdata_$i.txt\" u 1:(\$2/6):(\$3/6) w points ls 1 pt 5 lc rgb ${color[$j-1]} ti \"$name\", \\" >> tmp/plot.gp
    outfile+="_$type"
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

