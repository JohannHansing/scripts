#!/bin/sh

#  get_planeHistoGrid.sh
#  
#
#  Created by Johann on 1/8/13.
#
# Use like: sh get_planeHistoGrid.sh directory plane z
# z should be between 1 and 100 (1 is z=0 and 100 is z=boxsize)
if [ $# -eq 0 ]
then
    echo "$0:Error command arguments missing!"
    echo "Usage: sh get_planeHistoGrid.sh directory plane z"
	echo "directory is directory of posHistoMatrix.txt containing folder"
    exit 1
fi


directory=$1

matrixfile="$directory/posHistoMatrix.txt"

if [ ! -f $matrixfile ]
    then 
    echo "Error: posHistoMatrix.txt not Found! \n Exiting.."
    exit 1
fi

if [ $2 == "00x" ]
	then
	frac=$(echo "scale=2;$3/100" | bc )
	outfile="$directory/PosHisto_00x-plane_grid_at_z_$frac"
	outfile+="b.txt"
elif [ $2 == "110" ]
	then
	outfile="$directory/PosHisto_110-plane_grid.txt"
else
	echo "'plane' needs to be either 00x or 110 (Miller indices). \n Exiting!"
	exit 1
fi

touch $outfile


row=""

#################### 00x PLANE ################
if [ $2 = "00x" ]
	then
	z=$(( $3 - 1 ))
	while read line
	do 
	    if [ "$line" == "X" ]
	        then 
	        echo "$row" >> $outfile
			row=""
	    else
	        arr=($line)
	        val=${arr[$z]}
	        row="$row $val"
	    fi
	done < $matrixfile
	
#################### 110 PLANE ################
else
	z=1
	while read line
	do 
	    if [ "$line" == "X" ]
	        then 
			echo "$row" >> $outfile
			row=""
	        z=1
	    else
	        arr=($line)
	        val=${arr[$z - 1]}
	        row="$row $val"
	        z=$(( z + 1 ))
	    fi
	done < $matrixfile
fi

echo "done!"