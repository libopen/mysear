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
      
       
      def save6(self,pat,yourtype='pass'):
            snlist=self.getallfile(ROOTPATH,pat)
            i=0
            j=0 
            result=pd.DataFrame()
            #result1=pd.DataFrame()            
            gp=pd.DataFrame()
            for path in snlist:
                              dbcurrent=result
                              #db1=result1
                              _std=STDTB(path)
                              
                              
                              if yourtype=='pass':
                                    gp=stobj.mainindicator6()    
                              else :
                                    df=stobj.indicator6() 
                                    #only get the last row
                                    if df is not None:
                                          df=df.tail(1)
                                          gp=df[(df.Level0==1)&(df.Level3!=0)&(df.curno<=4)]
                                    else:
                                          gp=pd.DataFrame()
                              if gp is not None and len(gp)>0:
                                    try:
                                          #print(stobj.sn)
                                          result=dbcurrent.append(gp)
                                          i=i+1
                                          #print(i)
                                    except:
                                          print(gp.sn)
                                          continue 
                              else:
                                    j=j+1                              
            if result.empty == False:
                  result=result.sort_values('sn')
                  print("{}total:{} ,failure:{}".format(pat,i,j))
                  result.to_csv("gp6{}{}.csv".format(pat,yourtype))        
                  #result1.to_csv("gp6{}{}last.csv".format(pat,yourtype))       
                  return result                                    
                              
      def batsavegp(self,pat,cyctype='D',angtype='z',usemyfind='n'):
            alllist=self.getallfile(ROOTPATH,pat)
            snlist=[]
            if usemyfind=='y':
                  for sn in alllist:
                        for row in self.speciallist:
                              if row in sn:
                                    snlist.append(sn)
            else:
                  snlist=alllist
            
            result=pd.DataFrame()
            result1=pd.DataFrame()
            i=0
            j=0
            gp=pd.DataFrame()
            for path in snlist:
                  dbcurrent=result
                  db1=result1
                  if cyctype=='D':
                        stobj=STDTB(path,angtype)
                        gp=stobj.selftest()
                  else:
                        stobj=STWTB(path,angtype)
                        gp = stobj.getgp()
                  
                  if gp is not None:
                              try:
                                    
                                    result=dbcurrent.append(gp)
                                    if cyctype=='D':
                                          result1=db1.append(gp.tail(1))
                                    else:
                                          result1=db1.append(gp.tail(1))
                                    i=i+1
                              except:
                                    print(gp.sn)
                                    continue
                  else:
                        j=j+1
                        
                  #if i>3:
                        #break
            if result.empty == False:
                  print("{}{}{}total:{} ,failure:{}".format(pat,angtype,cyctype,i,j))
                  result.to_csv("gp{}{}{}.csv".format(pat,angtype,cyctype))        
                  result1.to_csv("gp{}{}{}last.csv".format(pat,angtype,cyctype))       
                  return result1
            
   
 
      
                                       

    
  
  
            
            #return db[(db.lastdate==curdate)&(db.lastc>db.)][['startdate','sn','len','len1','segdrawdown','segdrawdown1','segdrawdown2']]
      
      def dgp(self,sn):
            s=STDTB(sn)
            gp=s.getgp()[s.CONfmore]
            return gp[-5:],s.CONf
      
      def wgp(self,sn):
            s=STWTB(sn)
            gp=s.getgp()[s.CONf]
            return gp[-3:],s.CONfw      
      def mgp(self,sn):
            s=STMTB(sn)
            gp=s.getgp()[s.CONf]
            return gp[-3:],s.CONfm   
      
      #w: ktm 1-2-0 ,1-1-0 d: 0-1-0 if d 0-1-0->0-1-1(t:0->1) then up else down
      CONf=['sn','startdate','sdd','minc','lastc','len','kmt','lastdate']   
      def singlefindwd(self,sn):
            
            _wgp,fw=self.wgp(sn)
            _wgp=_wgp[-1:]
            _wgp.columns=self.CONf
            _wgp=_wgp.set_index('sn')
            _dgp,fd=self.dgp(sn)
            _dgp=_dgp[-1:][fd]
            _dgp.columns=self.CONf
            _dgp=_dgp.set_index('sn')
            gp= pd.concat([_wgp,_dgp],axis=0)
            return gp            
            
            
            

            

              

def main():
    #main1()
      #dofindsh6(findtype='a1')
      #dofindsh6(findtype='m4')
      
      a=ANALYSIS()
      #a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2],usemyfind=sys.argv[3])
      a.save6(pat=sys.argv[1],yourtype=sys.argv[2])
      #if (sys.argv[2]=='t'):
            #a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2],cyctype='W')
      

if __name__=="__main__":
      main()
 
      

