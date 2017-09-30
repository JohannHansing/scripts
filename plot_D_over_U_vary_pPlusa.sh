#!/bin/sh

#  
#
#
if [ $# -eq 0 ]
then
    echo "$0:Error command arguments missing!"
    echo "Usage: plot_D_over_U_vary_pPlusa.sh k p0 type a1 a2 .."
    echo "p0 corresponds to (p+a). a1 NEEDS TO BE 0 in this version"
    exit 1
fi


cd /Users/jh/Documents/workspace-cpp/gnuplot
#
#
#
#Create plotdata file and plot
#


#this stores the arguments in an array
declare -a args=("$@")
sa=3  # number of first of the final arguments 'array'
k=$1
p0=$2
type=$3
a1=$4
if [ $a1 != 0 ]
then echo "ERROR a1 should be 0!!!!!!!!!!!!!!!!!!!!!"
fi
typename=$(echo $type | sed 's;/;;g' )
kfrac=$( echo "$k" | awk '{printf "%g", $1/10}'  )


#outfile is file to save plot to
outfile="D_over_U_at_k$kfrac"
outfile+="_pPlusa$p0"
outfile+="_$typename"
outfile+="_a"



#load default color spectrum
color=($( head -1 /Users/jh/Documents/workspace-cpp/gnuplot/colors/default.txt )) 


# Load default plot parameters
cp -f gp_defaultPlot.txt tmp/plot.gp

# SET SPECIAL PLOT PARAMETERS
echo "set xlabel \"\$U_0/k_B T\$\"" >> tmp/plot.gp
echo "set xrange [-10:20]" >> tmp/plot.gp
echo "set key  top right horiz width 0"  >> tmp/plot.gp



echo "plot \\" >> tmp/plot.gp
folder=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_data/noreset/dt0.0001/t$2

#loop to recursively write plot commands to plot D over U_0 for different d--------------------------------
j=0; 
for (( i=sa;$i<$#;i=$i+1 ))
do
    a=${args[$i]}
	afrac=$( echo "$a" | awk '{printf "%g", $1/10}'  )
    p=$(bc <<< $p0-$a)
    pfrac=$( echo "$p" | awk '{printf "%g", $1/10}'  )
    j=$(( j + 1 ))
	if [ $(echo "$a == 0" | bc) -eq 1 ] 
	    then
			folder=/Users/jh/Documents/workspace-cpp/SingleParticleSimulation/sim_dataOLD/noreset/dt0.0001/t200/d0/b10/p$p/k$k
			MSD=""
	else 
        folder=/Users/jh/Documents/workspace-cpp/SPS/Release/sim_data/noreset/$type/dt0.001/t200/a$a/d0/b10/p$p/k$k
        # folder=/Users/jh/Documents/workspace-cpp/SPS/sim_data/nolub/noreset/steric/dt0.001/t200/a$a/d0/b10 # NOLUB
        MSD="MSD"
	fi
    #create tmp files for plotdata for different k values
    touch tmp/plotdata_$i.txt
    echo "#" > tmp/plotdata_$i.txt
    #recursively find all D values for different U_0
    find $folder -name u* -type d | while read line
        do
        file=$line/InstantValues/linear_fit_parameters$MSD.txt
		if [ -f $file ]
            then 
            u=$(echo "$line" | sed 's/.*u//g' | sed 's:/.*::') #assign u value of folder to variable u
            m=$(grep m $line/InstantValues/linear_fit_parameters$MSD.txt | sed 's/m//')
            echo "$u $m" >> tmp/plotdata_$i.txt
        fi
        done
    echo "\"tmp/plotdata_$i.txt\" u 1:(\$2/6):(\$3/6) ls 1 pt $j lc rgb ${color[$j-1]} ti \"\$p+a=($pfrac+$afrac)b \$\", \\" >> tmp/plot.gp
    outfile+="_$a"
    #lines in the file need to be sorted numerically for linespoints!
    echo "$(sort -n tmp/plotdata_$i.txt)" > tmp/plotdata_$i.txt    
done
#---------------------------------------------------------------------------- end of loop


outfile+=".tex"
#outfile+="_Close-Up.pdf"   #Close-up

echo " " >> tmp/plot.gp
echo "set output '/Users/jh/Documents/workspace-cpp/gnuplot/figures/epslatex/$outfile'" >> tmp/plot.gp
echo "replot" >> tmp/plot.gp

echo "set term aqua" >> tmp/plot.gp
echo "replot" >> tmp/plot.gp

gnuplot tmp/plot.gp; echo $outfile


#rm tmp/plotdata.dat; rm tmp/gnuplot.gp

#definition of Write_folder() function   -----------------------------
#Write_plot_command () {
##write tmp file where data is stored for certain k value
#touch tmp/plotdata.dat
#echo "#" > tmp/plotdata.dat

#recursively find all D values for different U_0
#find $1 -name k$2 -type d | while read line1
#do find $line1 -name u* -type d | while read line2
#do  u=$(echo "$line2" | sed 's/.*u//g' | sed 's:/.*::') #assign u value of folder to variable u
#m=$(grep m $line2/InstantValues/linear_fit_parameters.txt | sed 's/m//')
#echo "$u $m" >> tmp/plotdata.dat
#done
#done
#echo "\"tmp/plotdata.dat\" u 1:(\$2/6):(\$3/6) w yerrorbars ti \"r = $r\", \\" >> tmp/plot.gp
#}
#---------------------------- end of function definition

