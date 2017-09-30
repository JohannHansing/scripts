#!/bin/bash

#directory you to search:
/Users/jh/Documents/workspace-cpp/SPS/Release/sim_data/noreset/steric/dt0.001/t200/a2/d0/b10/p1/k1.000/u-7

#file to make changes in
file="trajectory.txt"

#the rest has to be changed within the sed command!

echo "searching and replacing recursively in $directory ..."
find $directory -name Coordinates -type d | while read dir
do
    if [ ! -f $dir/msd.txt ]
    then 
        cd $dir
        touch tmp.txt
        echo "" > tmp.txt
        head -9998 $file > tmp.txt
        tail -n +9999 $file | while read line
        do
            nr=$(echo $line | awk '{printf "%.0f\n", $1}')    # print first ($1) word in line as integer (%.0f)
            echo $line  >> tmp.txt
        done 
        mv $file trajbackup.txt
        mv tmp.txt trajectory.txt
        rm tmp.txt
    fi
done
echo "done!"
    
    
    

# OLD method

# #directory you to search:
# directory=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset/LJ/dt0.0001/t200/d0/b10/p0.5
#
# #file to make changes in
# file="sim_Settings.txt"
#
# #the rest has to be changed within the sed command!
#
# echo "searching and replacing recursively in $directory ..."
# find $directory -name $file -type f | while read line
# do
# sed 's/Particle size: 1/Particle size: 0.5/' $line > $line.$$ && \
# cp $line.$$ $line && \
# rm $line.$$
# done
# echo "done!"