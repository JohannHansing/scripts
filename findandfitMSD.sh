#!/bin/bash
#
#
#
#
directory=$1
msdInterval=$2
force=$3
if [[ $force != "" ]] && [[ $force != "f" ]]
then
    echo "If you want to force msd and fit, force needs to be 'f'"
    exit 1
fi
if [ "$msdInterval" = "" ]
	then
        msdInterval=100
fi
if [ "$directory" = "" ]
	then
	    echo "******** Please provide a directory ***********"
        exit 1
fi
echo "fitting recursively in $directory ..."
find $directory -name Coordinates -type d | while read line1
do  #if [ ! -f $line1/linear_fit_parametersMSD.txt ]
    #then 
    cd $line1
    if [[ !  -f $line1/msd.txt ]] || [[ $force == "f" ]]
    then
        echo "~~ MSD ~~ in: $line1"
        python /Users/jh/bin/msdFromTraj.py $msdInterval    # The argument corresponds to the time inerval used for calculating the msd
    fi
    if [[ ! -f $line1/linear_fit_parametersMSD.txt ]] || [[ $force == "f" ]]
    then
        echo "fit in: $line1"
        gnuplot /Users/jh/Documents/workspace-cpp/gnuplot/gp_linearfit_MSD.txt
	    cd ..
	    cp Coordinates/linear_fit_parametersMSD.txt InstantValues/linear_fit_parametersMSD.txt
	fi
done
echo "fitting done!"
echo "--------------------**********************------------------------"
