#!/usr/bin/env python3
import sys
import os
import pandas as pd
#os.chdir('/Users/jh/Documents/iPythonNB')
import argparse
import re


def main():
    dirdic = {'HI':     '/Users/jh/Documents/iPythonNB/HIforBD/data/dataFrameSPSHI.csv', 
              'rand':   '/Users/jh/Documents/iPythonNB/Ranb/data/dataFrameRanbrand.csv',
              'ranU':   '/Users/jh/Documents/iPythonNB/Ranb/data/dataFrameRanbranU.csv',
              'mixU':   '/Users/jh/Documents/iPythonNB/Ranb/data/dataFrameRanbmixU.csv',
              'setPBC': '/Users/jh/Documents/iPythonNB/Ranb/data/dataFrameRanbsetPBC.csv'
                  }
    parser = argparse.ArgumentParser(description='create or update pandas dataframe.')
    parser.add_argument("-sd", "--search_dirs", nargs="+", type=str, required=True, help='search data in these directories.')
    parser.add_argument("-u", "--update", type=str, required=True, help='HI, rand, ranU, mixU, setPBC')
    parser.add_argument("--reset",  action='store_true', required=False, help='set this flag, if you want to reset the dataframe with the data in sd')
    
    #parser.add_argument("-u", "--update", action='store_true', required=False, help='set -f flag, if you want to force msd and fit')
    args = parser.parse_args()
    csvdir = dirdic[args.update]
    if ( not os.path.exists(csvdir)) or args.reset==True:
        if args.reset==True: print("Reseting data frame ",args.update,"...")
        # if dataframe does not exists: create it!
        reviseDF(pd.DataFrame(makeDict(args.search_dirs[0]))).to_csv(csvdir, encoding='utf-8',index=False)
        return 0
    else:
        dfold = pd.read_csv(csvdir, encoding='utf-8')
    #print(dfold.query('preEwald==True and n==2 and t==200 and p==1'))
    for newdir in args.search_dirs:
        dfnew = pd.DataFrame(makeDict(newdir))
        dfold = updateDF(dfnew,dfold)
    #print(dfold.query('preEwald==True and n==2 and t==200 and p==1'))
    reviseDF(dfold).to_csv(csvdir, encoding='utf-8',index=False)


def getdd0(pathtofitfile):
    with open(pathtofitfile, 'r') as f:
        first_line = f.readline()
        return (float(first_line.split()[1]))/6
    
def getphiEff(pathtofitfile):
    with open(pathtofitfile, 'r') as f:
        first_line = f.readline()
        return (float(first_line.split()[0]))

def makeDict(directory):
    folder_ignore = ['noreset','Release','sim_data','fixb']
    skipdir = ['gamma','gamma2','pointq','ranRodRel','ranRod']
    dictlist = []
    problemFolders=[]
    for root, dirs, files in os.walk(directory):
        for folderx in dirs:
            if folderx == "InstantValues":
                if os.path.isfile(os.path.join(root,folderx,"linear_fit_parametersMSD.txt")):
                    pathto = root.split('/')
                    pathto = pathto[pathto.index('workspace-cpp')+1:]
                    #print(pathto)
                    datadict = {}
                    datadict['path'] = root
                    for folder in pathto:
                        if folder in folder_ignore: continue
                        elif folder == "SPS": folder = "SPSHI"
                        # extract number with regular expression
                        num = re.findall(r"[+-]?\d+(?:\.\d+)?", folder) 
                        if num == []:
                            #print('No number in ',folder)
                            datadict[folder] = True
                        elif len(num) == 1:
                            #print('Number is',num[0],'in folder ',folder)
                            if not folder.endswith(num[0]):
                                #print('!!! Maybe Problem with folder: ', folder)
                                if not folder in problemFolders:
                                    problemFolders.append(folder)
                                datadict['pepType'] = folder
                            else:
                                var = re.sub(num[0], '', folder)
                                datadict[var] = float(num[0])
                        else:
                            print('\n====> ERROR! more than one number in',folder)
                    # add D/D0
                    datadict['dd0'] = getdd0(os.path.join(root,folderx,"linear_fit_parametersMSD.txt"))
                    # add phiEff
                    if os.path.isfile(root+'/'+folderx+'/phiEff.txt'):
                        datadict['phiEff'] = getphiEff(root+'/'+folderx+'/phiEff.txt')
                    dictlist.append(datadict)
    if problemFolders!=[]: print("Possible Problems in:",problemFolders)
    return dictlist

def reviseDF(df):
    # http://stackoverflow.com/questions/13148429/how-to-change-the-order-of-dataframe-columns
    # make path last column and dd0 second last
    cols = df.columns.tolist()
    #print(cols)
    cols.remove("path"); cols.remove("dd0"); cols.remove("dt"); cols.remove("t");
    cols=["t","dt"]+cols+["dd0","path"]
    #print(cols)
    return df[cols]
    
def updateDF(dfnew,dfold):
    # This bit of code combines the old df with the new one and drops all duplicates in path
    return dfold.append(dfnew).drop_duplicates(subset='path', keep='last').reset_index(drop=True)

if __name__ == '__main__':
    main()
