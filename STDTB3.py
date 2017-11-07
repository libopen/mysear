import pandas as pd
import numpy as np
import talib 
import csv
from talib import MA_Type
from zigzag import *
import os
ROOTPATH='/home/lib/mypython/export/'
class STDTB(object):

    def __init__(self,file):
        self.name='STDTB'
        if len(file)==8:
            self.sn=file[-6:]
            self.snpath="{}{}.txt".format(ROOTPATH,file)            
        else:
            self.sn=os.path.splitext(file)[0][-6:] 
            self.snpath=file
        
        self.load()


    def load(self):
        self.db=pd.read_csv(self.snpath,header=None,names=['date','o','h','l','c','v','m'])
        self.db.date=pd.to_datetime(self.db.date)

 

 
    
    
   
    DBF=['date','kd','segup','segdown','posmacd','macd','tmacd','difup1','ang','c','k','d']
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
            exdb['tmacd']= np.where(a[:,0]>a[:,1],1,0)# exdb.apply(lambda x :1 if (x.trixl>=x.trixs)and (x.posmacd==1) else 0 ,axis=1)             
            exdb.loc[:,'id']=exdb.index
            exdb['k'],exdb['d']=talib.STOCH(np.array(exdb.h),np.array(exdb.l),np.array(exdb.c),9)
            exdb=exdb.fillna(0)
            exdb.loc[:,'j']=exdb.k*3-exdb.d*2
            a=exdb[['tmacd','id','k','d','posmacd','dif']].values
            exdb.loc[:,'segup']  = np.where(a[:,0]>0,a[:,1],0)   #exdb.apply(lambda x:x.id if (x.k<x.d)   else 0,axis=1)
            exdb.loc[:,'segdown']= np.where(a[:,0]==0,a[:,1],0)   #exdb.apply(lambda x:x.id if (x.k>x.d)   else 0,axis=1)            
            exdb.loc[:,'kd']= np.where(a[:,2]<a[:,3],1,0)
            exdb.loc[:,'difup1']= np.where((a[:,4]==1)&(a[:,5]<0),a[:,1],0)   #posmacd==4 and dif>0 dea<0
            exdb.loc[:,'ang']= talib.LINEARREG_ANGLE(np.array(exdb.trixl),3)
            exdb=exdb.fillna(0)
            a=exdb[['ang','id']].values
            exdb.loc[:,'angflag']=np.where(a[:,0]>0,1,0 )   
           
            exdb=np.round(exdb,decimals=2)
            cols=['segup','segdown','posmacd','difup1']
            exdb[cols]=exdb[cols].applymap(np.int64)

            
            return exdb
        except:
            return None
     
    def keypos(self,x):
        return "{}-{}-{}".format(int(x.seedmod),int(x.changes),x.macdturn)    
    def getseed(self):
        db=self.getexdb()
        lastupid=db.max(axis=0)['segup']
        lastdownid=db.max(axis=0)['segdown']
        lastdifup1id=db.max(axis=0)['difup1']
        _dbup=db[(db.index==lastupid)][['angflag','posmacd','id','kd']]
        _dbup.columns=['angup','posmacdup','segupid','upkd']
        _dbup.loc[:,'newid']='1'
        _dbup=_dbup.set_index('newid')
        _dbdown=db[(db.index==lastdownid)][['angflag','posmacd','id','kd']]
        _dbdown.columns=['angdown','posmacddown','segdownid','downkd']
        _dbdown.loc[:,'newid']='1'
        _dbdown=_dbdown.set_index('newid')        
        gp= pd.concat([_dbdown,_dbup],axis=1)
        gp['changes']=gp.apply(lambda x: int (x.segupid-x.segdownid) if x.segupid>x.segdownid else -int(x.segdownid-x.segupid),axis=1)
        gp['difturn']=gp.apply(lambda x: x.angdown if (x.segdownid>x.segupid) else x.angup,axis=1)
        
        if lastupid>lastdownid :
            gp['seedmod']=gp.apply(lambda x:'{posmacddown}{posmacdup}{difturn}{upkd}'.format(**x),axis=1)
        else:
            gp['seedmod']=gp.apply(lambda x:'{posmacdup}{posmacddown}{difturn}{downkd}'.format(**x),axis=1)
        gp['macdturn']=lastupid-lastdifup1id
        gp['keypos']=gp.apply(self.keypos,axis=1)
        gp['sn']=self.sn
        return gp            
        
  