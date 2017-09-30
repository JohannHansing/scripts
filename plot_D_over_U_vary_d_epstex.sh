#!/bin/sh

#  plot_D_over_U_vary_d.sh
#  
#
#  Created by Johann on 18/6/13.
#
#input: plot_D_over_U_vary_d.sh k t potmod d1 d2 ...
if [ $# -eq 0 ]
then
    echo "$0:Error command arguments missing!"
    echo "Usage: plot_D_over_U_vary_d.sh k t potmod d1 d2 .."
    echo "For Potential modification: potmod = on"
    echo "NOTE: k needs to be written as k = x.xxx !"
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
frac=$(echo "scale=3;$1/10" | bc )


#outfile is file to save plot to
outfile="D_over_U_at_k$1_t$2_d"                       
title="range \$k = $frac b\$"     

#title="D/D_0 with k = b x $frac at different d - Close-Up"       #Close-up



#load default color spectrum
color=($( head -1 /Users/jh/Documents/workspace-cpp/gnuplot/colors/default.txt )) 


# Load default plot parameters
cp -f gp_defaultPlot.txt tmp/plot.gp

# SET SPECIAL PLOT PARAMETERS
echo "set xlabel \"\$U_0/k_B T\$\"" >> tmp/plot.gp
echo "set xrange [-11:21]" >> tmp/plot.gp
#echo "set title \"$title\"" >> tmp/plot.gp #add $1 und $1 for d and potmod!
#echo "set xrange [-4:4]" >> tmp/plot.gp   #Close-up



echo "plot \\" >> tmp/plot.gp
folder=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset/dt0.0001/t$2

#loop to recursively write plot commands to plot D over U_0 for different d--------------------------------
j=0; #need this for potmod color
for (( i=3;$i<$#;i=$i+1 ))
do
    j=$(( j + 1 ))
    d=${args[$i]}
    dob=$( echo "$d" | awk '{printf "%g", $1/10}'  )   #$(echo "scale=1;$d/10" | bc )
    #create tmp files for plotdata for different k values
    touch tmp/plotdata_$i.txt
    echo "#" > tmp/plotdata_$i.txt
    #recursively find all D values for different U_0
    find $folder -name d$d -type d | while read line1
        do find $line1/b10/p0/k$1 -name u* -type d | while read line2
            do
            u=$(echo "$line2" | sed 's/.*u//g' | sed 's:/.*::') #assign u value of folder to variable u
            #if [ $(bc <<< "$u > -11") -eq 1 ]  #this is quite slow! comparing floating point numbers
            #    then
            m=$(grep m $line2/InstantValues/linear_fit_parameters.txt | sed 's/m//')
            echo "$u $m" >> tmp/plotdata_$i.txt
            #fi
            done
        done
    echo "\"tmp/plotdata_$i.txt\" u 1:(\$2/6):(\$3/6) ls 1 pt $j lc rgb ${color[$j-1]} ti \"\$d = $dob \\\\\\\\, b \$\", \\" >> tmp/plot.gp
    outfile+="_$d"
    #lines in the file need to be sorted numerically for linespoints!
    echo "$(sort -n tmp/plotdata_$i.txt)" > tmp/plotdata_$i.txt
done
#---------------------------------------------------------------------------- end of loop

#write plot commands to plot D over U_0 for potmod--------------------
if [ $3 = "on" ]
then 
    touch tmp/plotdata_potmod.txt
	j=$(( j + 1 ))
    echo "#" > tmp/plotdata_potmod.txt
    folder=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset/potMod/dt0.0001/t$2
    find $folder -name d0 -type d | while read line1
        do find $line1/b10/p0/k$1 -name u* -type d | while read line2
            do
            u=$(echo "$line2" | sed 's/.*u//g' | sed 's:/.*::') #assign u value of folder to variable u
            #if [ $(bc <<< "$u > -11") -eq 1 ]  #this is quite slow! comparing floating point numbers
            #    then
            m=$(grep m $line2/InstantValues/linear_fit_parameters.txt | sed 's/m//')
            echo "$u $m" >> tmp/plotdata_potmod.txt
            #fi
            done
        done
    echo "\"tmp/plotdata_potmod.txt\" u 1:(\$2/6):(\$3/6) ls 1 pt $j lc rgb ${color[$j-1]}  ti \"\$\$Model 3\", \\" >> tmp/plot.gp
    outfile+="_potmod"
    #lines in the file need to be sorted numerically for linespoints!
    echo "$(sort -n tmp/plotdata_potmod.txt)" > tmp/plotdata_potmod.txt
fi
#----------------------------------------------------------------------------

outfile+=".tex"
#outfile+="_Close-Up.pdf"   #Close-up

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

