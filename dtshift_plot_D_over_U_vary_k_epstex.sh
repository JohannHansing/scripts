#!/bin/sh

#  plot_D_over_k.sh
#  
#
#  Created by Johann on 18/6/13.
#
#input: plot_D_over_U_vary_k.sh d p potmod k1 k2 ...
if [ $# -eq 0 ]
then
    echo "$0:Error command arguments missing!"
    echo "Usage: plot_D_over_U_vary_k.sh d p trigger xMin xMax k1 k2 .."	
    echo "NOTE: k needs to be written as k = x.xxx !"
	echo "NOTE 2: Trigger can be: potMod, DH, Bessel, ranPot, off, no"
    exit 1
fi


cd /Users/jh/bin
touch tmp/tmp.sh
cat plot_D_over_U_vary_k.sh | sed "s/dt0.0005/dt0.0001/g" > tmp/tmp.sh
sh tmp/tmp.sh "$@"