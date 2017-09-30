#!/bin/sh

#  plot_D_over_k.sh
#  
#
#  Created by Johann on 18/6/13.
#
#input: plot_D_over_p_vary_U.sh TODO
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
    echo "Usage: plot_D_over_p_vary_U.sh d/a k trigger u1 u2 .."
	echo "NOTE 2: trigger can be steric, steric2, LJ,etc. -OR- HI, in the latter case use a instead of d as first param"
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

a=0
xlabel="\$p/b\$"
#xlabel='(a+p)/b'
#outfile is file to save plot to
outfile="D_over_p_at_d$1_k$2"
if  [ $3 != "off" ] && [ $3 != "no" ]
	then
    triggername=$(echo $trigger | sed 's;/;;g' )
	trigger=/$3
    outfile="D_over_p_at_d$1_k$2_$triggername"
fi

folder=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_dataOLD/noreset$trigger/dt0.0001/t200/d$1/b10
#HI
if  [ $3 = "HI" ]
    then
    a=$1
    folder=/Users/jh/Documents/workspace-cpp/SPS/Release/sim_data/noreset/fitRPinv/dt0.001/t200/a$a/d0/b10
    xlabel="\$(a+p)/b\$"
	outfile="D_over_p_at_a$a"
    outfile+="_k$2_HI"
	MSD="MSD"
fi

outfile+="_for_u"


# load default color spectrum
color=($( head -1 /Users/jh/Documents/workspace-cpp/gnuplot/colors/default.txt )) 

# Load default plot parameters
cp -f gp_defaultPlot.txt tmp/plot.gp

# SET SPECIAL PLOT PARAMETERS
echo "set xlabel \"$xlabel\"" >> tmp/plot.gp
echo "set xrange [0:1]" >> tmp/plot.gp
echo "set key top right width -1" >> tmp/plot.gp
#echo "set title \"$title\"" >> tmp/plot.gp #add $1 und $1 for d and potmod!
#echo "set key top right" >> tmp/plot.gp
#echo "set logscale y" >> tmp/plot.gp
#echo "set yrange [0:1.2]" >> tmp/plot.gp
#echo "set terminal epslatex color solid size 5.4, 3.4 font \" \" 13 lw 1.5" >> tmp/plot.gp
echo "set yrange [-0.01:1.3]" >> tmp/plot.gp

echo "plot \\" >> tmp/plot.gp

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
	find $folder -name k$2 -type d | while read line2
	do
		find $line2 -name u$u -type d | while read line
        do
			if [ -f $line/InstantValues/linear_fit_parameters$MSD.txt ]
                then 
	            p=$(echo "$line" | sed 's/.*p//g' | sed 's:/.*::') #assign p value to variable p
	            p=$(bc <<< "scale=3;$p/10") #scale p such that it gives the fraction of b
                pPlusa=$(bc <<< "scale=3;$p+$a*0.1")
	            #if [ $(bc <<< "$u > -11") -eq 1 ]  #this is quite slow! comparing floating point numbers
	            #then
	            m=$(grep m $line/InstantValues/linear_fit_parameters$MSD.txt | sed 's/m//')
	            echo "$pPlusa $m" >> tmp/plotdata_$i.txt
	            #fi
		    fi
        done
	done
    echo "\"tmp/plotdata_$i.txt\" u 1:(\$2/6):(\$3/6) ls 1 pt $j lw 1 lc rgb ${color[$j-1]} ti \"\$U_0 = $u k_B T\$\", \\" >> tmp/plot.gp
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
