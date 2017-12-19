import pandas as pd
import sys,os
import numpy as np
from time import ctime,sleep
import time
import datetime
import csv
from datetime import timedelta
import STS

#goodkey hope to slove 
#1 the minl always lower startc
#2 the maxh is not the starth
#3 the minlc is the lastc
#4 the minl is provious show at maxh
ROOTPATH='/home/lib/mypython/export/'
def startTime():
      return time.time()
def ticT(startTime):
      useTime=time.time()-startTime
      return round(useTime,3)


   
class ANALYSIS:
      def __init__(self):
            self.speciallist=[]
            self.load()
      def load(self):
            with open('myfind.csv','r') as csvfile:
                  allLines=csv.reader(csvfile)
                  for row in allLines:
                        self.speciallist.append(row[0])
                        
      def myfind(self):
            return self.speciallist
                      

      
      
      def getallfile(self,rootpath,pat):
            
            resultlist=[]
            for lists in os.listdir(rootpath):
                  path=os.path.join(rootpath,lists)
                  if os.path.isdir(path):
                        pass
                  else:
                        # only get lines >60 
                        if os.path.basename(path)[0:3]==pat and os.stat(path).st_size>4000 :#and os.path.basename(path)[0:8]=='SH600576':
                        #if os.path.basename(path)[0:5]=='SH600' and os.stat(path).st_size!=0: 
                              resultlist.append(path[-12:-4])
            return resultlist
      
      
       
      def save6(self,pat):
            snlist=self.getallfile(ROOTPATH,pat)
            i=0
            j=0            
            with open("gp6{}.csv".format(pat),'w',newline='',encoding='gb2312') as csvfile:
                  wr =  csv.writer(csvfile,quoting=csv.QUOTE_NONE,quotechar='',escapechar='\\')
                  for path in snlist:
                        exprow=['' for x in range(2)]
                        exprow[0]=path
                        if STS.getkmt(path) is not None:
                              i=i+1
                              exprow[1]=STS.getkmt(path)
                              wr.writerow(exprow)
                        else:
                              j=j+1
              
            print("{}total:{} ,failure:{}".format(pat,i,j))                                                    
            
            

            

              

def main():

      
      a=ANALYSIS()
      #a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2],usemyfind=sys.argv[3])
      a.save6(pat=sys.argv[1])
      #if (sys.argv[2]=='t'):
            #a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2],cyctype='W')
      

if __name__=="__main__":
      main()
 
      

