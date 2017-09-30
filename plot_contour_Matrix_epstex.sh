#!/bin/sh

#  plot_Contour_Matrix.sh
#  
#
#  Created by Johann on 1/8/13.
#
# Use like: sh plot_Contour_Matrix.sh 
if [ $# -eq 0 ]
then
    echo "$0:Error command arguments missing!"
    echo "Usage: sh plot_Contour_Matrix.sh plane z t d b p k u trigger"
    echo "z should be between 1 and 100 (1 is z=0 and 100 is z=boxsize). It does not matter for 110 plane"
    echo "NOTE: k needs to be written as k = x.xxx ! Triggers are: ranPot / potentialMod"
	echo "'plane' needs to be either 00x or 110 (Miller indices)!"
    exit 1
fi

cd /Users/jh/Documents/workspace-cpp/gnuplot

z=$2
frac=$(echo "scale=2;$z/100" | bc )

if [ $z = "0" ]
	then
	echo "Error: z should not be 0!!!"
	exit 1
fi

outfile="Contour_plot" 
if [ $1 = "00x" ]
	then outfile+="_00x_z$frac"
elif [ $1 = "110" ] || [ $1 = "both" ] #TODO
	then outfile+="_110"
else
	echo "'plane' needs to be either 00x or 110 (Miller indices). \n Exiting!"
	exit 1
fi
	
##########

if [[ $9 != "" ]] 
    then 
	trigger=/$9
	outfile+="_$9"
fi
outfile+="_t$3_d$4_b$5_p$6_k$7_u$8"

directory="/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset$trigger/dt0.0005/t$3/d$4/b$5/p$6/k$7/u$8/InstantValues"

######## Check if 3 D matrixfile exists
matrixfile="$directory/posHistoMatrix.txt"
if [ ! -f $matrixfile ]
    then 
    echo "Error: posHistoMatrix.txt not found in directory: \n $directory \n Exiting.."
    exit 1
fi
#TODO get highest value from this file last line
lastline=$(tail -1 $matrixfile)
if [ "$lastline" != "X" ]
	then
	max=$(tail -1 $matrixfile | sed 's/MaxVal //')
else 
	outfile+="NNORM"
	echo "Not normalized!"
	max=1
fi
	
outfile+=".tex"

######## Create grid file if neccessary
if [ $1 = "00x" ]
	then
	grid="$directory/PosHisto_00x-plane_grid_at_z_$frac"
	grid+="b.txt"
else
	grid="$directory/PosHisto_110-plane_grid.txt"
fi

if [ ! -f $grid ]
	then
	sh /Users/jh/Documents/workspace-cpp/gnuplot/get_planeHistoGrid.sh $directory $1 $z
	wait #wait until this is done
fi


######## Create gnuplot script
touch tmp/plot.gp
echo "#" > tmp/plot.gp

#set plot layout (tics, etc.)
echo "set autoscale; unset log; unset label; set ytic auto; set xtic auto" >> tmp/plot.gp
echo "set tics out" >> tmp/plot.gp
echo "set yrange [0:1]" >> tmp/plot.gp

echo "set pm3d map" >> tmp/plot.gp

if [ $1 = "00x" ]
	then
	echo "set xlabel '\$x$ - Position $/$ \$b$'" >> tmp/plot.gp
	#echo "set ylabel '\$z$ - Position / \$b$'" >> tmp/plot.gp
	echo "set xrange [0:1]" >> tmp/plot.gp
	#echo "set size square" >> tmp/plot.gp
	#set pdf output
	echo "set terminal epslatex color size 2.1,2.1" >> tmp/plot.gp  # size 2.4,2.4
	echo "set lmargin at screen 0.1" >> tmp/plot.gp
	echo "set rmargin at screen 0.83" >> tmp/plot.gp
	echo "set tmargin at screen 0.98" >> tmp/plot.gp
	echo "set bmargin at screen 0.24" >> tmp/plot.gp
else
	echo "set xlabel '\$xy$ - Position / \$b$'" >> tmp/plot.gp
	echo "set ylabel '\$z$ - Position / \$b$'" >> tmp/plot.gp
	#echo "set size ratio 0.71" >> tmp/plot.gp
	echo "set xrange [0:1.414]" >> tmp/plot.gp
	#set pdf output
	echo "set terminal epslatex color size 2.77,2.1" >> tmp/plot.gp  # size 3.1,2.4
	echo "unset colorbox" >> tmp/plot.gp 	 #only if they are put next to each other
	echo "set lmargin at screen 0.19" >> tmp/plot.gp
	echo "set rmargin at screen 0.99" >> tmp/plot.gp
	echo "set tmargin at screen 0.98" >> tmp/plot.gp
	echo "set bmargin at screen 0.24" >> tmp/plot.gp
fi


echo "set output '/Users/jh/Documents/workspace-cpp/gnuplot/figures/epslatex/Contour/$outfile'" >> tmp/plot.gp

#Define interpolation level. Gnuplot chooses when using: set pm3d interpolate 0, 0
echo "set pm3d interpolate 0, 0" >> tmp/plot.gp

#Define the colour palette: Test with command: test palette
echo "set palette defined ( 0 '#ffffff', 1 '#ffee00', 2 '#ff7000', 3 '#ee0000', 4 '#7f0000', 5 '#000000' )" >> tmp/plot.gp
echo "set cbtics ('0' 0, 'max' 1)" >> tmp/plot.gp
echo "set cbrange [0:1]" >> tmp/plot.gp
#echo "set cbtics  add ('0' 0.0)" >> tmp/plot.gp

#plotting
if [ $1 = "00x" ]
	then
	echo "plot '$grid' u (\$1/100 + 0.005):(\$2/100 + 0.005):(\$3/$max) matrix w image notitle" >> tmp/plot.gp
else
	echo "plot '$grid' u (\$1 * 0.01414 + 0.005):(\$2/100 + 0.005):(\$3/$max) matrix w image notitle" >> tmp/plot.gp
fi


# obsolete: For plotting both next to each other
#if [ $1 = "both" ]
#	then
#	echo "set terminal epslatex color size 8,2.5 font 'Helvetica,11'" >> tmp/plot.gp
#	echo "set multiplot layout 1,2 rowsfirst" >> tmp/plot.gp
#	echo "set lmargin at screen 0.10" >> tmp/plot.gp
#	echo "set rmargin at screen 0.60" >> tmp/plot.gp
#	echo "set tmargin at screen 0.95" >> tmp/plot.gp
#	echo "set bmargin at screen 0.10" >> tmp/plot.gp
#	
#	
#	echo "set lmargin at screen 0.60" >> tmp/plot.gp
#	echo "set rmargin at screen 0.92" >> tmp/plot.gp
#	echo "set tmargin at screen 0.95" >> tmp/plot.gp
#	echo "set bmargin at screen 0.10" >> tmp/plot.gp
#fi
	

gnuplot tmp/plot.gp; echo $outfile