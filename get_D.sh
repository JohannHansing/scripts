#!/bin/sh

#  get_D.sh
#  
#
#  Created by Johann on 18/6/13.
#
#input: get_D.sh TODO
#
#********************************************************
#********************************************************
#Maybe include "Filename_addition_string" in args of script
#so one can include "attractive_" or "repulsive_" in the filename
#********************************************************
#********************************************************
#
#
if [ $# -eq 0 ]
then
    echo "$0:Error command arguments missing!"
    echo "Usage: get_D.sh trigger d k u p1 p2 .."
    exit 1
fi

if  [ $1 != "off" ] && [ $1 != "no" ]
	then
	trigger=/$1
fi

cd /Users/jh/Documents/reports-talk-etc/Excel/data
declare -a args=("$@")
filename="$1_$2_$3_$4_$5.txt"
touch $filename
echo "# p    m" > $filename

folder=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset$trigger/dt0.0001/t200/d$2/b10

#loop   ----------------------------------------
j=0
for (( i=4;$i<$#;i=$i+1 ))
do
	j=$(( j + 1 ))
    p=${args[$i]}
    m=$(grep m $folder/p$p/k$3/u$4/InstantValues/linear_fit_parameters.txt | sed 's/m//')
    echo "$p $m" >> $filename
    echo "$(sort -n $filename)" > $filename
done
#---------------------------------------------------------------------------- end of loop

echo "Done!"