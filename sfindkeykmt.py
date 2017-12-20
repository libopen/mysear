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
            df1=pd.DataFrame()
            for path in snlist:
                  if STS.getkmt(path) is not None:
                        df=pd.Series("{},{}".format(path,STS.getkmt(path)))
                        i=i+1
                        df1=df1.append(df,ignore_index=True)
                  j=j+1
            df1.to_csv("gp6{}.csv".format(pat))                  
            print("{}total:{} ,failure:{}".format(pat,i,j))       
           
                                                              
            
            

            

              

def main():

      
      a=ANALYSIS()
      #a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2],usemyfind=sys.argv[3])
      a.save6(pat=sys.argv[1])
      #if (sys.argv[2]=='t'):
            #a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2],cyctype='W')
      

if __name__=="__main__":
      main()
 
      

