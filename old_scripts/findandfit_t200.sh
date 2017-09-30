#!/bin/bash
#
#
#
#
directory=$1
if [ "$directory" = "" ]
	then
    directory=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset
# else
#     cd $directory
#     if [ "$2" = "long" ]
#         then
#         echo "now LONG fitting file: $directory/squaredisp.dat"
#         gnuplot /Users/jh/Documents/workspace-cpp/gnuplot/gp_linearfit_t1200.txt
#         exit 0
#     fi
#     echo "now fitting file: $directory/squaredisp.dat"
#     gnuplot /Users/jh/Documents/workspace-cpp/gnuplot/gp_linearfit_t200.txt
#     exit 0
fi
echo "fitting recursively in $directory ..."
find $directory -name t200 -type d | while read line1
do
	find $line1 -name InstantValues -type d | while read line2
	do if [ ! -f $line2/linear_fit_parameters.txt ]
	    then 
	    cd $line2
	    echo "now fitting in: $line2"
	    gnuplot /Users/jh/Documents/workspace-cpp/gnuplot/gp_linearfit_t200.txt
    fi; done
done
echo "fitting done!"
