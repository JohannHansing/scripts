#!/usr/bin/env python3
from subprocess import Popen
from shutil import copyfile
import os
import sys
import argparse
parser = argparse.ArgumentParser(description='find and fit trajectory files.')
parser.add_argument("-sd", "--search_dirs", nargs="+", type=str, required=True, help='search files to be fitted in these directories.')
parser.add_argument("-dmsd", "--delta_msd", default=100, type=int, required=False, help='maximum interval for msd calculation, default 100')
parser.add_argument("-f", "--force", action='store_true', required=False, help='set -f flag, if you want to force msd and fit')
args = parser.parse_args()

if args.force==True:
    print("%%%%%%%%%%%%%%%%%%%%%%\n%%%%%%%%%%%%%%%%%%%%%%\n%%%%%%%%%%%%%%%%%%%%%%\n")

sps = [] # list of tuples for subprocesses and respective directories
# find all folders 'Coordinates'
for d in args.search_dirs:
    owd = os.getcwd()
    for root, dirs, files in os.walk(d):
        if "Coordinates" in dirs:
            print("trajectory.txt found in:\n",os.path.join(root))
            if (not os.path.isfile(os.path.join(root,"Coordinates/msd.txt")) or args.force): 
                os.chdir(os.path.join(root,"Coordinates"))
                print("~~~~ MSD and fit ~~~~")
                # msd and fit commands in triple quotes
                if args.force: Popen(['rm','msd.txt']).wait()
                shellcommand = 'python /Users/jh/bin/msdFromTraj.py ' + str(args.delta_msd)
                shellcommand += ' && gnuplot /Users/jh/Documents/workspace-cpp/gnuplot/gp_linearfit_MSD.txt '
                shellcommand += ' && cp linear_fit_parametersMSD.txt ../InstantValues/linear_fit_parametersMSD.txt '
                #print(shellcommand)
                with open(os.devnull, 'w') as fp:
                    sps.append((Popen(shellcommand, shell=True, stdout=fp, stderr=fp)  ,  root))
            else: print("*** msd.txt exist.. no fitting performed")
            print("____________________________________________________________")
    os.chdir(owd)
exit_codes = [sp.wait() for sp,d in sps]
print("-------- ",exit_codes)
for i,code in enumerate(exit_codes):
    if code!=0:
        print("++++++++++++++++++++++++++\n  ==>> WARNING: There was an error for ", sps[i][1])
print("fitting done!\n--------------------**********************------------------------")
