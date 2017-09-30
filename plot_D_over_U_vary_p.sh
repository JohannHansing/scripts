#!/bin/sh

#  plot_D_over_U_vary_p.sh
#  
#
#  Created by Johann on 30/7/13.
#
#input: plot_D_over_U_vary_p.sh d/a k trigger type Umin Umax p1 p2 ..
if [ $# -eq 0 ]
then
	echo ""
    echo "$0:Error command arguments missing!"
    echo "Usage: plot_D_over_U_vary_p.sh d/a k trigger type Umin Umax p1 p2 .."
    echo "NOTE: k needs to be written as k = x.xxx, type either 'steric' or 'steric2'. Anything else -> default LJ"
	echo "NOTE 2: Trigger can be: potMod, DH, Bessel, ranPot, ranPot2, off, no or HI, in the latter case 'a' must be provided"
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
outfile="D_over_Pot_at_d$1_k$kfrac"
title="range \$k = $kfrac b\$"
if  [ $3 == "DH" ] || [ $3 == "ranPot" ] || [ $3 == "Bessel" ] || [ $3 == "potMod" ] || [ $3 == "2ndOrder" ] 
	then
	trigger=/$3
    outfile="D_over_Pot_at_$3_d$1_k$kfrac"
    title="D/D_0 with d = $1, $3"
fi

if  [ $3 != "DH" ] && [ $3 != "ranPot" ] && [ $3 != "Bessel" ] && [ $3 != "potMod" ] && [ $3 != "2ndOrder" ] && [ $3 != "off" ] && [ $3 != "no" ] && [ $3 != "HI" ] && [ $3 != "HIoldlub" ]
	then
	echo "Error: Trigger must be one of: potMod, DH, Bessel, ranPot, HI, off, no !"
	exit 1	
fi


outfile+="b"
if [ $4 == "steric" ] || [ $4 == "steric2" ]  || [ $4 == "LJ" ]
then 
    echo "Type set to $4"
    type="/$4"
	outfile+="_$4"
fi

if [ $4 == "ewaldCorr" ] || [ $4 == "noLub/steric" ] || [ $4 == "test/EwaldTest20/noLub/steric" ] || [ $4 == "test/epsilon0.5/LJ" ] || [ $4 == "test/epsilon0.25/LJ"  ]  || [ $4 == "LJ025"  ]
then 
    typeHI="/$4"
    typename=$(echo $typeHI | sed 's;/;;g' )
	outfile+="_$typename"
    echo "$typename"
fi

folder=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_dataOLD/noreset$type$trigger/dt0.0001/t200/d$1/b10


# In case the trigger is 'HI', the 'folder' variable needs to be redefined
if  [ $3 = "HI" ]
    then
    folder=/Users/jh/Documents/workspace-cpp/SPS/Release/sim_data/noreset/fitRPinv$typeHI$type/dt0.001/t200/a$1/d0/b10
	outfile="D_over_Pot_at_HI$typename"
    outfile+="_a$1_k$kfrac"
	MSD="MSD"
fi

# In case the trigger is 'HI', the 'folder' variable needs to be redefined
if  [ $3 = "HIoldlub" ]
    then
    folder=/Users/jh/Documents/workspace-cpp/SPS/Release/sim_data/noreset_oldLubBadg/fitRPinv$typeHI/dt0.001/t200/a$1/d0/b10
	outfile="D_over_Pot_at_HInewlub$typename"
    outfile+="_a$1_k$kfrac"
	MSD="MSD"
fi

outfile+="_p"

#load default color spectrum
color=($( head -1 /Users/jh/Documents/workspace-cpp/gnuplot/colors/default.txt )) 

# Load default plot parameters
cp -f gp_defaultPlot.txt tmp/plot.gp


# SET SPECIAL PLOT PARAMETERS
echo "set xlabel \"\$U_0/k_B T\$\"" >> tmp/plot.gp
echo "set xrange [$5:$6]" >> tmp/plot.gp
#echo "set title \"$title\" offset graph -0.4, character -0.5" >> tmp/plot.gp #add $1 und $1 for d and potmod!
#echo "set yrange [0.0:1.3]" >> tmp/plot.gp       #LOG
#echo "set logscale y" >> tmp/plot.gp             # LOG
echo $folder

# PLOT COMMAND
echo "plot \\" >> tmp/plot.gp



#loop to recursively write plot commands to plot D over U_0  ----------------------------------------
j=0
for (( i=6;$i<$#;i=$i+1 ))
do
	j=$(( j + 1 ))
    p=${args[$i]}
    frac=$( echo "$p" | awk '{printf "%g", $1/10}'  )   #(echo "scale=3;$p/10" | bc ) 
    #create tmp files for plotdata for different k values
    touch tmp/plotdata_$i.txt
    echo "#" > tmp/plotdata_$i.txt
	#recursively find all D values for different U_0
	# the if statement if for p=0!
#	if [ $p = "0" ]
#		then
#		folder_Alternative=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset/dt0.0005$ranPot/t$2/d$1/b10/k$2
#        find $folder_Alternative -name u* -type d | while read line2
#            do  
#            u=$(echo "$line2" | sed 's/.*u//g' | sed 's:/.*::') #assign u value of folder to variable u
#            #if [ $(bc <<< "$u > -11") -eq 1 ]  #this is quite slow! comparing floating point numbers
#            #then
#            m=$(grep m $line2/InstantValues/linear_fit_parameters.txt | sed 's/m//')
#            echo "$u $m" >> tmp/plotdata_$i.txt
#            #fi
#            done
#	fi
    find $folder -name p$p -type d | while read line1
        do find $line1/k$2 -name u* -type d | while read line2
            do  
            u=$(echo "$line2" | sed 's/.*u//g' | sed 's:/.*::') #assign u value of folder to variable u
            #if [ $(bc <<< "$u > -11") -eq 1 ]  #this is quite slow! comparing floating point numbers
            #then
            m=$(grep m $line2/InstantValues/linear_fit_parameters$MSD.txt | sed 's/m//')
            echo "$u $m" >> tmp/plotdata_$i.txt
            #fi
            done
        done
    echo "\"tmp/plotdata_$i.txt\" u 1:(\$2/6):(\$3/6) ls 1 pt $j lc rgb ${color[$j-1]} ti \"\$p = $frac \\\\\\\\, b\$ \", \\" >> tmp/plot.gp
    outfile+="_$p"
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

