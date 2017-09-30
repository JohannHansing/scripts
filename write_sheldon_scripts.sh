#!/bin/sh

#  write_sheldon_scripts.sh
#  
#
#  Created by Johann on 18/6/13.
#
# Call: 
#SingleParticleSim writeTraj resetPos potMod recordMFP recordPosHisto steric LJ runs dt t d b p k u

cd /Users/jh/Documents/Remote_PC/sheldon_scripts
writeTraj="false"
resetPos="false"
potMod="false"
recordMFP="false"
recordPosHisto="false"
steric="false"
ranPot="false"
runs=10000
dt=0.0001
t=200
d_arr=(0)    # Separate by space!
b_arr=(10)
p_arr=(1)
k_arr=(3 4 5)
u_arr=(-20 -15 -10 -7 -5 -3 -1 1 3 5 7 10 15 20)
name="p1Extra"	
walltime="55:00:00"

counter=1
echo "writing: $name"
rm -r job_scripts_prev
mv job_scripts job_scripts_prev   # Saves previous job scripts, in case I need to check something again
mkdir job_scripts
for (( d = 0 ; $d < ${#d_arr[@]} ; d=$d+1 ))
do
	for (( b = 0 ; $b < ${#b_arr[@]} ; b=$b+1 ))
	do
		for (( p = 0 ; $p < ${#p_arr[@]} ; p=$p+1 ))
		do
			for (( k = 0 ; $k < ${#k_arr[@]} ; k=$k+1 ))
			do
				for (( u = 0 ; $u < ${#u_arr[@]} ; u=$u+1 ))
				do
					touch job_scripts/job_$counter.sh					
					echo "job_$counter.sh"
					cat job_template.sh | sed "s/WALLTIME/$walltime/" | sed "s/JOBNAME/SPS$name$counter/" | sed "s/PARAMETERS/$writeTraj $resetPos $potMod $recordMFP $recordPosHisto $steric $ranPot $runs $dt $t ${d_arr[d]} ${b_arr[b]} ${p_arr[p]} ${k_arr[k]} ${u_arr[u]}/" > job_scripts/job_$counter.sh
					counter=$(( counter + 1 ))
				done
			done
		done
	done
done
echo "$(( counter - 1 )) job scripts written!"
					
cp write_sheldon_scripts.sh job_scripts/parameters.txt