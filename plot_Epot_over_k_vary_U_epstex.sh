#!/bin/sh

#  plot_Epot_over_k.sh
#  
#
#  Created by Johann on 18/6/13.
#
#input: plot_Epot_over_k_vary_U.sh d p potmod U1 U2 ...
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
    echo "Usage: plot_Epot_over_k_vary_U.sh d p trigger U1 U2 .."
    echo "For Potential modification: trigger = potentialMod, ranPot, Bessel, DH. Anythiing else -> No modification"
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
outfile="Epot_over_range_at_d$1_p$2_U"
if [ $3 = "potMod" ] || [ $3 = "DH" ] || [ $3 = "ranPot" ] || [ $3 = "Bessel" ] || [ $3 = "2ndOrder" ]
    then potmod=/$3
    outfile="Epot_over_range_at_$3_d$1_p$2_U"
fi



#load default color spectrum
color=($( head -1 /Users/jh/Documents/workspace-cpp/gnuplot/colors/default.txt )) 


# Load default plot parameters
cp -f gp_defaultPlot.txt tmp/plot.gp

# SET SPECIAL PLOT PARAMETERS
echo "set ylabel \"\$ \\\\\\\\langle E_\\\\\\\\text{pot} \\\\\\\\rangle /\\\\\\\\kT \$\"" >> tmp/plot.gp
echo "set xlabel \"\$k / b\$\"" >> tmp/plot.gp
echo "set xrange [0:0.53]" >> tmp/plot.gp
echo "set yrange [*:*]" >> tmp/plot.gp        # = autoset yrange
echo "set key bottom right width -6" >> tmp/plot.gpf
#echo "set logscale y" >> tmp/plot.gp
#echo "set terminal epslatex color solid size 6, 3.4 font \" \" 13 lw 1.5" >> tmp/plot.gp


echo "plot \\" >> tmp/plot.gp
folder=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset$potmod/dt0.0001/t200/d$1/b10/p$2
	

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
    #recursively find all D values for different U_0
    find $folder -name u$u -type d -not -path "*/1stOrder/*" | while read line1
        do  
        k=$(echo "$line1" | sed 's/.*k//g' | sed 's:/.*::') #assign k value of folder to variable k
        k=$(bc <<< "scale=3;$k/10") #scale k such that it gives the fraction of the boxsize (which is 10)
            #if [ $(bc <<< "$u > -11") -eq 1 ]  #this is quite slow! comparing floating point numbers
            #then
        c=$(grep c $line1/InstantValues/average_Epot.txt | sed 's/c//')
        echo "$k $c" >> tmp/plotdata_$i.txt
            #fi
        done
    echo "\"tmp/plotdata_$i.txt\" u 1:2:3 ls 1 pt $j lc rgb ${color[$j-1]} ti \"\$U_0/k_B T = $u\$ \", \\" >> tmp/plot.gp
    outfile+="_$u"
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

