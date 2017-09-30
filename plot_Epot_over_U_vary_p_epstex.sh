#!/bin/sh

#  plot_D_over_U_vary_p.sh
#  
#
#  Created by Johann on 30/7/13.
#
#input: plot_Epot_over_U_vary_p.sh d t k trigger type p1 p2 ...
if [ $# -eq 0 ]
then
    echo "$0:Error command arguments missing!"
    echo "Usage: plot_Epot_over_U_vary_p.sh d k trigger type Umin Umax p1 p2 .."
    echo "NOTE: k needs to be written as k = x.xxx, type either 'steric' or 'steric2'. Anything else -> default LJ"
	echo "NOTE 2: Trigger can be: potMod, DH, Bessel, ranPot"
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

#outfile is file to save plot to
outfile="Epot_over_Pot_at_d$1_k$kfrac"
if  [ $3 == "DH" ] || [ $3 == "ranPot" ] || [ $3 == "Bessel" ] || [ $3 == "potMod" ] || [ $3 == "2ndOrder" ] || [ $3 == "ranPot2" ]
	then
	trigger=/$3
    outfile="Epot_over_Pot_at_$3_d$1_k$kfrac"
fi
outfile+="b"
if [ $4 == "steric" ] || [ $4 == "steric2" ] 
then 
    echo "Type set to $4"
    type="/$4"
	outfile+="_$4"
fi
outfile+="_p"

#load default color spectrum
color=($( head -1 /Users/jh/Documents/workspace-cpp/gnuplot/colors/default.txt )) 

# Load default plot parameters
cp -f gp_defaultPlot.txt tmp/plot.gp


# SET SPECIAL PLOT PARAMETERS
echo "set ylabel \"\$ \\\\\\\\langle E_\\\\\\\\text{pot} \\\\\\\\rangle /\\\\\\\\kT \$\"" >> tmp/plot.gp
echo "set xlabel \"\$U_0/k_B T\$\"" >> tmp/plot.gp
echo "set xrange [$5:$6]" >> tmp/plot.gp
echo "set yrange [*:*]" >> tmp/plot.gp        #autoset yrange
echo "set key bottom right  width -6" >> tmp/plot.gp
#echo "set title \"$title\" offset graph -0.4, character -0.5" >> tmp/plot.gp #add $1 und $1 for d and potmod!
#echo "set yrange [0.0:1.3]" >> tmp/plot.gp       #LOG
#echo "set logscale y" >> tmp/plot.gp             # LOG


# PLOT COMMAND
echo "plot \\" >> tmp/plot.gp

folder=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset$type$trigger/dt0.0001/t200/d$1/b10

#loop to recursively write plot commands to plot Epot over U_0  ----------------------------------------
j=0
for (( i=6;$i<$#;i=$i+1 ))
do
	j=$(( j + 1 ))
    p=${args[$i]}
    frac=$( echo "$p" | awk '{printf "%g", $1/10}'  )   #(echo "scale=3;$p/10" | bc ) 
    #create tmp files for plotdata for different k values
    touch tmp/plotdata_$i.txt
    echo "#" > tmp/plotdata_$i.txt
	#recursively find all Epot values for different U_0
    find $folder -name p$p -type d | while read line1
        do find $line1/k$2 -name u* -type d | while read line2
            do  
            u=$(echo "$line2" | sed 's/.*u//g' | sed 's:/.*::') #assign u value of folder to variable u
            #if [ $(bc <<< "$u > -11") -eq 1 ]  #this is quite slow! comparing floating point numbers
            #then
            c=$(grep c $line2/InstantValues/average_Epot.txt | sed 's/c//')
            echo "$u $c" >> tmp/plotdata_$i.txt
            #fi
            done
        done
    echo "\"tmp/plotdata_$i.txt\" u 1:2:3 ls 1 pt $j lc rgb ${color[$j-1]} ti \"\$p = $frac \\\\\\\\, b\$ \", \\" >> tmp/plot.gp
    outfile+="_$p"
    echo "$(sort -n tmp/plotdata_$i.txt)" > tmp/plotdata_$i.txt
done
#---------------------------------------------------------------------------- end of loop

outfile="$outfile.tex"  #LOG

echo " " >> tmp/plot.gp
echo "set output '/Users/jh/Documents/workspace-cpp/gnuplot/figures/epslatex/$outfile'" >> tmp/plot.gp
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

