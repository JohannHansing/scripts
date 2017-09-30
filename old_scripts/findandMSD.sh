#!/bin/bash
#
#
#
#
directory=$1
fitInterval=$2
if [ "$directory" = "" ]
	then
    directory=/Users/jh/Documents/workspace-cpp/SPS/sim_data/noreset
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
# Check if a fit interval for the python script is supplied
if [ "$fitInterval" = "" ]
	then
        fitInterval=100
fi
echo "creating msd.txt in $directory ..."
find $directory -name Coordinates -type d | while read line1
do if [ -f $line1/trajectory.txt ] && [ !  -f $line1/msd.txt ]
    then 
    cd $line1
    echo "msd in: $line1"
	echo "--------------------------------------------"
    python /Users/jh/bin/msdFromTraj.py $fitInterval    # The argument corresponds to the time inerval used for calculating the msd
	fi
done
echo "fitting done!"
