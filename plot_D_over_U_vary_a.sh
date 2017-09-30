#!/bin/sh

#  plot_D_over_U_vary_p.sh
#  
#
#  Created by Johann on 30/7/13.
#
#input: plot_D_over_U_vary_p.sh p k trigger Umin Umax a1 a2 ..
if [ $# -eq 0 ]
then
	echo ""
    echo "$0:Error command arguments missing!"
    echo "Usage: plot_D_over_U_vary_p.sh p k trigger type Umin Umax a1 a2 .." 
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
kfrac=$( echo "$2" | awk '{printf "%g", $1/10}'  )
trigger=$3
p=$1


folder=/Users/jh/Documents/workspace-cpp/SPS/Release/sim_data/noreset/fitRPinv/dt0.001/t200

#outfile is file to save plot to
outfile="D_over_Pot_at_HI$typename"
outfile+="_p$1_k$kfrac"
outfile+="b_p"
title="range \$k = $kfrac b\$"

if [ $trigger != "no" ] && [ $trigger != "off" ] 
then 
    typename=$(echo $trigger | sed 's;/;;g' )
    outfile+="_$typename"
    echo "$typename"
    folder=/Users/jh/Documents/workspace-cpp/SPS/Release/sim_data/noreset/fitRPinv/$trigger/dt0.001/t200
fi


MSD="MSD"




#load default color spectrum
color=($( head -1 /Users/jh/Documents/workspace-cpp/gnuplot/colors/default.txt )) 

# Load default plot parameters
cp -f gp_defaultPlot.txt tmp/plot.gp


# SET SPECIAL PLOT PARAMETERS
echo "set xlabel \"\$U_0/k_B T\$\"" >> tmp/plot.gp
echo "set xrange [$4:$5]" >> tmp/plot.gp
#echo "set title \"$title\" offset graph -0.4, character -0.5" >> tmp/plot.gp #add $1 und $1 for d and potmod!
#echo "set yrange [0.0:1.3]" >> tmp/plot.gp       #LOG
#echo "set logscale y" >> tmp/plot.gp             # LOG
echo $folder

# PLOT COMMAND
echo "plot \\" >> tmp/plot.gp



#loop to recursively write plot commands to plot D over U_0  ----------------------------------------
j=0
for (( i=5;$i<$#;i=$i+1 ))
do
    j=$(( j + 1 ))
    a=${args[$i]}
    frac=$( echo "$a" | awk '{printf "%g", $1/10}'  )   #(echo "scale=3;$a/10" | bc ) 
    #create tmp files for plotdata for different k values
    touch tmp/plotdata_$i.txt
    echo "#" > tmp/plotdata_$i.txt
    find $folder -name a$a -type d | while read line1
        do find $line1/d0/b10/p$p/k$2 -name u* -type d | while read line2
            do  
            u=$(echo "$line2" | sed 's/.*u//g' | sed 's:/.*::') #assign u value of folder to variable u
            #if [ $(bc <<< "$u > -11") -eq 1 ]  #this is quite slow! comparing floating point numbers
            #then
            m=$(grep m $line2/InstantValues/linear_fit_parameters$MSD.txt | sed 's/m//')
            echo "$u $m" >> tmp/plotdata_$i.txt
            #fi
            done
        done
    echo "\"tmp/plotdata_$i.txt\" u 1:(\$2/6):(\$3/6) ls 1 pt $j lc rgb ${color[$j-1]} ti \"\$a = $frac  b\$ \", \\" >> tmp/plot.gp
    outfile+="_$a"
    echo "$(sort -n tmp/plotdata_$i.txt)" > tmp/plotdata_$i.txt
done
#---------------------------------------------------------------------------- end of loop

outfile="$outfile.tex"  #LOG

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

