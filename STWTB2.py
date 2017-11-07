import pandas as pd
import numpy as np
import talib 
import csv
from talib import MA_Type
from zigzag import *
import os
ROOTPATH='/home/lib/mypython/export/'
class STWTB(object):

    def __init__(self,file):
        self.name='STWTB'
        if len(file)==8:
            self.sn=file[-6:]
            self.snpath="{}{}.txt".format(ROOTPATH,file)            
        else:
            self.sn=os.path.splitext(file)[0][-6:] 
            self.snpath=file
        
        self.load()

    def load(self):
        exdb=pd.read_csv(self.snpath,header=None,names=['date','o','h','l','c','v','m'])
        exdb.date=pd.to_datetime(exdb.date)
        exdb=exdb.set_index('date')
        wdb=exdb.resample('w').last()
        wdb.h=exdb.h.resample('w').max()
        wdb.o=exdb.o.resample('w').first()
        wdb.l=exdb.l.resample('w').min()
        wdb.v=exdb.v.resample('w').sum()
        #wdb=wdb[wdb.o.notnull()]
        wdb=wdb.dropna(axis=0) 
        wdb['id']=pd.Series(range(len(wdb)),index=wdb.index)
        wdb['date']=wdb.index

        self.db=wdb.set_index('id')
        self.db.date=pd.to_datetime(self.db.date)
        
  
    DBF=['date','c','k','d','j','segdown','segup','posmacd','macd','tmacd','angflag','kd','difup1']
    def getexdb(self):
        try:

            exdb=self.db
            #macd
            exdb['dif'],exdb['dea'],exdb['macd']=talib.MACD(np.array(exdb.c),10,20,6) 
            exdb=exdb.fillna(0)
            a=exdb[['macd','dif','dea']].values
            exdb['pos1']=np.where((a[:,0]>0) & (a[:,1]>0) & (a[:,2]>0),2,1)
            exdb['pos4']=np.where((a[:,0]<0) & ((a[:,1]>0) & (a[:,2]>0)),3,4)
            a=exdb[['macd','pos1','pos4']].values
            exdb['posmacd']=np.where(a[:,0]<0 ,a[:,2],a[:,1])
            #trix
            
            exdb['trixl']=talib.TRIX(np.array(exdb.c),12) 
            exdb['trixs']=talib.SMA(np.array(exdb.trixl),9)
            exdb=exdb.fillna(0)
            a=exdb[['trixl','trixs','posmacd']].values
            exdb['tmacd']= np.where(((a[:,0]>a[:,1])&(a[:,2]==1)),1,0)# exdb.apply(lambda x :1 if (x.trixl>=x.trixs)and (x.posmacd==1) else 0 ,axis=1)             
            exdb.loc[:,'id']=exdb.index
            exdb['k'],exdb['d']=talib.STOCH(np.array(exdb.h),np.array(exdb.l),np.array(exdb.c),9)
            exdb=exdb.fillna(0)
            exdb.loc[:,'j']=exdb.k*3-exdb.d*2
            a=exdb[['macd','id','k','d','posmacd','dif']].values
            exdb.loc[:,'segdown']= np.where(a[:,0]<0,a[:,1],0)   #exdb.apply(lambda x:x.id if (x.k<x.d)   else 0,axis=1)
            exdb.loc[:,'segup']= np.where(a[:,0]>0,a[:,1],0)   #exdb.apply(lambda x:x.id if (x.k>x.d)   else 0,axis=1)            
            exdb.loc[:,'kd']= np.where(a[:,2]>a[:,3],1,0)
            exdb.loc[:,'difup1']= np.where((a[:,4]==1)&(a[:,5]<0),a[:,1],0)   #posmacd==4 and dif>0 dea<0
            #exdb.loc[:,'trixang']=talib.LINEARREG_ANGLE(np.array(exdb.trixs),3)
            #exdb.loc[:,'trixangflag']=exdb.apply(lambda x :1 if x.trixang>0 else 0 ,axis=1)
            #exdb.loc[:,'seed']= exdb.apply(lambda x:1 if (x.j<x.k) and (x.j<x.d) and (x.k<x.d) and (x.tmacd==1) and (x.trixangflag==1)  else 0 ,axis=1)
            exdb.loc[:,'ang']= talib.LINEARREG_ANGLE(np.array(exdb.dif),3)
            exdb=exdb.fillna(0)
            a=exdb[['ang','id']].values
            exdb.loc[:,'angflag']=np.where(a[:,0]>0,1,0)  #exdb.apply(lambda x :1 if x.ang>0 else 0 ,axis=1) 
            exdb.loc[:,'ang1id']= np.where(a[:,0]>0,a[:,1],0)  #exdb.apply(lambda x :x.id if x.ang>0 else 0 ,axis=1)
            exdb.loc[:,'ang0id']= np.where(a[:,0]<0,a[:,1],0) #exdb.apply(lambda x :x.id if x.ang<0 else 0 ,axis=1)            
            exdb=np.round(exdb,decimals=2)
            cols=['segdown','segup','posmacd','kd','ang0id','ang1id','difup1']
            exdb[cols]=exdb[cols].applymap(np.int64)
            return exdb
        except:
            return None

  
    def keypos(self,x):
        return "{}-{}-{}".format(int(x.seedmod),int(x.changes),x.macdturn)

    def seed(self):
            db=self.getexdb()
        #try:
            lastdownid=db.max(axis=0)['segdown']
            lastupid=db.max(axis=0)['segup']
            lastdifup1id=db.max(axis=0)['difup1']
            _dbdown=db[(db.index==lastdownid)][['angflag','posmacd','id']]
            _dbdown.columns=['angdown','posmacddown','segdownid']
            _dbdown.loc[:,'newid']='1'
            _dbdown=_dbdown.set_index('newid')
            _dbup1=db[(db.index==lastupid)][['angflag','posmacd','id']]
            _dbup1.columns=['angup','posmacdup','segupid']
            _dbup1.loc[:,'newid']='1'
            _dbup1=_dbup1.set_index('newid')        
            gp= pd.concat([_dbdown,_dbup1],axis=1)
            gp['changes']=gp.apply(lambda x: int (x.segupid-x.segdownid) if x.segupid>x.segdownid else -int(x.segdownid-x.segupid),axis=1)
            gp['difturn']=gp.apply(lambda x: x.angdown if (x.segdownid>x.segupid) else x.angup,axis=1)
            cols=['posmacddown','posmacdup']
            gp[cols]=gp[cols].applymap(np.int64)
            if lastdownid>lastupid:  # if current is down
                gp['seedmod']=gp.apply(lambda x:'{posmacdup}{posmacddown}{difturn}'.format(**x),axis=1)
            else:
                gp['seedmod']=gp.apply(lambda x:'{posmacddown}{posmacdup}{difturn}'.format(**x),axis=1)
            gp['macdturn']=lastupid-lastdifup1id
            gp['keypos']=gp.apply(self.keypos,axis=1)
            
            gp['sn']=self.sn
            return gp
        #except:
            #return None
   
class STMTB(STWTB):
    def load(self):
        exdb=pd.read_csv(self.snpath,header=None,names=['date','o','h','l','c','v','m'])
        exdb.date=pd.to_datetime(exdb.date)
        exdb=exdb.set_index('date')
        wdb=exdb.resample('m').last()
        wdb.h=exdb.h.resample('m').max()
        wdb.o=exdb.o.resample('m').first()
        wdb.l=exdb.l.resample('m').min()
        wdb.v=exdb.v.resample('m').sum()
        #wdb=wdb[wdb.o.notnull()]
        wdb=wdb.dropna(axis=0) 
        wdb['id']=pd.Series(range(len(wdb)),index=wdb.index)
        wdb['date']=wdb.index

        self.db=wdb.set_index('id')
        self.db.date=pd.to_datetime(self.db.date)
