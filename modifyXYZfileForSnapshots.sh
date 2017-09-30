#!/bin/bash
#
#
#
#

cd $1
space=1
counter=0
touch snapShotTMP.xyz
echo "sim_name (  10.000   10.000   10.000) t=0" > snapShotTMP.xyz
grep "H" single_traj.xyz | while read line
do
	if [[ "$counter" == "$space" ]]
	then 
	    echo $line >> snapShotTMP.xyz
		counter=0
	fi
	counter=$(( counter + 1 ))
done

lines=$(wc -l snapShotTMP.xyz | awk '{print $1}')
spheres=$((lines-1))


#sed -i "s/XXX/$spheres/" "snapShotFile.xyz"
echo "$spheres" | cat - snapShotTMP.xyz > "snapShots$spheres.xyz"


# TO DO A LOT AT ONCE!
# find /Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset/dt0.0005/t500000x/d0/b10 -name Coordinates -type d | while read line; do  modifyXYZfileForSnapshots.sh $line; done



