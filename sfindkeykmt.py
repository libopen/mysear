import pandas as pd
import sys,os
import numpy as np
from time import ctime,sleep
import time
import datetime
import csv
from datetime import timedelta
from STTB import STDTB,STWTB

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
                              resultlist.append(path)
            return resultlist
      
      
       
      def save6(self,pat):
            snlist=self.getallfile(ROOTPATH,pat)
            i=0
            j=0 
            result=pd.DataFrame()
            gp=pd.DataFrame()
            for path in snlist:
                  try:
                        dbcurrent=result
                        #db1=result1
                        _std=STDTB(path)
                        _stw=STWTB(path)
                        if _stw.seed() is not None:
                              _gp=_stw.seed()[['sn','seedmod','areamod','keymod']]
                              _dgp=_std.seed()[['seedmod','areamod','keymod']]
                              _dgp.columns=['dseedmod','dareamod','dkeymod']
                              gp=pd.concat([_gp,_dgp],axis=1)[['sn','seedmod','areamod','keymod','dseedmod','dareamod','dkeymod']]                            
                              gp['keymod_key']=gp['keymod'].str.split(':').str[0].astype(str)
                              gp['dkeymod_key']=gp['dkeymod'].str.split(':').str[0].astype(str)
                              cols=['sn','areamod','dareamod','seedmod','dseedmod','keymod_key','dkeymod_key','keymod','dkeymod']
                              result=dbcurrent.append(gp[cols])
                              i=i+1
                                          #print(i)
                  except:
                                          #print(path)
                                          j=j+1  
                                          continue 
                             
                                                                
            if result.empty == False:
                  result=result.sort_values(['areamod','dareamod','seedmod','dseedmod'])
                  print("{}total:{} ,failure:{}".format(pat,i,j))
                  result[((result.seedmod=='411')|(result.seedmod=='231'))].to_csv("gp6{}.csv".format(pat))        
                  #result.to_csv("gp6{}.csv".format(pat))       
                  return result                                    
                              
  
            
            

            

              

def main():

      
      a=ANALYSIS()
      #a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2],usemyfind=sys.argv[3])
      a.save6(pat=sys.argv[1])
      #if (sys.argv[2]=='t'):
            #a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2],cyctype='W')
      

if __name__=="__main__":
      main()
 
      

