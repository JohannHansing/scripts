#!/bin/sh
cd /Users/jh/Documents/workspace-cpp/gnuplot


# Change This array and the for loop accordingly!
Array=(0.001 0.0005)
folder=/Users/jh/Documents/workspace-cpp/SPS/Release/sim_data/noreset/test/noEwald/EwaldTestn3/noLub/steric


#loop to recursively write plot commands to plot D over U_0  ----------------------------------------
j=0
for (( i=0;$i<${#Array[@]};i=$i+1 ))
do
	j=$(( j + 1 ))
    X=${Array[$i]}
    #frac=$(echo "scale=3;$k/10" | bc )
    #create tmp files for plotdata for different u values
    touch tmp/plotdata_$i.txt
    echo "#" > tmp/plotdata_$i.txt
    find $folder/dt$X -name p* -type d | while read line
    	do
        file=$line/k1.000/u0/InstantValues/linear_fit_parametersMSD.txt
            if [ -f $file ]
                then 
                p=$(echo "$line" | sed 's/.*p//g' | sed 's:/.*::' | awk '{printf "%g", $1/10}' ) #assign p value to variable p
                m=$(grep m $file | sed 's/m//')
                echo "$p $m" >> tmp/plotdata_$i.txt
            fi
        done
done
#---------------------------------------------------------------------------- end of loop
