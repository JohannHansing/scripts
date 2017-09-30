#!/usr/bin/python

#plot_D_over_p_vary_type_constU.py created by Johann 27/07/2015


from __future__ import print_function
from myFunctions import touch
import os
import sys
import shutil, errno

import argparse
parser = argparse.ArgumentParser(description='Write gnuplot script for plotting.')
parser.add_argument("-u", "--const_U", metavar='POT_STRENGTH', type=str, required=True, help='Potential strength U_0 in kT.')
parser.add_argument("-a", "--const_a", metavar='POLYMER_WIDTH', type=str, required=True, help='Polymer diameter a in simulation units.')
parser.add_argument('-dir','--typedirs', metavar='TYPEDIR', type=str, nargs='+', required=True, help='sub-directories ../noreset/TYPEDIR/steric/.. specifying the types to be plotted.')
parser.add_argument('-ti','--titles', metavar='TITLE', type=str, nargs='+', required=False, help='Optional title for plotted typedirs')
args = parser.parse_args()


os.chdir('/Users/jh/Documents/workspace-cpp/gnuplot')

#
#
#Create plotdata file and plot
#

arglist=args.typedirs
U=args.const_U
a=args.const_a
afrac = '%g'%(float(a)/10)
titlelist=args.titles


#outfile is file to save plot to
outfile="D_over_p_at_u" + str(U) + "_a" + str(a)


# load default color spectrum into array of strings
with open('colors/default.txt', 'r') as cf:
    colors = cf.readline().split()


# Load default plot parameters into plot.gp file
shutil.copy('gp_defaultPlot.txt', 'tmp/plot.gp')

# SET SPECIAL PLOT PARAMETERS
pf = open('tmp/plot.gp','a')
def printpf(line):
    print(line,file=pf)

printpf('set xlabel "(p+a)/b"')
printpf("set xrange [0:1]")
#printpf("set title \"$title\"" >> tmp/plot.gp #add $1 und $1 for d and potmod!
#printpf("set key off")
#printpf("set logscale y")
#printpf("set yrange [0:1.2]")



printpf("plot \\")

#loop to recursively write plot commands to plot D over U_0  ----------------------------------------
for i in range(len(arglist)):
    typedir=arglist[i]
    typename=typedir.replace('/','')
    if len(titlelist)==i:
        titlelist.append(typename)
    k="1.000"
    folder='/Users/jh/Documents/workspace-cpp/SPS/Release/sim_data/noreset/' + str(typedir) + '/steric/dt0.001/t200/a' + str(a) + '/d0'
    #touch tmp/plotdata_$i.txt
    datafile='tmp/plotdata_' + str(i) + '.txt'
    touch(datafile)
    data = list()
    for root, dirs, files in os.walk(folder):
        name='k' + str(k)
        if name in dirs:
            file=os.path.join(root, name,'u'+str(U),'InstantValues/linear_fit_parametersMSD.txt')
            if os.path.isfile(file):
                p=root.split('/p')[1].split('/k')[0] # assign value from dir to p
                p='%g'%(float(p)/10)                 # make p value p/b
                with open(file, 'r') as fitf:
                    m = fitf.readline().split('m')[1]
                data.append(str(p) + str(m))
                
    printpf('"'+ str(datafile) +'" u ($1+'+ str(afrac) +'):($2/6):($3/6) w linespoints ls 1 pt 5 lc rgb '+ str(colors[i]) +' ti "'+ str(titlelist[i]) +'", \\')
    outfile+='_'+ str(typename)
    with open(datafile, 'w') as df:
        #for line in data:
        print("".join(data),file=df)

#---------------------------------------------------------------------------- end of loop

outfile+='.tex'

printpf(" ")
printpf('set output "/Users/jh/Documents/workspace-cpp/gnuplot/figures/epslatex/'+str(outfile)+'"')
printpf("replot")

printpf("set term aqua")
printpf("replot")

pf.close()

from subprocess import call
call(["gnuplot","tmp/plot.gp"])
print(outfile)

