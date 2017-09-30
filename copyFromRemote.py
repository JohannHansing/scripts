#!/usr/bin/python

# Native alternative: rsync --dry-run -izr --ignore-existing [origin] [destination]

import os
import sys
import shutil, errno

import argparse
parser = argparse.ArgumentParser(description='copy directory tree from sheldon or yoshi to imac.')
parser.add_argument("-r", "--remote_dir", type=str, required=True, help='sheldon-ng or yoshi directory tree to be copied to imac')
parser.add_argument("-m", "--imac_dir", type=str, required=True, help='imac directory to be copied into')
parser.add_argument("--new", action='store_true', required=False, help='set -n flag, if you want to copy only NEW data folders')
args = parser.parse_args()

workspace_dir='/Users/jh/Documents/workspace-cpp'


# imports all functions in myFunctions.py file
import myFunctions as my

def find_all(name,remote_dir,imac_dir):
    # 1. delete and re-create the backup folder
    shutil.rmtree(workspace_dir+'/Backup',True)
    if not os.path.exists(workspace_dir+'/Backup'):
        os.makedirs(workspace_dir+'/Backup')
    # 2. find folders to replace and put into backup

    # 3. replace folders with data from sheldon
    if remote_dir.find('scratch') == -1:
        sys.exit("Error: Is the first argument really a sheldon or yoshi directory?! no 'scratch' found")
    if (my.lastfolder(remote_dir) != my.lastfolder(imac_dir)):
        sys.exit("Error: Last folder of remote path not the same as last folder of imac path.")

    hits=0
    result = []
    for root, dirs, files in os.walk(remote_dir):
        # if name in files:
        #     print os.path.join(root,name)
        #     destination=os.path.join(root.replace(remote_dir,imac_dir),name)
        if name in dirs:
            source=root
            destination=root.replace(remote_dir,imac_dir)
            # backupCopy=workspace_dir+'/Backup'+destination.replace(workspace_dir,"")
            backupCopy=destination.replace(workspace_dir,workspace_dir+'/Backup')
            print destination
            if (os.path.isdir(destination)):
                if args.new==True: 
                    print "directory exists - no copy!"
                    continue #This avoids copying of the remote data dircetory, if it already exists on the imac
                my.copyanything(destination,backupCopy)
                shutil.rmtree(destination)
            my.copyanything(source,destination)




find_all('Coordinates', args.remote_dir, args.imac_dir )



#
# def readDataAndCheck(datafile):
#     file = open(datafile,'r')
#     all_lines = file.readlines()
#     i=0
#     n=0
#     hit=False
#     new_data = []
#     linePrev = all_lines[0].split()
#     for i in xrange(len(all_lines[1:])):
#         lineArr = all_lines[i+1].split()
#         try:
#             step =  float(lineArr[0]) - float(linePrev[0])
#         except ValueError:
#             print "Could not convert string to float at line ", i
#             step=0
#             hit=True
#         nan = (str(lineArr[1]) == "nan") or (str(lineArr[2]) == "nan") or (str(lineArr[3]) == "nan")
#         if (nan):
#             hit=True
#             print '\nnan at line {} ###########################################################'.format(i)
#             print ""
#             break
#         if (step != 10.0):
#             hit=True
#             print 'Error at line {} ###########################################################'.format(i)
#             print ""
#         linePrev = lineArr
#     file.close()
#     return hit
#
#
#
#
