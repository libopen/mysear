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
      def poschange(self,x):
            if  (x.nextang1<0  and x.ang>0 and x.dif<0 and x.dea<0):
                  return x.id
            else:
                  return 99999 
      def poschangemacd(self,x):
            if (x.nextang1>0 and x.nextang2>0 and x.ang<0 ) or (x.nextang1<0 and x.nextang2<0 and x.ang>0):
                  return x.id
            else:
                  return 99999    
      def regroupmacd(self,db):
            curid=0
            for index,row in db.iterrows():
                  if row['trn']!=99999:
                        curid=row['trn']
                  db.loc[index,'gpid']=curid
            return db 
      def getmacdexdb(self):
            try:
                  self.load()
                  exdb=self.db
                  exdb['id']=exdb.index
                  exdb['dif'],exdb['dea'],exdb['macd']=talib.MACD(np.array(exdb.c),10,20,6) # change 
                  exdb['ang']= exdb.macd
                  exdb['nextang1']=exdb.ang.shift(1)
                  exdb['nextang2']=exdb.ang.shift(2)  
                  exdb['trn']=exdb.apply(self.poschangemacd,axis=1)
                  exdb['gpid']=0        
                  exdb['len']=exdb.apply(lambda x: 1 if x.ang>=0 else -1,axis=1)
                  return self.regroupmacd(exdb)
                  
            except:
                  pass      
            
      def creatmacdgp(self,db):
                        # group by gpid get sum of md and gpred
            if db.empty==False and len(db)>60:
                  gp1=db.groupby('gpid').max()[['c']]  # compare power？ angle或stddev
                  gp1.columns=['smaxc']
                  gp2=db.groupby('gpid').min()[['c']]
                  gp2.columns=['sminc']
                  gp22=db.groupby('gpid').sum()[['len']]
                  gp22.columns=['lenang']                  
                  gp24=db.groupby('gpid').count()[['len']]
                  gp24.columns=['lennum']
                  #gp23=db.groupby('gpid')
                  idx=db.groupby('gpid')['id'].transform(min)==db['id']
                  gp3=db[idx][['gpid','date','c']]
                  gp3.columns=['gpid','startdate','startc']
                  gp3=gp3.set_index('gpid')
                  idx2=db.groupby('gpid')['id'].transform(max)==db['id']
                  gp32=db[idx2][['gpid','date','c']]
                  gp32.columns=['gpid','lastdate','lastc']
                  gp32=gp32.set_index('gpid')
                  
                  gp=pd.concat([gp1,gp2,gp22,gp24,gp3,gp32],axis=1,join="inner")
                  #gp=pd.concat([gp,gp33],axis=1,join="inner")
                  #return gp33,gp
                  gp['len']=gp.apply(lambda x:x.lennum if x.lenang>0 else -x.lennum,axis=1)
                  gp['len1']=gp.len.shift(1)
                  gp['len2']=gp.len.shift(2)
                  gp['len3']=gp.len.shift(3)
                  
                 
                  
                  gp['peakc']=gp.apply(lambda x: x.smaxc if x.len>0 else x.sminc ,axis=1) # if len>0 minc is the provious minc if len<0 minc is isself
                  gp['peakc1']=gp.peakc.shift(1)
                  gp['peakc2']=gp.peakc.shift(2)
                  gp['peakc3']=gp.peakc.shift(3)
                            
                  gp['sn']=self.sn
                  gp['gpid']=gp.index
                  #future 
                  gp['fupeakc1']=gp.peakc.shift(-1)
                  gp['fulen1']=gp.len.shift(-1)
                  gp['fupeakc2']=gp.peakc.shift(-2)
                  gp['fulen2']=gp.len.shift(-2)
                  return gp                    
      def getexdb(self):
            try:
                  self.load()
                  exdb=self.db
                  exdb['dif'],exdb['dea'],exdb['macd']=talib.MACD(np.array(exdb.c),10,20,6) # change
                  exdb['ang']= exdb.macd
                  exdb['nextang1']=exdb.ang.shift(1)
                  exdb['id']=exdb.index
                  exdb['trn']=exdb.apply(self.poschange,axis=1)
                  exdb['trnc']=exdb.apply(lambda x:x.c if x.trn==1 else 0 ,axis=1)
                  exdb['dmacd']=exdb.apply(lambda x:-x.macd if x.macd<0 else 0 ,axis=1)
                  exdb['umacd']=exdb.apply(lambda x:x.macd if x.macd>0 else 0 ,axis=1)
                  exdb['dm']=exdb.apply(lambda x:1 if x.macd<0 else 0 ,axis=1)
                  exdb['um']=exdb.apply(lambda x:1 if x.macd>0 else 0 ,axis=1)
                  exdb['rat']=exdb.apply(lambda x: x.h/x.l-1 if (x.c<x.o)&(x.h/x.c>1.05)&(x.o/x.c>1.05) else 0 ,axis=1)
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
                  exdb['s6id']=exdb.id-exdb.gpid6+1
                  exdb['s13id']=exdb.id-exdb.gpid+1
                  
                  return exdb
            except:
                  pass
                  #print (self.sn)
         
 

      
            
            
      def creatgp(self,db):
                  # group by gpid get sum of md and gpred
            if db.empty==False and len(db)>60:
                  gp22=db.groupby('gpid').sum()[['z13mode']]
                  gp22.columns=['len']
                  #gp23=db.groupby('gpid')
                  idx=db.groupby('gpid')['id'].transform(min)==db['id']
                  gp3=db[idx][['gpid','date','h','l','o','c','v'                              ]]
                  gp3.columns=['gpid','startdate','starth','startl','starto','startc','startv']
                  gp3=gp3.set_index('gpid')
                  idx2=db.groupby('gpid')['id'].transform(max)==db['id']
                  gp32=db[idx2][['gpid','date','l','c']]
                  gp32.columns=['gpid','lastdate','lastl','lastc']
                  gp32=gp32.set_index('gpid')
                  gp6=db.groupby('gpid').gpid6.nunique()
                  
                  gp=pd.concat([gp22,gp3,gp32,gp6],axis=1,join="inner")
                  #gp=pd.concat([gp,gp33],axis=1,join="inner")
                  #return gp33,gp
                  gp['sn']=self.sn
                  gp['len1']=gp.len.shift(1) 
                  gp=gp.dropna(axis=0)  #drop the first row that is not really segment
                  
                  gp['len2']=gp.len.shift(2)
                  gp['len3']=gp.len.shift(3)
                  
                  p13=peak_valley_pivots(np.array(db['c']),0.13,-0.13)
                  segdrawdown=compute_segment_returns(np.array(db['c']),p13)
                  #segdrawdown=np.insert(segdrawdown,0,0)
                  gp['segdrawdown']=pd.Series(segdrawdown,index=gp.index)
                  gp['segdrawdown1']=gp.segdrawdown.shift(1)
                  gp['segdrawdown2']=gp.segdrawdown.shift(2)
                  gp['startc1']=gp.startc.shift(1)
                  gp['startc2']=gp.startc.shift(2)
                  gp['lastc1']=gp.lastc.shift(1)
                  gp['lastc2']=gp.lastc.shift(2)

                 
 
                  return gp  
 
            
      def creatgp13(self,db):
                  # group by gpid get sum of md and gpred
            if db.empty==False and len(db)>60:
                  gp22=db.groupby('gpid').sum()[['z13mode','dm','um']]
                  gp22.columns=['s13len','s13sumdmacd','s13sumumacd']
                  gp23=db.groupby('gpid').max()[['dmacd','umacd']]
                  gp23.columns=['s13maxdmacd','s13maxumacd']
                  
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
                  gp['s6segs1']=gp.s6segs.shift(1)
                  gp['s6segs2']=gp.s6segs.shift(2)
                  gp['s6segs3']=gp.s6segs.shift(3)
                  gp['s6segs4']=gp.s6segs.shift(4)
                  gp['s13sumdmacd1']=gp.s13sumdmacd.shift(1)
                  gp['s13sumdmacd2']=gp.s13sumdmacd.shift(2)
                  gp['s13sumdmacd3']=gp.s13sumdmacd.shift(3)
                  gp['s13sumdmacd4']=gp.s13sumdmacd.shift(4)
                  gp['s13sumumacd1']=gp.s13sumumacd.shift(1)
                  gp['s13sumumacd2']=gp.s13sumumacd.shift(2)
                  gp['s13sumumacd3']=gp.s13sumumacd.shift(3)
                  gp['s13sumumacd4']=gp.s13sumumacd.shift(4)
                  gp['s13maxumacd1']=gp.s13maxumacd.shift(1)
                  gp['s13maxumacd2']=gp.s13maxumacd.shift(2)
                  gp['s13maxumacd3']=gp.s13maxumacd.shift(3)
                  gp['s13maxumacd4']=gp.s13maxumacd.shift(4)
                  gp['s13maxdmacd1']=gp.s13maxdmacd.shift(1)
                  gp['s13maxdmacd2']=gp.s13maxdmacd.shift(2)
                  gp['s13maxdmacd3']=gp.s13maxdmacd.shift(3)
                  gp['s13maxdmacd4']=gp.s13maxdmacd.shift(4)
                  gp['s13startdate1']=gp.s13startdate.shift(1)
                  gp['s13startdate2']=gp.s13startdate.shift(2) 
                  gp['s13startdate3']=gp.s13startdate.shift(3)
                  gp['s13startdate4']=gp.s13startdate.shift(4)
                  gp['s13startdate5']=gp.s13startdate.shift(5)
                  gp['s13startdate6']=gp.s13startdate.shift(6)                  
                  gp['gpid']=gp.index
                  return gp        
            
 
                  
      def creatgp6(self,db):
                  # group by gpid get sum of md and gpred
            if db.empty==False and len(db)>60:
                  gp22=db.groupby('gpid6').sum()[['z6mode','dm','um']]
                  gp22.columns=['s6len','s6sumdmacd','s6sumumacd'] #len6 :seg6 
                  #gp23=db.groupby('gpid')
                  gp23=db.groupby('gpid6').max()[['dmacd','umacd']]
                  gp23.columns=['s6maxdmacd','s6maxumacd']                  
                  gp24=db.groupby('gpid6').min()[['c',]]
                  gp24.columns=['s6minc']                  
                  idx=db.groupby('gpid6')['id'].transform(min)==db['id']
                  gp3=db[idx][['gpid6','date','c']]
                  gp3.columns=['gpid6','s6startdate','s6startc']
                  gp3=gp3.set_index('gpid6')
                  idx2=db.groupby('gpid6')['id'].transform(max)==db['id']
                  gp32=db[idx2][['gpid6','date'     ,'c'      ,'gpid','s6id','dm','um','dmacd']]
                  gp32.columns=['gpid6','s6lastdate','s6lastc','gpid','s6id','dm','um','s6lastdmacd']
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
                  gp['s6sumdmacd1']=gp.s6sumdmacd.shift(1)
                  gp['s6sumdmacd2']=gp.s6sumdmacd.shift(2)
                  gp['s6sumdmacd3']=gp.s6sumdmacd.shift(3)
                  gp['s6sumdmacd4']=gp.s6sumdmacd.shift(4)
                  gp['s6sumumacd1']=gp.s6sumumacd.shift(1)
                  gp['s6sumumacd2']=gp.s6sumumacd.shift(2)
                  gp['s6sumumacd3']=gp.s6sumumacd.shift(3)
                  gp['s6sumumacd4']=gp.s6sumumacd.shift(4)
                  
                  gp['s6maxdmacd1']=gp.s6maxdmacd.shift(1)
                  gp['s6maxdmacd2']=gp.s6maxdmacd.shift(2)
                  gp['s6maxdmacd3']=gp.s6maxdmacd.shift(3)
                  gp['s6maxdmacd4']=gp.s6maxdmacd.shift(4)
                  gp['s6maxumacd1']=gp.s6maxumacd.shift(1)
                  gp['s6maxumacd2']=gp.s6maxumacd.shift(2)
                  gp['s6maxumacd3']=gp.s6maxumacd.shift(3)
                  gp['s6maxumacd4']=gp.s6maxumacd.shift(4)
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
      def moduleL (self,x):
            if (x.s6sdd4>0 and x.s6sdd4>-x.s6sdd3 and x.s6sdd2<x.s6sdd4 and x.s6g2<x.s6g4 and x.s6d3>x.s6d5): # 
                  return 'DL' # 厂 shape maybe it is the top
            # 这里不能使用abs 
            elif (x.s6sdd4<0 and -x.s6sdd4 >x.s6sdd3 and -x.s6sdd2<x.s6sdd3 and x.s6g5>x.s6g3 and x.s6d4<x.s6d2 ):
                  return 'L'  # L shape
            else:
                  return 'N'  
                  
      def getgp(self):
            try:
                  db=self.getexdb()
                  gp6=self.creatgp6(db)
                  gp13=self.creatgp13(db)
                  gpn=pd.merge(gp6,gp13 ,left_on='gpid',right_on='gpid')
                  gpn['id']=gpn.index
                  gpn['s6equkey']=gpn.apply(lambda x: 1 if (x.s6sdd2>0)&(x.s6sdd1<0)&(x.s6d1>x.s6d3)&(x.s6d1<x.s6d3*1.02) else 0,axis=1)
                  gpn['s13equkey']=gpn.apply(lambda x: 1 if (x.s13sdd2>0)&(x.s13sdd1<0)&(x.s13d1>x.s13d3)&(x.s13d1<x.s13d3*1.02) else 0,axis=1)
                  #gpn['ml0']=gpn.apply(self.moduleL,axis=1)
                  #gpn['ml1']=gpn.ml0.shift(1)
                  #gpn['ml2']=gpn.ml0.shift(2)
                  
 
                  
                  
                  
                  gpn=self.sortgpid6(gpn)                     
                  gpn['gp6no1']=gpn.gp6no.shift(1)
                  gpn['gp6no2']=gpn.gp6no.shift(2)
                  gpn['gp6no3']=gpn.gp6no.shift(3)
                  gpn['gp6no4']=gpn.gp6no.shift(4)
                  return gpn
            except:
                  #print('get gp failure')
                  return None
            
      def getmergegp(self):
            try:
                  gp=self.getgp()
                  if gp is not None :
                        mdb=self.getmacdexdb()
                        mgp=self.creatmacdgp(mdb)[['gpid','len','fulen1','peakc','fupeakc1','startdate']]                 
                        
                        gpm=pd.merge(gp,mgp,how='left',left_on='s13mintrn',right_on='gpid')
                        return gpm.fillna(0)
                  else:
                        return None
            except:
                  return None
            
      def getgpbyno(self,refid):
            db=self.getexdb()
            gp=self.creatgp(db)
            return gp[gp.index>=refid][['len','minc','maxc','len1']].head()
      def mainstream(self):
            try:
                  gp=self.getgp()
                  if gp is not None:
                        gp1=gp[(gp.s6segs>3)&(gp.s13sdd>0)&(gp.gp6no==1)][['s13startdate','s13sdd','gpid','s6segs','s6d0','s6g0']]
                        gp2=gp[(gp.s6segs>3)&(gp.s13sdd>0)&(gp.gp6no==2)][['gpid','s6d0','s6g0']]
                        gp1.columns=['s13startdate','s13sdd','gpid1','s6seg2','s1d','s1g']
                        gp2.columns=['gpid2','s2d','s2g']
                         
                        df=pd.merge(gp1,gp2,left_on='gpid1',right_on='gpid2')
                        return df
            except:
                  pass
            
      def findbyumdm(self):
            gp=self.getgp()
            #df=gp[(gp.s6sdd<0)&(gp.s6sumumacd>gp.s6sumdmacd)][['s6startdate','s6sumdmacd','s6sumumacd','s6um','s6dm','s6len','s6sdd']]
            df=gp[(gp.s6sdd3<0)&(gp.s6sdd3.abs()>gp.s6sdd2.abs()*1.05)&(gp.s6sumumacd2>gp.s6sumdmacd1)]
            
            gp1=gp.loc[df.index][['s6startdate','s6sdd3','s6sdd2','s6sdd1','s6sdd','s6d3','s6g3','s6g2','s6d2','s6g1','s6d1','s6d0','s6g0','s6sumumacd2','s6sumdmacd1','s6sumumacd','s6sumdmacd']]
            gp1['s6sddf1']=gp['s6sdd'].ix[df.index+1].values
            gp1['s6d0f1']=gp['s6d0'].ix[df.index+1].values
            gp1['d123']=gp1.apply(lambda x:'d3[{s6d3}]:d2[{s6d2}]:d1[{s6d1}]'.format(**x),axis=1)
            gp1['s2lts3']=gp1.apply(lambda x:1 if x.s6sdd2<-x.s6sdd3 else 0,axis=1)
            gp1['d0gtd2']=gp1.apply(lambda x: 1 if (x.s6d1>x.s6d2)|(x.s6d1>x.s6d3) else 0,axis=1)
            
            gp1=np.round(gp1,decimals=2)
            return gp1[['s6sdd3','s6sdd','d123','s2lts3','d0gtd2']]

      def selftest(self):
            gp=self.getgp()
            #df=gp[(gp.s6sdd<0)&(gp.um==1)]
            df=gp[(gp.s6sdd<0)&(gp.s6sumdmacd1>(gp.s6sumumacd1+gp.s6sumumacd))&(gp.s6maxdmacd1>gp.s6maxdmacd)&(gp.s6maxdmacd1>gp.s6maxumacd1)]
            gp1=gp.loc[df.index][['s13sdd','s6segs','s6startdate','s6sdd','s6id','um','dm','s6len','s6sdd1','s6sdd2','s6sdd3']]
            gp1['s6len1']=gp['s6len'].ix[df.index+1].values
            gp1['s6sdd0']=gp['s6sdd'].ix[df.index+1].values
            gp1=np.round(gp1,decimals=2)
            return gp1.sort_values(by=['s6sdd0'],ascending=True)[['s13sdd','s6segs','s6startdate','s6sdd3','s6sdd2','s6sdd1','s6sdd','s6sdd0']]
            
            
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
                      
      #no use       
      def seg4(self):
            gp=pd.read_csv('gpSH6zD.csv')
            #df=gp[(gp.s13len2>0)&(gp.s13len1<0)&(gp.s6segs1==3)&(gp.s13d1>gp.s13d2)][['s13len','sn','s13sdd','s13len1','s13len2','s13sdd1','s13sdd2','s13startdate','s13g0','s13g2']]
            #df=gp[(gp.s6len4<0)&(gp.s6d2<gp.s6d4)&(gp.s6dmacd4>gp.s6dmacd2)][['sn','s6startdate','s6len4','s6len3','s6len2','s6sdd4','s6sdd1','s6sdd3','s6d4','s6d3','s6d2','s6d1','s6g4','s6g3','s6g2','s6g1']]
            df=gp[(gp.s13sdd4>0)&(gp.s13sdd4>0.5)
                  &(gp.s13sdd3<-0.2)&(gp.s6segs3>=3)&(gp.s13sdd3>-0.5)&(gp.s13d3>gp.s13d4) # line3 is 3 segs  
                  &(gp.s13sdd2>0.1)&(gp.s13g2<gp.s13g4) #line2 only 1 segs 
                  #&(gp.s13umacd2>gp.s13dmacd1)
                  &(gp.s13dmacd3.abs()>gp.s13dmacd1.abs())
                  &(gp.s13d1>gp.s13d3)][['s13sdd','sn','s13startdate','s6segs']]
            return df.sort_values(by=['s13sdd'],ascending=True)
            
      def bigperiod(self,pat,cyctype='W',angtype='m'):
                  snlist=self.getallfile(ROOTPATH,pat)
                  result=pd.DataFrame()
                  i=0
                  for path in snlist:
                        dbcurrent=result
                        if cyctype=='D':
                              stobj=STDTB(path,angtype)
                        else:
                              stobj=STWTB(path,angtype)
                        gp = stobj.mainstream()
                        if gp is not None:
                                    try:
                                          result=dbcurrent.append(gp)
                                          i=i+1
                                    except:
                                          print(a.sn)
                                          continue
                        
                        #if i>3:
                              #break
                  if result.empty == False:
                        print("total:{}".format(i))
                        #result.to_csv("bp{}{}{}.csv".format(pat,angtype,cyctype)) 
                        df1=result.groupby('date').sum()[['up','do']]
                        df1['per']=df1.up/df1.do
                        print(df1[df1.index.year>=2016].to_csv(sep='\t'))
                        return result
      
      def bigperiodsn(self,sn,angtype='m'):
            s=STDTB(sn, angtype)
            sw=STWTB(sn,angtype)
            sdb=s.getexdb()[['date','wdate','gpid','h','c']]
            sdb.columns=[['ddate','wdate','dgpid','dh','dc']]
            gp=s.getgp()[['gpid','len','len1','len2','len3']]
            
            
            #sdb=sdb.set_index('gpid')
            df1=pd.merge(sdb,gp,left_on='dgpid',right_on='gpid')
            wdb=sw.getexdb()[['date','gpid']]
            wdb.columns=['wdate','wgpid']
            df2=pd.merge(df1,wdb,left_on='wdate',right_on='wdate')
            wgp=sw.getgp()[['gpid','len','len1','len2']]
            wgp.columns=[['wgpid','wlen','wlen1','wlen2']]
            df3=pd.merge(df2,wgp,left_on='wgpid',right_on='wgpid')
            
            return df3
      
      
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
                        #stwobj=STWTB(path,angtype)
                        #gpd=stobj.getgp()
                        #wdb=stwobj.getexdb()
                        #if wdb is None:
                        #      continue
                        #w=wdb[['date','tmacd']]
                        #w.columns=[['wdate','wtmacd']] 
                        #try:
                        #      gp=pd.merge(w,gpd ,left_on='wdate',right_on='lastwdate')
                        #except:
                        #      continue
                        gp=stobj.getgp()
                        #gp=stobj.getmergegp()
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
            
   
 
      
                                       

      def batfindlast1(self,sortfield='s13len1'):
          gp=pd.read_csv('gpSH6zDlast.csv')
          find=gp[(gp.s13sdd1<-0.35)&(gp.s13sdd>0)][['sn','s13startdate','s6segs','s13sdd1','s13sdd','s6sdd','s6seg1sdd','s6seg1lastc','s6seg1startc','s13lastc']]
          find=np.round(find,decimals=2)
          find['curpos']=find.apply(lambda x:'L:{s6seg1startc}-c:{s13lastc}-H{s6seg1lastc})'.format(**x),axis=1)            
          find['currat']=(find.s13lastc-find.s6seg1startc)/(find.s6seg1lastc-find.s6seg1startc)
          #return find.sort_values(by=['s13len1','s13sdd1'],ascending=True)
          return find[['sn','s13startdate','s6segs','s13sdd1','s13sdd','s6sdd','s6seg1sdd','s13lastc','curpos','currat']]
    
      def batfind(self,pat,findtype='t',cyctype='D'):
            gp=pd.read_csv("gp{}{}{}.csv".format(pat,'z',cyctype))
            df=gp[(gp.s6sdd<0)&(gp.um==1)]
           # if findtype=='t':
            result=self.keyfindt(gp)
            #if result.empty==False:
                  #self.statics(result)	
            #cur=datetime.datetime.now().strftime('%Y-%m-01')
            return result
           
      def batfindlast(self,pat,findtype='z',cyctype='D'): #findtype is mean use zigzag 
            gp=pd.read_csv("gp{}{}{}last.csv".format(pat,findtype[0],cyctype))
            df= gp[(gp.s6sdd3>0)&(gp.s6sdd3>gp.s6sdd2.abs())&(gp.s6sdd3>gp.s6sdd1)&(gp.s6sdd3>gp.s6sdd.abs())&(gp.s6maxdmacd2>gp.s6maxdmacd)&(gp.s6sdd<0)&(gp.um==1)]#[['s6startdate','s13startdate','s6len','s13sdd','s6sdd','sn','gp6no','s6sumdmacd','s6sumumacd']]
            df['d123']=df.apply(lambda x:'d3[{s6d1}]:d2[{s6lastc}]:d1[{s6d0}]'.format(**x),axis=1)
            df['ud']=df.apply(lambda x:'d[{s6sumdmacd}]:u[{s6sumumacd}]:d1[{s6sumdmacd1}]:u1[{s6sumumacd1}]'.format(**x),axis=1)
            return df[['s13startdate','s6startdate','s13sdd','d123','sn','gp6no']]
  
            
            #return db[(db.lastdate==curdate)&(db.lastc>db.)][['startdate','sn','len','len1','segdrawdown','segdrawdown1','segdrawdown2']]
      CONt=['sn','s6startdate','s6sdd3','s6sddf1']
      def singlefind(self,sn,findtype='t'):
            stobj=STDTB("{}{}.txt".format(ROOTPATH,sn),findtype[0])
            stwobj=STWTB("{}{}.txt".format(ROOTPATH,sn),findtype[0])
            #week obj?
            gp=stobj.getgp()
            
            
            finddb=self.keyfindt(gp)
            #wdb=stwobj.getexdb()
            
            return finddb[self.CONt]
      def keyfindt(self,gp):
            # s13 : 1: cur down   cursdd <s13sdd1  cur have 3 s6segs   
            #df=gp[(gp.s6sdd3<0)&(gp.s6sdd3.abs()>gp.s6sdd2.abs())&(gp.s6sumumacd2>gp.s6sumdmacd1)]
            #df=gp[(gp.s6sdd3<0)&(gp.s6sdd3.abs()>gp.s6sdd2.abs()*1.05)&(gp.s6sumumacd2>(gp.s6sumdmacd1+gp.s6sumdmacd2))]
            df=gp[(gp.s6sdd3>0)&(gp.s6sdd3>gp.s6sdd2.abs())&(gp.s6sdd3>gp.s6sdd1)&(gp.s6sdd3>gp.s6sdd.abs())&(gp.s6maxdmacd2>gp.s6maxdmacd)]
            gp1=gp.loc[df.index][['sn','s6startdate','s6sdd3','s6sdd2','s6sdd1','s6sdd','s6d3','s6g3','s6g2','s6d2','s6g1','s6d1','s6d0','s6g0','s6sumumacd2','s6sumdmacd1','s6sumumacd','s6sumdmacd']]
            gp1['s6sddf1']=gp['s6sdd'].ix[df.index+1].values
            gp1['s6d0f1']=gp['s6d0'].ix[df.index+1].values
            #gp1['d123']=gp1.apply(lambda x:'d3[{s6d3}]:d2[{s6d2}]:d1[{s6d1}]'.format(**x),axis=1)
            gp1['d123']=gp1.s6d1/gp1.s6d3
            gp1['entrylo']=gp1.apply(lambda x: 'ind2' if (x.s6d1>x.s6d2)|(x.s6d1>x.s6d3) else 'outd2',axis=1)
            gp1['entryhi']=gp1.apply(lambda x: 'ing2' if (x.s6g0<x.s6g2)|(x.s6g0<x.s6g1) else 'outg2',axis=1)
            gp1['entryum']=gp1.apply(lambda x:'ltum2' if (x.s6sumumacd<x.s6sumumacd2) else 'gtum2',axis=1)
            gp1=np.round(gp1,decimals=2)
            return gp1[self.CONt]

            
           
      def fustatics(self,df):
            # begin the startc that is not the most lower point the lowest
            print("success fumaxc2 below minc   rate:{}".format(df[df.fumaxc2<df.minc]['sn'].count()/df.sn.count()))
            print("success fumaxc2 higher starto  rate:{}".format(df[df.fumaxc2>=df.starto]['sn'].count()/df.sn.count()))
            print("success fumaxc2 higher fuminc1  rate:{}".format(df[df.fumaxc2>=df.minc]['sn'].count()/df.sn.count()))

      def statics(self,pat,curdate):
            df['startdate']=pd.to_datetime(df['startdate'],format='%Y-%m-%d')
      
            print ("total:")
            for i in [3,5,10]:
                  print("success {} rate:{}".format(i,round(float(df[df.segdrawdown>i]['sn'].count()/df.sn.count()),3)))
            
            #print("furture 10 rate:{}".format(df[(df.rat<3)&(df.furrat2>10)]['sn'].count()/df[(df.rat<3)]['sn'].count()))
            for myyear in [2014,2015,2016,2017]:
                  print ("{}:{}".format(myyear,df[(df.startdate.dt.year==myyear)].sn.count()))
                  for i in [3,5,10]:
                        print("success {} rate:{}".format(i,round(float(df[(df.segdrawdown>=i)&(df.startdate.dt.year==myyear)]['sn'].count()/df[df.startdate.dt.year==myyear].sn.count()),3)))
                  
  
            find1=pd.DatetimeIndex(df.startdate).to_period("M")
            gp=df.sn.groupby(find1).count()
            print(gp[gp.index>'2014-1-1'].to_csv(sep='\t'))
            

def main():
    #main1()
      #dofindsh6(findtype='a1')
      #dofindsh6(findtype='m4')
      
      a=ANALYSIS()
      a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2],usemyfind=sys.argv[3])
      #if (sys.argv[2]=='t'):
            #a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2],cyctype='W')
      

if __name__=="__main__":
      main()
 
      

