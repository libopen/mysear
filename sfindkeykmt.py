import pandas as pd
import sys,os
import numpy as np
from time import ctime,sleep
import time
import datetime
import csv
from datetime import timedelta
from STWTB import STMTB,STWTB
from STDTB2 import STDTB
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
                        if _stw.curstate() is not None:
                              gp=_stw.seed1()[['sn','totalkey','keypos']]
                              gp['seed']=0
                              seed=_std.getseed1()
                              if seed is not None  :
                                    gp['seed']=seed
                              result=dbcurrent.append(gp)
                              i=i+1
                                          #print(i)
                  except:
                                          #print(path)
                                          j=j+1  
                                          continue 
                             
                                                                
            if result.empty == False:
                  result=result.sort_values('sn')
                  print("{}total:{} ,failure:{}".format(pat,i,j))
                  result[(result.totalkey>0)|((result.seed=='22')&(result.seed=='42'))].to_csv("gp6{}.csv".format(pat))        
                  #result1.to_csv("gp6{}{}last.csv".format(pat,yourtype))       
                  return result                                    
                              
  
            
            

            

              

def main():
    #main1()
      #dofindsh6(findtype='a1')
      #dofindsh6(findtype='m4')
      
      a=ANALYSIS()
      #a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2],usemyfind=sys.argv[3])
      a.save6(pat=sys.argv[1])
      #if (sys.argv[2]=='t'):
            #a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2],cyctype='W')
      

if __name__=="__main__":
      main()
 
      

