#!/bin/sh

#  plot_D_over_C_vary_U_at_RT.sh
#  
#
#  Created by Johann on 18/6/13.
#
#input: plot_D_over_C_vary_U_at_RT.sh d p potmod b_real U1 U2 ...
#
#
#
if [ $# -eq 0 ]
then
    echo ""
    echo "$0:Error command arguments missing!"
    echo "---------------------"
    echo "Usage: plot_D_over_k_vary_U.sh d/a p trigger b_real C_max U1 U2 .."
	echo "b_real needs to be the box size (pore size) in nanometers!!!"
	echo "For Potential modification: trigger = potentialMod, ranPot, Bessel, DH. Anything else -> No modification"
    echo "NOTE: U needs to be an integer !"
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
#sh plot_D_over_k_vary_U_epstex.sh $1 $2 $3 $4 $5 $6 $7 $8 $9


#outfile is file to save plot to
outfile="D_over_C_at_d$1_p$2_U"
title="D/D_0 with d = $1 at different U_0"
if [ $3 != "no" ] && [ $3 != "off" ] 
    then potmod="/$3"
    outfile="D_over_C_at_$3_d$1_p$2_U"
    title="D/D_0 with d = $1 and $3 at different U_0"
fi


#load default color spectrum
color=($( head -1 /Users/jh/Documents/workspace-cpp/gnuplot/colors/default.txt )) 


# Load default plot parameters
cp -f gp_defaultPlot.txt tmp/plot.gp

# SET SPECIAL PLOT PARAMETERS
echo "set xlabel '\$C_\\\\text{Ion}\$ / mM'" >> tmp/plot.gp
echo "set xrange [-0.5:$5]" >> tmp/plot.gp	
echo "set yrange [0:1.1]" >> tmp/plot.gp	
echo "set key bottom right vertical width -5" >> tmp/plot.gp
#echo "set title \"$title\"" >> tmp/plot.gp #add $1 und $1 for d and potmod!
#echo "set logscale y" >> tmp/plot.gp



folder=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_dataOLD/noreset$potmod
#folder+=/hpiu-3/hpik1
#folder+=/hpiu-2/hpik1
#folder+=/hpiu-7/hpik0.5
#folder+=/hpiu-0.5/hpik2
folder+=/dt0.0005/t200/d$1/b10/p$2


# In case the trigger is 'HI', the 'folder' variable needs to be redefined
if  [ $3 = "HI" ]
    then
    folder=/Users/jh/Documents/workspace-cpp/SPS/Release/sim_data/noreset/fitRPinv/steric/dt0.0005/t200/a$1/d0/b10/p$2
	outfile="D_over_C_at_$3_a$1_p$2_U"
	MSD="MSD"
fi

echo "plot \\" >> tmp/plot.gp
#loop to recursively write plot commands to plot D over U_0  ----------------------------------------
j=0
for (( i=5;$i<$#;i=$i+1 ))
do
	j=$(( j + 1 ))
    u=${args[$i]}
    #frac=$(echo "scale=3;$k/10" | bc )
    #create tmp files for plotdata for different u values
    touch tmp/plotdata_$i.txt
    echo "#" > tmp/plotdata_$i.txt
    #recursively find all D values for different U_0
    find $folder -name u$u -type d | while read line1
        do  
        k=$(echo "$line1" | sed 's/.*k//g' | sed 's:/.*::') #assign k value of folder to variable k
        k=$(bc <<< "scale=3;$k/10") #scale k such that it gives the fraction of the boxsize (which is 10)
            #if [ $(bc <<< "$u > -11") -eq 1 ]  #this is quite slow! comparing floating point numbers
            #then
        m=$(grep m $line1/InstantValues/linear_fit_parameters$MSD.txt | sed 's/m//')
        echo "$k $m" >> tmp/plotdata_$i.txt
            #fi
        done
    echo "\"tmp/plotdata_$i.txt\" u (0.0924*10**3/(\$1*$4)**2):(\$2/6):(\$3/6) ls 1 pt $j lc rgb ${color[$j-1]} ti \"\$U_0/k_B T = $u\$\", \\" >> tmp/plot.gp
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

