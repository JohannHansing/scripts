#!/bin/sh

#  plot_D_over_k.sh
#  
#
#  Created by Johann on 18/6/13.
#
#input: plot_D_over_U_vary_k.sh d p potmod k1 k2 ...
if [ $# -eq 0 ]
then
    echo "$0:Error command arguments missing!"
    echo "Usage: plot_D_over_U_vary_k.sh d p trigger xMin xMax k1 k2 .."	
    echo "NOTE: k needs to be written as k = x.xxx !"
	echo "NOTE 2: Trigger can be: potMod, DH, Bessel, ranPot, off, no"
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

folder="/Users/jh/Documents/workspace-cpp/SPS/sim_data/lubsheldon/noreset/"

#outfile is file to save plot to
outfile="HI_D_over_U_at_d$1_p$2_k"
title="D/D_0 with d = $1"
if  [ $3 = "DH" ] || [ $3 = "ranPot" ] || [ $3 = "Bessel" ] || [ $3 = "potMod" ] || [ $3 = "2ndOrder" ]
	then
	potmod=/$3
    outfile="D_over_U_with_$3_p$2_d$1_k"
    title="D/D_0 with d = $1, $3"
fi

if  [ $3 != "DH" ] && [ $3 != "ranPot" ] && [ $3 != "Bessel" ] && [ $3 != "potMod" ] && [ $3 != "2ndOrder" ] && [ $3 != "off" ] && [ $3 != "no" ]
	then
	echo "Error: Trigger must be one of: potMod, DH, Bessel, ranPot, off, no !"
	exit 1	
fi



folder=/Users/jh/Documents/workspace-cpp/SPS/sim_data/lubsheldon/noreset/steric/dt0.001/t200/a1/d0/b10/p1

title+="$title at different k"


#load default color spectrum
color=($( head -1 /Users/jh/Documents/workspace-cpp/gnuplot/colors/default.txt )) 


# Load default plot parameters
cp -f gp_defaultPlot.txt tmp/plot.gp

# SET SPECIAL PLOT PARAMETERS
echo "set xlabel \"\$U_0/k_B T\$\"" >> tmp/plot.gp
echo "set xrange [$4:$5]" >> tmp/plot.gp
#echo "set title \"$title\"" >> tmp/plot.gp #add $1 und $1 for d and potmod!
#echo "set terminal epslatex color solid size 6, 3.4 font \" \" 10 lw 1.5" >> tmp/plot.gp



echo "plot \\" >> tmp/plot.gp
#loop to recursively write plot commands to plot D over U_0  ----------------------------------------
j=0
for (( i=5;$i<$#;i=$i+1 ))
do
	j=$(( j + 1 ))
    k=${args[$i]}
    frac=$( echo "$k" | awk '{printf "%g", $1/10}'  )
    #create tmp files for plotdata for different k values
    touch tmp/plotdata_$i.txt
    echo "#" > tmp/plotdata_$i.txt
    #recursively find all D values for different U_0
    find $folder -name k$k -type d -not -path "*/1stOrder/*"  | while read line1
        do find $line1 -name u* -type d | while read line2
            do  
            u=$(echo "$line2" | sed 's/.*u//g' | sed 's:/.*::') #assign u value of folder to variable u
            #if [ $(bc <<< "$u > -11") -eq 1 ]  #this is quite slow! comparing floating point numbers
            #then
            m=$(grep m $line2/Coordinates/linear_fit_parameters.txt | sed 's/m//')
            echo "$u $m" >> tmp/plotdata_$i.txt
            #fi
            done
        done
    echo "\"tmp/plotdata_$i.txt\" u 1:(\$2/6):(\$3/6) ls 1 pt $j lc rgb ${color[$j-1]} ti \"\$k = $frac \\\\\\\\, b\$\", \\" >> tmp/plot.gp #lw 4 ps 2
    outfile+="_$k"
    echo "$(sort -n tmp/plotdata_$i.txt)" > tmp/plotdata_$i.txt
done
#---------------------------------------------------------------------------- end of loop

outfile="$outfile.tex"

echo " " >> tmp/plot.gp
echo "set output '/Users/jh/Documents/workspace-cpp/gnuplot/figures/epslatex/$outfile'" >> tmp/plot.gp
echo "replot" >> tmp/plot.gp


echo "set term aqua" >> tmp/plot.gp
echo "replot" >> tmp/plot.gp

gnuplot tmp/plot.gp; echo $outfile


#rm tmp/plotdata.dat; rm tmp/gnuplot.gp

#definition of Write_folder() function   -----------------------------
#Write_plot_command () {
##write tmp file where data is stored for certain k value
#touch tmp/plotdata.dat
#echo "#" > tmp/plotdata.dat

#recursively find all D values for different U_0
#find $1 -name k$2 -type d | while read line1
#do find $line1 -name u* -type d | while read line2
#do  u=$(echo "$line2" | sed 's/.*u//g' | sed 's:/.*::') #assign u value of folder to variable u
#m=$(grep m $line2/InstantValues/linear_fit_parameters.txt | sed 's/m//')
#echo "$u $m" >> tmp/plotdata.dat
#done
#done
#echo "\"tmp/plotdata.dat\" u 1:(\$2/6):(\$3/6) w yerrorbars ti \"r = $r\", \\" >> tmp/plot.gp
#}
#---------------------------- end of function definition

