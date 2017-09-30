#!/usr/bin/python

import sys

def readData(datafile):
    file = open(datafile,'r')
    all_lines = file.readlines()
    i=0
    n=0
    new_data = []
    for i in xrange(len(all_lines[::1])):
        new_data.append([float(x) for x in all_lines[i].split()])
    file.close()
    return new_data



def makeMSD(dataArr, startInterval, maxTime=2000, error=False):
    "Create msd array from 2D input data array"
    points = len(dataArr)
    step = (int) (startInterval*1.0/(dataArr[1][0] - dataArr[0][0]))
    N = points//step # This gives the max number of displacements to average over
    maxPoint = (int)(maxTime*1.0/(dataArr[1][0] - dataArr[0][0]))
    sd = [0] * maxPoint
    msd = [0] * maxPoint
    count = [0] * maxPoint
    if (error):
        msd_err = [0] * maxPoint
    for i in xrange(N):
        mark = i*step
        # print dataArr[mark][0]
        r0x = dataArr[mark][1]
        r0y = dataArr[mark][2]
        r0z = dataArr[mark][3]
        k=0 
        #for k in xrange(points-mark):
        while (k < ((N-i)*step) and k < maxPoint):
            drx = dataArr[mark+k][1] - r0x
            dry = dataArr[mark+k][2] - r0y
            drz = dataArr[mark+k][3] - r0z
            #sqrdisp = drx*drx + dry*dry#TODO 2D
            sqrdisp = drx*drx + dry*dry + drz*drz
            sd[k] += sqrdisp
            if (error):
                msd_err += sqrdisp*sqrdisp
            count[k] += 1
            k+=1
    msd = [sd[i]/count[i] for i in xrange(maxPoint)]
    return msd


def normMSD(dataArr,msd):
    return [msd[i]/((i+1)*6*(dataArr[1][0] - dataArr[0][0])) for i in xrange(len(msd))]

def makeMSD0t(dataArr, startInterval):
    msd = makeMSD(dataArr,startInterval)
    return normMSD(dataArr,msd)

def exportMSD(avgInterval):
    maxTime=2000
    data = readData('trajectory.txt')
    msd = makeMSD(data, avgInterval, maxTime)
    MSDfile = open('msd.txt','w')
    timestep = (data[1][0] - data[0][0])
    for i in xrange((int)(maxTime*1.0/timestep)):
        t = i * timestep
        line = str(t) + '\t' + str(msd[i]) + '\n'
        MSDfile.write(line)


exportMSD(float(sys.argv[1]))
