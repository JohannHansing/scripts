#!/bin/bash
#
#
#
#
directory=$1
if [ "$directory" = "" ]
	then
    directory=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset
else
    cd $directory
    echo "now fitting in: $directory"
    gnuplot /Users/jh/Documents/workspace-cpp/gnuplot/gp_linearfit_t200.txt
	exit 0
fi
echo "averaging Epot recursively in $directory ..."
find $directory -name t200 -type d | while read line1
do
	find $line1 -name InstantValues -type d | while read line2
	do if [ ! -f $line2/average_Epot.txt ]
	    then 
	    cd $line2
	    echo "now fitting in: $line2"
	    gnuplot /Users/jh/Documents/workspace-cpp/gnuplot/gp_linearfit_Epot.txt
    fi; done
done
echo "averaging done!"
