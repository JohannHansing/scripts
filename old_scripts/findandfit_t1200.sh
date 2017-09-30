#!/bin/bash
#
#
#
#
directory=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset
echo "fitting recursively in $directory ..."
find $directory -name t1200 -type d | while read line1
do
    find $line1 -name InstantValues -type d | while read line2
	do if [ ! -f $line2/linear_fit_parameters.txt ]
	then cd $line2; gnuplot /Users/jh/Documents/workspace-cpp/gnuplot/gp_linearfit_t1200.txt;
    echo "$line2"
    fi
    done
done
echo "fitting done!"
