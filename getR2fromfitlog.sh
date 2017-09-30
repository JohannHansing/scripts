#!/bin/bash
#
#
#
#
directory=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset

find $directory -name t200 -type d | while read line1
do
	find $line1 -name InstantValues -type d | while read line2
	do 
	if [ -f $line2/fit.log ]
	    then 
	    cd $line2
	    r=$(grep -A5 "correlation" fit.log | grep "^c" | tail -1 | awk '{ print $2 }')
	    if [ $(bc <<< "$r*$r < 0.9") -eq 1 ]
	    then
	    echo "bad fit in $line2"
	    #findandfit_t200.sh $line2 long
	    fi
	fi
	done
done



