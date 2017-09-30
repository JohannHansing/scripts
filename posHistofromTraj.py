#!/usr/bin/python

import sys

def readData(datafile):
    file = open(datafile,'r')
    all_lines = file.readlines()
    i=0
    new_data = []
    for i in xrange(len(all_lines[::1])):
        new_data.append([float(x) for x in all_lines[i].split()])
    file.close()
    return new_data



def makeHisto(dataArr, startInterval, maxTime=2000, error=False):
    "Create histogram from input data array"
    histo = [[[0 for x in range(100)] for x in range(100)] for x in range(100)]
    norm=0
    boxsize=10
    for pos in dataArr:
        x = (int)(pos[1] % boxsize / boxsize * 100) # % returns the modulo of a division
        y = (int)(pos[2] % boxsize / boxsize * 100)
        z = (int)(pos[3] % boxsize / boxsize * 100)
        histo[x][y][z] += 1
        norm += 1
    
    # for x in range(100):
    #     for y in range(100):
    #         for z in range(100):
    #             histo[x][y][z] /= norm



def exportMSD():
    maxTime=2000
    avgInterval=float(sys.argv[1])
    data = readData('trajectory.txt')
    msd = makeMSD(data, avgInterval, maxTime)
    MSDfile = open('msd.txt','w')
    timestep = (data[1][0] - data[0][0])
    for i in xrange((int)(maxTime*1.0/timestep)):
        t = i * timestep
        line = str(t) + '\t' + str(msd[i]) + '\n'
        MSDfile.write(line)


exportMSD()
