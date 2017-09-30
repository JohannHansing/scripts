#!/bin/bash
#
#
#
#
directory=$1
if [ "$directory" = "" ]
	then
    directory=/Users/jh/Documents/workspace-cpp/SPS/Release/sim_data/noreset
# else
#     cd $directory
    # if [ "$2" = "long" ]
# 		then
# 		echo "now LONG fitting file: $directory/squaredisp.dat"
# 		gnuplot /Users/jh/Documents/workspace-cpp/gnuplot/gp_linearfit_t1200.txt
# 		exit 0
# 	fi
	# echo "now fitting file: $directory/squaredisp.dat"
	#     gnuplot /Users/jh/Documents/workspace-cpp/gnuplot/gp_linearfit_t200.txt
	# exit 0
fi
find $directory -name Coordinates -type d | while read line1
do if [ -f $line1/trajectory.txt ] 
    then 
    cd $line1
    echo "Check Traj in: $line1"
    python /Users/jh/bin/checkTrajFile.py
	echo "--------------------------------------------"
	fi
done
echo "fitting done!"
