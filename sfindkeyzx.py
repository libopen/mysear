import pandas as pd
import sys,os
import numpy as np
import talib 
from time import ctime,sleep
import time
import datetime
import csv
from datetime import timedelta
from talib import MA_Type
from zigzag import *
#goodkey hope to slove 
#1 the minl always lower startc
#2 the maxh is not the starth
#3 the minlc is the lastc
#4 the minl is provious show at maxh

def startTime():
      return time.time()
def ticT(startTime):
      useTime=time.time()-startTime
      return round(useTime,3)

ROOTPATH='/home/lib/mypython/export/'
   
      
class STDTB(object):
      
      def __init__(self,file,angtype='z'):
            self.name='STDTB'
            if len(file)==8:
                  self.sn=file[-6:]
                  self.snpath="{}{}.txt".format(ROOTPATH,file)            
            else:
                  self.sn=os.path.splitext(file)[0][-6:] 
                  self.snpath=file
            self.angtype=angtype
            self.load()
            
      
      def load(self):
            self.db=pd.read_csv(self.snpath,header=None,names=['date','o','h','l','c','v','m'])
            self.db.date=pd.to_datetime(self.db.date)
            
      def gettrn(self,x):
            if (x.prez13mode==-1 and x.z13mode==1) or (x.prez13mode==1 and x.z13mode==-1):
                  return x.id
            else:
                  return 0 
            
 
      def regroup13(self,db):
            curid=0
            for index,row in db.iterrows():
                  if row['prez13mode']!=row['z13mode']:
                        curid=index
                  
                  db.loc[index,'gpid']=curid
            return db 
      def regroup6(self,db):
            curid=0
            for index,row in db.iterrows():
                  if row['prez6mode']!=row['z6mode']:
                        curid=index
                  
                  db.loc[index,'gpid6']=curid
            return db 
 
 
      def getexdb(self):
            try:
                  self.load()
                  exdb=self.db
                  exdb['dif'],exdb['dea'],exdb['macd']=talib.MACD(np.array(exdb.c),10,20,6) # change
 
                  exdb['id']=exdb.index
 
                  exdb['dmzu']=exdb.apply(lambda x:-x.macd if (x.macd<0)&(x.dif>0)&(x.dea>0) else 0 ,axis=1) #zero axis down macd
                  exdb['dmzd']=exdb.apply(lambda x:-x.macd if (x.macd<0)&(x.dmzu==0) else 0 ,axis=1)
                  exdb['umzu']=exdb.apply(lambda x:x.macd if (x.macd>0)&(x.dif>0)&(x.dea>0) else 0 ,axis=1)
                  exdb['umzd']=exdb.apply(lambda x:x.macd if (x.macd>0)&(x.umzu==0) else 0 ,axis=1)
                  exdb['idmzu']=exdb.apply(lambda x:1 if (x.macd<0)&(x.dif>0)&(x.dea>0) else 0 ,axis=1)
                  exdb['idmzd']=exdb.apply(lambda x:1 if (x.macd<0)&(x.idmzu==0) else 0 ,axis=1)
                  exdb['iumzu']=exdb.apply(lambda x:1 if (x.macd>0)&(x.dif>0)&(x.dea>0) else 0 ,axis=1)
                  exdb['iumzd']=exdb.apply(lambda x:1 if (x.macd>0)&(x.iumzu==0) else 0 ,axis=1)
                  z6=peak_valley_pivots(np.array(exdb.c),0.06,-0.06)
                  z13=peak_valley_pivots(np.array(exdb.c),0.13,-0.13)
                  z6mode=pivots_to_modes(z6)
                  z13mode=pivots_to_modes(z13)
                  
                  exdb['z6']=pd.Series(z6,index=exdb.index)
                  exdb['z13']=pd.Series(z13,index=exdb.index)
                  exdb['z6mode']=pd.Series(z6mode,index=exdb.index)
                  exdb['z13mode']=pd.Series(z13mode,index=exdb.index)
                  exdb['prez13mode']=exdb.z13mode.shift(1).fillna(0).astype(int)
                  exdb['prez6mode']=exdb.z6mode.shift(1).fillna(0).astype(int)
                  
                  exdb['gpid']=0
                  exdb['gpid6']=0
                  
     
                  exdb=self.regroup13(exdb)
                  exdb=self.regroup6(exdb)
                  exdb['s6id']=exdb.id-exdb.gpid6+1 #use for get the current position in current seg
                  exdb['s13id']=exdb.id-exdb.gpid+1
                  
                  return exdb
            except:
                  pass
                  #print (self.sn)
         
 
       
      def creatgp13(self,db):
                  # group by gpid get sum of md and gpred
            if db.empty==False and len(db)>60:
                  gp22=db.groupby('gpid').sum()[['z13mode','idmzu','idmzd','iumzu','iumzd']]
                  gp22.columns=['s13len','s13sumdmzu','s13sumdmzd','s13sumumzu','s13sumumzd']
                  gp23=db.groupby('gpid').max()[['dmzu','umzu','umzd','dmzd']]
                  gp23.columns=['s13maxdmzu','s13maxumzu','s13maxumzd','s13maxdmzd']
                  
                  #gp23=db.groupby('gpid')
                  idx=db.groupby('gpid')['id'].transform(min)==db['id']
                  gp3=db[idx][['gpid','date','c']]
                  gp3.columns=['gpid','s13startdate','s13startc']
                  gp3=gp3.set_index('gpid')
                  idx2=db.groupby('gpid')['id'].transform(max)==db['id']  #the current and the last position
                  gp32=db[idx2][['gpid','date','c','s13id']]
                  gp32.columns=['gpid','s13lastdate','s13lastc','s13id']
                  gp32=gp32.set_index('gpid')
                  s6=db.groupby('gpid').gpid6.nunique()
                  gp6=pd.DataFrame(s6)
                  gp6.columns=['s6segs']
                  gp=pd.concat([gp22,gp23,gp3,gp32,gp6],axis=1,join="inner")
                  
                  gp['s13len1']=gp.s13len.shift(1) 
                  gp=gp.dropna(axis=0)  #drop the first row that is not really segment
                  
                  gp['s13len2']=gp.s13len.shift(2)
                  gp['s13len3']=gp.s13len.shift(3)
                  gp['s13len4']=gp.s13len.shift(4)
                  p13=peak_valley_pivots(np.array(db['c']),0.13,-0.13)
                  s13sdd=compute_segment_returns(np.array(db['c']),p13)
                  #segdrawdown=np.insert(segdrawdown,0,0)
                  gp['s13sdd']=pd.Series(s13sdd,index=gp.index)
                  gp['s13sdd1']=gp.s13sdd.shift(1)
                  gp['s13sdd2']=gp.s13sdd.shift(2)
                  gp['s13sdd3']=gp.s13sdd.shift(3)
                  gp['s13sdd4']=gp.s13sdd.shift(4)
                  gp['s13g0']=gp.apply(lambda x:x.s13lastc if x.s13len>0 else x.s13startc,axis=1)
                  gp['s13d0']=gp.apply(lambda x:x.s13lastc if x.s13len<0 else x.s13startc,axis=1)
                  gp['s13startc1']=gp.s13startc.shift(1)
                  gp['s13startc2']=gp.s13startc.shift(2)
                  gp['s13startc3']=gp.s13startc.shift(3)
                  gp['s13startc4']=gp.s13startc.shift(4)
                  gp['s13lastc1']=gp.s13lastc.shift(1)
                  gp['s13lastc2']=gp.s13lastc.shift(2)
                  gp['s13lastc3']=gp.s13lastc.shift(3)
                  gp['s13lastc4']=gp.s13lastc.shift(4)
                  gp['s13g1']=gp.apply(lambda x :x.s13lastc1 if x.s13len1>0 else x.s13startc1,axis=1)
                  gp['s13d1']=gp.apply(lambda x :x.s13lastc1 if x.s13len1<0 else x.s13startc1,axis=1)
                  gp['s13g2']=gp.apply(lambda x :x.s13lastc2 if x.s13len2>0 else x.s13startc2,axis=1)
                  gp['s13d2']=gp.apply(lambda x :x.s13lastc2 if x.s13len2<0 else x.s13startc2,axis=1)                  
                                   
                  gp['s13g3']=gp.apply(lambda x :x.s13lastc3 if x.s13len3>0 else x.s13startc3,axis=1)
                  gp['s13d3']=gp.apply(lambda x :x.s13lastc3 if x.s13len3<0 else x.s13startc3,axis=1)                  
                  gp['s13g4']=gp.apply(lambda x :x.s13lastc4 if x.s13len4>0 else x.s13startc4,axis=1)
                  gp['s13d4']=gp.apply(lambda x :x.s13lastc4 if x.s13len4<0 else x.s13startc4,axis=1)                  
                  #if x.s13len3>0 min(d3,d4) max(g3,g2) else max(g3,g4) -min(g3,g2)
                  gp['s13h3']=gp.apply(lambda x: max(x.s13g3,x.s13g2)-min(x.s13d3,x.s13d4) if x.s13len3>0 else max(x.s13g3,x.s13g4)-min(x.s13d3,x.s13d2),axis=1 )
                  gp['s13h2']=gp.apply(lambda x: max(x.s13g2,x.s13g1)-min(x.s13d2,x.s13d3) if x.s13len2>0 else max(x.s13g2,x.s13g3)-min(x.s13d2,x.s13d1),axis=1 )
                  gp['s13h1']=gp.apply(lambda x: max(x.s13g1,x.s13g0)-min(x.s13d1,x.s13d2) if x.s13len1>0 else max(x.s13g1,x.s13g2)-min(x.s13d1,x.s13d0),axis=1 )
                                  
                  gp['s13sumumzu1']=gp.s13sumumzu.shift(1)
                  gp['s13sumumzd1']=gp.s13sumumzd.shift(1)
                  gp['s13maxumzu1']=gp.s13maxumzu.shift(1)
                  gp['s13maxumzd1']=gp.s13maxumzd.shift(1)
                  gp['s13maxdmzu2']=gp.s13maxdmzu.shift(2)
                  gp['s13maxdmzd2']=gp.s13maxdmzd.shift(2)
                  gp['s13sumdmzu2']=gp.s13sumumzu.shift(2)
                  gp['s13sumdmzd2']=gp.s13sumumzd.shift(2)                  
                  gp['s6segs1']=gp.s6segs.shift(1)
                  gp['s6segs2']=gp.s6segs.shift(2)
                  gp['s6segs3']=gp.s6segs.shift(3)
                  gp['s6segs4']=gp.s6segs.shift(4)
                  # seg3 up seg seg2 down seg seg1 up seg seg current seg is also key entry
                  
                  gp['s13startdate1']=gp.s13startdate.shift(1)
                  gp['s13startdate2']=gp.s13startdate.shift(2) 
                  gp['s13startdate3']=gp.s13startdate.shift(3)
                  gp['s13startdate4']=gp.s13startdate.shift(4)
                  gp['gpid']=gp.index
                  return gp        
            
      def creatgp13v2(self,db):
                        # group by gpid get sum of md and gpred
                  if db.empty==False and len(db)>60:
                        gp22=db.groupby('gpid').sum()[['z13mode']]
                        gp22.columns=['s13len']
      
                        #gp23=db.groupby('gpid')
                        idx=db.groupby('gpid')['id'].transform(min)==db['id']
                        gp3=db[idx][['gpid','date','c']]
                        gp3.columns=['gpid','s13startdate','s13startc']
                        gp3=gp3.set_index('gpid')
                        idx2=db.groupby('gpid')['id'].transform(max)==db['id']
                        gp32=db[idx2][['gpid','date','c']]
                        gp32.columns=['gpid','s13lastdate','s13lastc']
                        gp32=gp32.set_index('gpid')
                        s6=db.groupby('gpid').gpid6.nunique()
                        gp6=pd.DataFrame(s6)
                        gp6.columns=['s6segs']
                        gp=pd.concat([gp22,gp3,gp32,gp6],axis=1,join="inner")
      
                        gp['s13len1']=gp.s13len.shift(1) 
                        gp=gp.dropna(axis=0)  #drop the first row that is not really segment
      
                        p13=peak_valley_pivots(np.array(db['c']),0.13,-0.13)
                        s13sdd=compute_segment_returns(np.array(db['c']),p13)
                        #segdrawdown=np.insert(segdrawdown,0,0)
                        gp['s13sdd']=pd.Series(s13sdd,index=gp.index)
                        gp['s13sdd1']=gp.s13sdd.shift(1)
                        gp['s13sdd2']=gp.s13sdd.shift(2)
                        gp['s13g0']=gp.apply(lambda x:x.s13lastc if x.s13len>0 else x.s13startc,axis=1)
                        gp['s13d0']=gp.apply(lambda x:x.s13lastc if x.s13len<0 else x.s13startc,axis=1)
                        gp['s13startc1']=gp.s13startc.shift(1)
                        gp['s13lastc1']=gp.s13lastc.shift(1)
                        gp['s13g1']=gp.apply(lambda x :x.s13lastc1 if x.s13len1>0 else x.s13startc1,axis=1)
                        gp['s13d1']=gp.apply(lambda x :x.s13lastc1 if x.s13len1<0 else x.s13startc1,axis=1)
                        gp['s6segs1']=gp.s6segs.shift(1)
                        gp['s6segs2']=gp.s6segs.shift(2)
                        gp['s13startdate1']=gp.s13startdate.shift(1)
                        gp['s13startdate2']=gp.s13startdate.shift(2) 
                        gp['gpid']=gp.index
                        return gp        
 
                  
      def creatgp6(self,db):
                  # group by gpid get sum of md and gpred
            if db.empty==False and len(db)>60:
                  gp22=db.groupby('gpid6').sum()[['z6mode','idmzu','idmzd','iumzu','iumzd']]
                  gp22.columns=['s6len','s6sumdmzu','s6sumdmzd','s6sumumzu','s6sumumzd'] #len6 :seg6 
                  #gp23=db.groupby('gpid')
                  gp23=db.groupby('gpid6').max()[['dmzu','umzu','umzd','dmzd']]
                  gp23.columns=['s6maxdmzu','s6maxumzu','s6maxumzd','s6maxdmzd']                  
                  gp24=db.groupby('gpid6').min()[['c',]]
                  gp24.columns=['s6minc']                  
                  idx=db.groupby('gpid6')['id'].transform(min)==db['id']
                  gp3=db[idx][['gpid6','date','c']]
                  gp3.columns=['gpid6','s6startdate','s6startc']
                  gp3=gp3.set_index('gpid6')
                  idx2=db.groupby('gpid6')['id'].transform(max)==db['id']
                  gp32=db[idx2][['gpid6','date'     ,'c'      ,'gpid','s6id']]
                  gp32.columns=['gpid6','s6lastdate','s6lastc','gpid','s6id']
                  gp32=gp32.set_index('gpid6')
                  gp=pd.concat([gp22,gp23,gp24,gp3,gp32],axis=1,join="inner")
                  
                  
 
                  gp['sn']=self.sn
                  gp['s6len1']=gp.s6len.shift(1) 
                  gp=gp.dropna(axis=0)  #drop the first row that is not really segment
                  
                  gp['s6len2']=gp.s6len.shift(2)
                  gp['s6len3']=gp.s6len.shift(3)
                  gp['s6len4']=gp.s6len.shift(4)
                  p6=peak_valley_pivots(np.array(db['c']),0.06,-0.06)
                  #segdrawdown: sdd6
                  s6sdd=compute_segment_returns(np.array(db['c']),p6)
                  #segdrawdown=np.insert(segdrawdown,0,0)
                  gp['s6sdd']=pd.Series(s6sdd,index=gp.index)
                  gp['s6sdd1']=gp.s6sdd.shift(1)
                  gp['s6sdd2']=gp.s6sdd.shift(2)
                  gp['s6sdd3']=gp.s6sdd.shift(3)
                  gp['s6sdd4']=gp.s6sdd.shift(4)
                  gp['s6g0']=gp.apply(lambda x:x.s6lastc if x.s6len>0 else x.s6startc,axis=1)
                  gp['s6d0']=gp.apply(lambda x:x.s6lastc if x.s6len<0 else x.s6startc,axis=1)
                  gp['s6startc1']=gp.s6startc.shift(1)
                  gp['s6startc2']=gp.s6startc.shift(2)
                  gp['s6startc3']=gp.s6startc.shift(3)
                  gp['s6startc4']=gp.s6startc.shift(4)
                  gp['s6lastc1']=gp.s6lastc.shift(1)
                  gp['s6lastc2']=gp.s6lastc.shift(2)
                  gp['s6lastc3']=gp.s6lastc.shift(3)
                  gp['s6lastc4']=gp.s6lastc.shift(4)
                  gp['s6g1']=gp.apply(lambda x :x.s6lastc1 if x.s6len1>0 else x.s6startc1,axis=1)
                  gp['s6d1']=gp.apply(lambda x :x.s6lastc1 if x.s6len1<0 else x.s6startc1,axis=1)
                  gp['s6g2']=gp.apply(lambda x :x.s6lastc2 if x.s6len2>0 else x.s6startc2,axis=1)
                  gp['s6d2']=gp.apply(lambda x :x.s6lastc2 if x.s6len2<0 else x.s6startc2,axis=1)                  
                  gp['s6g3']=gp.apply(lambda x :x.s6lastc3 if x.s6len3>0 else x.s6startc3,axis=1)
                  gp['s6d3']=gp.apply(lambda x :x.s6lastc3 if x.s6len3<0 else x.s6startc3,axis=1)                  
                  gp['s6g4']=gp.apply(lambda x :x.s6lastc4 if x.s6len4>0 else x.s6startc4,axis=1)
                  gp['s6d4']=gp.apply(lambda x :x.s6lastc4 if x.s6len4<0 else x.s6startc4,axis=1) 
                  # seg3 up seg seg2 down seg seg1 up seg seg current seg is also key entry               
                  gp['s6sumdmzu1']=gp.s6sumdmzu.shift(1) #down and zero 
                  gp['s6sumdmzd1']=gp.s6sumdmzd.shift(1)
                  gp['s6maxumzu1']=gp.s6maxumzu.shift(1)
                  gp['s6maxumzd1']=gp.s6maxumzd.shift(1)
                  gp['s6sumumzu1']=gp.s6sumumzu.shift(1) # up and zero 
                  gp['s6sumumzd1']=gp.s6sumumzd.shift(1)
                  gp['s6maxdmzu1']=gp.s6maxdmzu.shift(1)
                  gp['s6maxdmzd1']=gp.s6maxdmzd.shift(1) 
                  
                  gp['s6sumdmzu2']=gp.s6sumdmzu.shift(2)
                  gp['s6sumdmzd2']=gp.s6sumdmzd.shift(2)
                  gp['s6sumumzu2']=gp.s6sumumzu.shift(2)
                  gp['s6sumumzd2']=gp.s6sumumzd.shift(2)
                  gp['s6maxumzu2']=gp.s6maxumzu.shift(2)
                  gp['s6maxumzd2']=gp.s6maxumzd.shift(2)
                  gp['s6maxdmzu2']=gp.s6maxdmzu.shift(2)
                  gp['s6maxdmzd2']=gp.s6maxdmzd.shift(2) 
                                    
                  gp['s6sumdmzu3']=gp.s6sumdmzu.shift(3)
                  gp['s6sumdmzd3']=gp.s6sumdmzd.shift(3)
                  gp['s6maxdmzu3']=gp.s6maxdmzu.shift(3)
                  gp['s6maxdmzd3']=gp.s6maxdmzd.shift(3)
                  gp['s6startdate1']=gp.s6startdate.shift(1)
                  gp['s6startdate2']=gp.s6startdate.shift(2)
                  gp['s6startdate3']=gp.s6startdate.shift(3)
                  gp['s6startdate4']=gp.s6startdate.shift(4)
                 
                  gp['gpid6']=gp.index
                  
                  
                  #find the first gpid6 in every gpid
                  idx6=gp.groupby('gpid')['gpid6'].transform(min)==gp['gpid6']
                  gp6=gp[idx6][['gpid','s6sdd','s6startc','s6lastc']]
                  gp6.columns=['gpid','s6seg1sdd','s6seg1startc','s6seg1lastc']
                  gpn=pd.merge(gp,gp6 ,left_on='gpid',right_on='gpid')
                  return gpn      
      
      def sortgpid6(self,db):
            
            baseid=0
            for index,row in db.iterrows():
                  if row['gpid']==row['gpid6']:
                        baseid=row['id']
                        db.loc[index,'gp6no']=1
                  else:
                        db.loc[index,'gp6no']=row['id']-baseid+1
                  
                  
            return db             
   
                  
      def getgp(self):
            try:
                  db=self.getexdb()
                  #gp6=self.creatgp6(db)
                  gp13=self.creatgp13(db)
                  gp13['sn']=self.sn
                  
                  return gp13
            except:
                  #print('get gp failure')
                  return None
            
      CONf6=['sn','s13sdd','gp6no','s13sdd1','s6segs','s6startdate','s6sdd','s6sumdmzd','s6sumdmzu','s6sumumzd1','s6sumdmzu1']
      def getgp6(self):
            exdb=self.getexdb()
            gp6=self.creatgp6(exdb)
            #gp6['seg1dm']=gp6.apply(lambda x:'{s6sumdmzd1}-{s6sumdmzu1}'.format(**x),axis=1)
            gp13=self.creatgp13(exdb)
            
            gpn=pd.merge(gp6,gp13 ,left_on='gpid',right_on='gpid') 
            gpn['id']=gpn.index
            #gp['g12']=
            gpn=self.sortgpid6(gpn)
            gpn['gp6no1']=gpn.gp6no.shift(1)
            gpn['gp6no2']=gpn.gp6no.shift(2)
            gpn['gp6no3']=gpn.gp6no.shift(3)
            gpn['gpid1']=gpn.gpid.shift(1)
            gpn['gpid2']=gpn.gpid.shift(2)
            gpn['gpid3']=gpn.gpid.shift(3)
            return gpn
      def Level1(self,x):
            if (x.pronumredfr>x.curnumgrefr) and  (x.propowredfr>x.curpowgrefr) and (x.ppropowgrefr>x.propowredfr):
                  return 1
            elif (x.pronumredfr>x.curnumgrefr) and  (x.propowredfr>x.curpowgrefr):
                  return 2
            elif (x.ppropowgrefr>x.propowredfr) and (x.propowredfr>x.curpowgrefr):
                  return 3
            else :
                  return 0
      def Level2(self,x):
            if (-x.pprat>x.prat) and  (x.ppronumgrefr<x.pronumredfr):
                  return 1
            else :
                  return 0
      def Level5(self,x):
            if (x.ppgpid==x.pgpid) and (x.pgpid==x.cgpid):
                  return 's'
            else :
                  return 'd'
      CURRCONf=['sn','Level0','Level0data','s6startdate','pos','lastsdd','lastc','curno','currat','Level1data','Level1','Level2data','Level2','Level3data','Level3','Level4data','Level4','s6same']
      def indicator6(self):
            try:
                  #exdb=self.getexdb()
                  #gp=self.creatgp6(exdb)
                  gp=self.getgp6()
                  if gp is not None:
                        gp['nid']=pd.Series(range(len(gp)),index=gp.index)
                        
                        
                        #gp=gp.set_index('nid')
                        df=gp[(gp.s6sdd<0)&(gp.s6sumdmzd>gp.s6sumdmzu)&(gp.s6sumdmzu<3)
                               &(gp.s6sumumzu1<3)&(gp.s6sumumzd1>gp.s6sumumzu1)
                               #&(gp.s6maxdmzu3>gp.s6maxdmzd1)
                               #&(gp.s6sumzmzd>0)
                               ]
                        #df['g12']=df.apply(lambda x :max(x.s6g1,x.s6g2),axis=1) is not currect is use below
                        df.loc[:,'proh']=df.apply(lambda x:x.s6g1 if x.s6g1>x.s6g0 else x.s6g0,axis=1)
                        df.loc[:,'prol']=df.apply(lambda x:x.s6d1 if x.s6d1<x.s6d2 else x.s6d2,axis=1)
                        #suppose s6sdd1 is up and current is s6sdd is down
                        df.loc[:,'pronumredfr']=df['s6sumumzd1']
                        df.loc[:,'pronumredwa']=df['s6sumumzu1']
                        df.loc[:,'curnumgrefr']=df['s6sumdmzd']
                        df.loc[:,'curnumgrewa']=df['s6sumdmzu']
                        df.loc[:,'propowredfr']=df['s6maxumzd1'] #compose same state below zero line pronumredfr & curnumgrefr  propowredfr & curpowgrefr ppropowgrnfr & curpowfrnfr
                        df.loc[:,'curpowgrefr']=df['s6maxdmzd']
                        df.loc[:,'ppropowgrefr']=df['s6maxdmzd2']
                        df.loc[:,'ppronumgrefr']=df['s6sumdmzd2']
                        df.loc[:,'Level1']=df.apply(lambda x:1 if (x.s6sumumzd1>x.s6sumdmzd)&(x.s6maxumzd1>x.s6maxdmzd) else 0 ,axis=1)
                        df.loc[:,'pre13rat']=df['s13sdd1']
                        df.loc[:,'cur13rat']=df['s13sdd']
                        df.loc[:,'pre13segs']=df['s6segs1']
                        df.loc[:,'cur13segs']=df['s6segs']  
                        df=np.round(df,decimals=2)
                        df.loc[:,'Level0data']=df.apply(lambda x:'p13rat{pre13rat}[{s6segs1}],c13rat{cur13rat}'.format(**x),axis=1)
                        df.loc[:,'Level0']=df.apply(lambda x:1 if (x.pre13rat>0)&(x.pre13rat>=-x.cur13rat)&(x.pre13rat/2>(x.pre13rat+x.cur13rat)) else 0 ,axis=1)
                        df.loc[:,'Level1data']=df.apply(lambda x:'pow[{ppropowgrefr}-{propowredfr}-{curpowgrefr}]num[{ppronumgrefr}-{pronumredfr}-{curnumgrefr}]'.format(**x),axis=1)
                        df.loc[:,'Level1']=df.apply(self.Level1,axis=1)
                        df.loc[:,'pprat']=df['s6sdd2']
                        df.loc[:,'prat']=df['s6sdd1']
                        df.loc[:,'currat']=df['s6sdd']
                        df.loc[:,'Level2data']=df.apply(lambda x:'pow[{pprat},{prat},{currat}]num[{ppronumgrefr}-{pronumredfr}-{curnumgrefr}]'.format(**x),axis=1)
                        df.loc[:,'Level2']=df.apply(self.Level2,axis=1)
                        df.loc[:,'progp6no']=df['gp6no1']
                        df.loc[:,'curgp6no']=df['gp6no']
                        df.loc[:,'Level3data']=df.apply(lambda x:'rat[{prat},{currat}]gno[{progp6no}-{curgp6no}]'.format(**x),axis=1)
                        df.loc[:,'Level3']=df.apply(lambda x:1 if (x.progp6no==1)&(x.curgp6no==1) else 0,axis=1)
                        df.loc[:,'Level4data']=df.apply(lambda x:'h{proh}-c{s6d0},{s6d1}-l{prol}'.format(**x),axis=1)
                        df.loc[:,'Level4']=df.apply(lambda x:1 if (x.s6d0>=x.prol)&(x.s6d1>=x.prol) else 0 ,axis=1)
                        # current state
                        df.loc[:,'lastid']=gp[-1:]['nid'].values[0]
                        df.loc[:,'lastsdd']=gp[-1:]['s6sdd'].values[0]
                        df.loc[:,'lastc']=gp[-1:]['s6lastc'].values[0]
                        df.loc[:,'curno']=df['lastid']-df['nid']
                        df.loc[:,'currat']=df.apply(lambda x :x.lastc/x.prol-1 if x.lastc>x.prol else -x.lastc/x.prol,axis=1)
                        #df.iloc[-1,df.columns.get_loc('lastid')]=gp[-1:]['nid'].values[0]
                        #:wdf.loc[df.index[-1],'lastid']=gp[-1,]['nid']
                        df.loc[:,'s6w1']=df['s6len1']/5
                        df.loc[:,'s6w']=-df['s6len']/5
                        
                        df.loc[:,'ppgpid']=df['gpid2']
                        df.loc[:,'pgpid']=df['gpid1']
                        df.loc[:,'cgpid']=df['gpid']
                        df.loc[:,'s6same']=df.apply(self.Level5,axis=1)
                        df.loc[:,'pos']=df.apply(lambda x:'curr:{nid},last{lastid},pass{curno}'.format(**x),axis=1)
                        
                        
                        
                        return df[self.CURRCONf]
                        
            except:
                  pass

      #freeze below zero warm up zero
      MAINCONf=['sn','Level0','Level0data','s13sdd','s6segs','s6startdate','s6len','s6sdd','gp6no','progp6no','curgp6no','Level1data','Level1','Level2data','Level2','Level3data','Level3','Level4data','Level4','s6same']      
      def mainindicator6(self):
            #for gp6 the most import indicator is the seg1,seg2 and seg3 seg3 is down 
            # 1.s6sdd3>s6sdd1
            # 2.s6sdd1' sumdmzd1>sumdmzu1 and no sumdmzu1<2 
            # 3.s6sdd2>0' sumumzu<2 and sumumzd is main
            # 4.s6sdd3<0 sumdmzd3>sumdmzd1 that is time compare maxdmzu3>maxdmzu1 that is power compare
            # 5 s6sdd    sumumzd>sumdmzd
            try:
                  #exdb=self.getexdb()
                  #gp=self.creatgp6(exdb)
                  gp=self.getgp6()
                  if gp is not None:
                        #image s6sdd2 is up but it is below zero so sumumzd2>sumumzu2 
                        df=gp[(gp.s6sdd1<0)&(gp.s6sumdmzd1>gp.s6sumdmzu1)&(gp.s6sumdmzu1<3)
                               &(gp.s6sumumzu2<3)&(gp.s6sumumzd2>gp.s6sumumzu2)
                               #&(gp.s6maxdmzu3>gp.s6maxdmzd1)
                               #&(gp.s6sumzmzd>0)
                               ]
                        #df['g12']=df.apply(lambda x :max(x.s6g1,x.s6g2),axis=1) is not currect is use below
                        df.loc[:,'proh']=df.apply(lambda x:x.s6g1 if x.s6g1>x.s6g2 else x.s6g2,axis=1)
                        df.loc[:,'prol']=df.apply(lambda x:x.s6d2 if x.s6d2<x.s6d3 else x.s6d3,axis=1)
                        # suppose  s6sdd3 is down  s6sdd2 is up s6sdd1 is down 
                        df.loc[:,'pronumredfr']=df['s6sumumzd2']
                        df.loc[:,'pronumredwa']=df['s6sumumzu2']
                        df.loc[:,'curnumgrefr']=df['s6sumdmzd1']
                        df.loc[:,'curnumgrewa']=df['s6sumdmzu1']
                        df.loc[:,'propowredfr']=df['s6maxumzd2'] #compose same state below zero line pronumredfr & curnumgrefr  propowredfr & curpowgrefr ppropowgrnfr & curpowfrnfr
                        df.loc[:,'curpowgrefr']=df['s6maxdmzd1']
                        df.loc[:,'ppropowgrefr']=df['s6maxdmzd3']
                        df.loc[:,'ppronumgrefr']=df['s6sumdmzd3']
                        df.loc[:,'pre13rat']=df['s13sdd2']   # s6sdd2 is up so maybe it's in 
                        df.loc[:,'cur13rat']=df['s13sdd1']
                        df.loc[:,'pre13segs']=df['s6segs2']
                        df.loc[:,'cur13segs']=df['s6segs1']                        
                        
                        df=np.round(df,decimals=2)
                        df.loc[:,'Level0data']=df.apply(lambda x:'p13rat{pre13rat}[{pre13segs}],c13rat{cur13rat}[{cur13segs}]'.format(**x),axis=1)
                        df.loc[:,'Level0']=df.apply(lambda x:1 if (x.pre13rat>0)&(x.pre13rat>=-x.cur13rat)&(x.pre13rat/2>(x.pre13rat+x.cur13rat)) else 0 ,axis=1)
                        df.loc[:,'Level1data']=df.apply(lambda x:'pow[{ppropowgrefr}-{propowredfr}-{curpowgrefr}]num[{ppronumgrefr}-{pronumredfr}-{curnumgrefr}]'.format(**x),axis=1)
                        df.loc[:,'Level1']=df.apply(self.Level1,axis=1)
                        df.loc[:,'pprat']=df['s6sdd3']
                        df.loc[:,'prat']=df['s6sdd2']
                        df.loc[:,'currat']=df['s6sdd1']
                        df.loc[:,'Level2data']=df.apply(lambda x:'pow[{pprat},{prat},{currat}]num[{ppronumgrefr}-{pronumredfr}-{curnumgrefr}]'.format(**x),axis=1)
                        df.loc[:,'Level2']=df.apply(self.Level2,axis=1)
                        df.loc[:,'progp6no']=df['gp6no2']
                        df.loc[:,'curgp6no']=df['gp6no1']
                        df.loc[:,'Level3data']=df.apply(lambda x:'rat[{prat},{currat}]gno[{progp6no}-{curgp6no}]'.format(**x),axis=1)
                        df.loc[:,'Level3']=df.apply(lambda x:1 if (x.progp6no==1)&(x.curgp6no==1) else 0,axis=1)
                        df.loc[:,'Level4data']=df.apply(lambda x:'h{proh}-c{s6d0},{s6d1}-l{prol}'.format(**x),axis=1)
                        df.loc[:,'Level4']=df.apply(lambda x:1 if (x.s6d0>=x.prol)&(x.s6d1>=x.prol) else 0 ,axis=1)
                        df.loc[:,'ppgpid']=df['gpid3']
                        df.loc[:,'pgpid']=df['gpid2']
                        df.loc[:,'cgpid']=df['gpid1']
                        df.loc[:,'s6same']=df.apply(self.Level5,axis=1)
                        
                        return df[self.MAINCONf]
                        
            except:
                  pass
            
   
      CONf=['sn','s13startdate1','s13startdate','s13sdd4','s13sdd3','s13sdd2','s13sdd1','s13sdd','s13h3','s13h2','s13h1','s13len3','s13len2','s13len1','s13len','s13maxumzu1','s13maxumzd1','s13maxdmzu','s13maxdmzd','s13sumumzd1','s13sumumzu1','s13d4','s13d3','s13d2','s13d1','s13g4','s13g3','s13g2','s13g1','s6segs1','s13sddf1']
      def selftest(self):
            gp=self.getgp()
            #exdb=self.getexdb()
            #gp=self.creatgp13(exdb)
            gp['nid']=pd.Series(range(len(gp)),index=gp.index)
            gp=gp.set_index('nid')
            #df=gp[(gp.s6sdd<0)&(gp.um==1)]
            # 1.s1sdd1 standard: 1. both umzd1 and umzu1 and umzd1>umzu1 2.power maxumzu1>maxdmzu and maxdmzu>maxdmzd
            df=gp[((gp.s13g1<gp.s13g2)|(gp.s13g1<gp.s13g3))&(gp.s13sdd1>0)&(gp.s13sumumzu1>0)&(gp.s13sumumzd1>0)&(gp.s13sumumzd1>=gp.s13sumumzu1)&(gp.s13maxumzu1>gp.s13maxdmzu)&(gp.s13maxdmzu>gp.s13maxdmzd)]
            if len(df)>0:
                  gp1=gp.loc[df.index]
                  gp1['s13lenf1']=gp['s13len'].ix[df.index+1].values
                  gp1['s13sddf1']=gp['s13sdd'].ix[df.index+1].values
                  gp1['s6segsf1']=gp['s6segs'].ix[df.index+1].values
                  gp1['d02d1']=gp1.s13d0/gp1.s13d1
                  gp1['d02d2']=gp1.s13d0/gp1.s13d2
                  gp1['new2d0']=gp1.s13lastc/gp1.s13d0
                  gp1=np.round(gp1,decimals=2)
                  gp1['d123']=gp1.apply(lambda x:'{s13d1}:{s13d2}-{d02d1}:{d02d2}-{new2d0}'.format(**x),axis=1)
                  gp1['seg1']=gp1.apply(lambda x:'{s13len1}-{s6segs1}[{s13sdd1}]'.format(**x),axis=1)
                  gp1['seg0']=gp1.apply(lambda x:'{s13len}-{s6segs}[{s13sdd}]'.format(**x),axis=1)
                  gp1['segf']=gp1.apply(lambda x:'{s13lenf1}-{s6segsf1}[{s13sddf1}]'.format(**x),axis=1)
                  
                  return gp1.sort_values(by=['s13startdate'],ascending=True)[self.CONf]
            else:
                  return None
            
            
class STWTB(STDTB):

      def load(self):
            exdb=pd.read_csv(self.snpath,header=None,names=['date','o','h','l','c','v','m'])
            exdb.date=pd.to_datetime(exdb.date)
            exdb=exdb.set_index('date')
            wdb=exdb.resample('w').last()
            wdb.h=exdb.h.resample('w').max()
            wdb.o=exdb.o.resample('w').first()
            wdb.c=exdb.c.resample('w').min()
            wdb.v=exdb.v.resample('w').sum()
            #wdb=wdb[wdb.o.notnull()]
            wdb=wdb.dropna(axis=0) 
            wdb['id']=pd.Series(range(len(wdb)),index=wdb.index)
            wdb['date']=wdb.index
            
            self.db=wdb.set_index('id')
            self.db.date=pd.to_datetime(self.db.date)



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
                        if os.path.basename(path)[0:3]==pat and os.stat(path).st_size>4000 :#and os.path.basename(path)[0:8]=='SH600358':
                        #if os.path.basename(path)[0:5]=='SH600' and os.stat(path).st_size!=0: 
                              resultlist.append(path)
            return resultlist
      
       
      def save6(self,pat,yourtype='pass'):
            snlist=self.getallfile(ROOTPATH,pat)
            i=0
            j=0 
            result=pd.DataFrame()
            result1=pd.DataFrame()            
            gp=pd.DataFrame()
            for path in snlist:
                              dbcurrent=result
                              db1=result1
                              stobj=STDTB(path,'z')
                              if yourtype=='pass':
                                    gp=stobj.mainindicator6()    
                              else :
                                    gp=stobj.indicator6()
                              if gp is not None:
                                    try:
                                          result=dbcurrent.append(gp)
                                          result1=db1.append(gp.tail(1))
                                          i=i+1
                                    except:
                                          print(gp.sn)
                                          continue 
                              else:
                                    j=j+1                              
            if result.empty == False:
                  print("{}total:{} ,failure:{}".format(pat,i,j))
                  result.to_csv("gp6{}{}.csv".format(pat,yourtype))        
                  result1.to_csv("gp6{}{}last.csv".format(pat,yourtype))       
                  return result1                                    
                              
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
            
   
 
      
                                       

    
      def batfind(self,pat='SH6'):
            gp=pd.read_csv("gp{}zD.csv".format(pat))
            
            result=self.keyfind(gp)
            return result
           
      def batfindlast(self,pat): #findtype is mean use zigzag 
            gp=pd.read_csv("gp{}zDlast.csv".format(pat))
            result=gp[(gp.s6segsf1.isnull())]
            return result
  
            
            #return db[(db.lastdate==curdate)&(db.lastc>db.)][['startdate','sn','len','len1','segdrawdown','segdrawdown1','segdrawdown2']]
      CONt=['sn','s13startdate1','s13startdate','s13sdd','s6segs','s13lenf1','s13sddf1','s6segsf1','d123']
      def singlefind(self,sn):
            stobj=STDTB("{}{}.txt".format(ROOTPATH,sn))
            
            
            finddb=stobj.selftest()
            #wdb=stwobj.getexdb()
            
            return finddb

      # by selftest      
      def keyfind(self,gp):
            
            gp['nid']=pd.Series(range(len(gp)),index=gp.index)
            gp=gp.set_index('nid')
            #df=gp[(gp.s6sdd<0)&(gp.um==1)]
            df=gp[((gp.s13g1<gp.s13g2)|(gp.s13g1<gp.s13g3))&(gp.s13sdd1>0)&(gp.s13sumumzu1>0)&(gp.s13sumumzd1>0)&(gp.s13maxumzu1>gp.s13maxumzd1)]
            if len(df)>0:
                  gp1=gp.loc[df.index][['sn','s13startdate1','s13startdate','s13d0','s13d1','s13d2','s13sdd','s6segs','s13len','s13lastc']]
                  gp1['s13lenf1']=gp['s13len'].ix[df.index+1].values
                  gp1['s13sddf1']=gp['s13sdd'].ix[df.index+1].values
                  gp1['s6segsf1']=gp['s6segs'].ix[df.index+1].values
                  gp1['d02d1']=gp1.s13d0/gp1.s13d1
                  gp1['d02d2']=gp1.s13d0/gp1.s13d2
                  gp1['new2d0']=gp1.s13lastc/gp1.s13d0
                  
                  gp1=np.round(gp1,decimals=2)
                  gp1['d123']=gp1.apply(lambda x:'prod[{s13d1},{s13d2}]:lastd[{d02d1}:{d02d2}]:curd[{new2d0}]'.format(**x),axis=1)
            
                  return gp1[self.CONt]
           

              

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
 
      

