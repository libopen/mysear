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

    def addload(self):
        exdb=self.db
        exdb['dif'],exdb['dea'],exdb['macd']=talib.MACD(np.array(exdb.c),10,20,6) 
        exdb['k'],exdb['d']=talib.STOCH(np.array(exdb.h),np.array(exdb.l),np.array(exdb.c),9)
        exdb.loc[:,'j']=exdb.k*3-exdb.d*2
        exdb['sma20']=talib.SMA(np.array(exdb.c),20)
        exdb['sma55']=talib.SMA(np.array(exdb.c),55)
        exdb['trixl']=talib.TRIX(np.array(exdb.c),12) 
        exdb['trixs']=talib.SMA(np.array(exdb.trixl),9)
        exdb=exdb.fillna(0)
        #macd
        a=exdb[['macd','dif','dea']].values
        exdb['pos1']=np.where((a[:,0]>0) & (a[:,1]>0) & (a[:,2]>0),2,1)
        exdb['pos4']=np.where((a[:,0]<0) & ((a[:,1]>0) & (a[:,2]>0)),3,4)
        a=exdb[['macd','pos1','pos4']].values
        exdb['posmacd']=np.where(a[:,0]<0 ,a[:,2],a[:,1])
        a=exdb[['trixl','trixs']].values
        exdb['tmacd']= np.where(a[:,0]>a[:,1],1,0)# exdb.apply(lambda x :1 if (x.trixl>=x.trixs)and (x.posmacd==1) else 0 ,axis=1)             
      
        exdb.loc[:,'id']=exdb.index  
        a=exdb[['id','k','d']].values        
        exdb.loc[:,'kdup']  = np.where(a[:,1]>a[:,2],a[:,0],0)   #exdb.apply(lambda x:x.id if (x.k<x.d)   else 0,axis=1)
        exdb.loc[:,'kddown']= np.where(a[:,1]<=a[:,2],a[:,0],0)   #exdb.apply(lambda x:x.id if (x.k>x.d)   else 0,axis=1)            
        a=exdb[['c','sma20','sma55']].values
        exdb.loc[:,'segdown20']= np.where((a[:,0]>=a[:,1]),1,0)
        exdb.loc[:,'segdown55']= np.where((a[:,0]>=a[:,2]),1,0)

        self.db=exdb        
    def load(self):
        self.db=pd.read_csv(self.snpath,header=None,names=['date','o','h','l','c','v','m'])
        self.db.date=pd.to_datetime(self.db.date)
        self.addload()
    #DBF=['date','c','k','d','j','segdown','segup','posmacd','macd','tmacd','angflag','kd']
    DBF=['date','kdup','kddown','segup','segdown','posmacd','macd','tmacd','ang','angflag','c','segdown55']
    def getexdb(self):
        try:
  
            exdb=self.db
            #trix
            a=exdb[['tmacd','id']].values
            exdb.loc[:,'segup']  = np.where(a[:,0]>0,a[:,1],0)   #exdb.apply(lambda x:x.id if (x.k<x.d)   else 0,axis=1)
            exdb.loc[:,'segdown']= np.where(a[:,0]==0,a[:,1],0)   #exdb.apply(lambda x:x.id if (x.k>x.d)   else 0,axis=1)            
            cols=['segdown','segup','posmacd','segdown20','segdown55']
            exdb[cols]=exdb[cols].applymap(np.int64)
            
            exdb.loc[:,'ang']= talib.LINEARREG_ANGLE(np.array(exdb.trixl),3)
            exdb=exdb.fillna(0)
            a=exdb[['ang']].values
            exdb.loc[:,'angflag']=np.where(a[:,0]>=0,1,0)  #exdb.apply(lambda x :1 if x.ang>0 else 0 ,axis=1) 
            exdb=np.round(exdb,decimals=2)
            
            return exdb
        except:
            return None
      
   
    
    def getKDseg(self,db):
        lastdownid=db.max(axis=0)['kddown']
        lastupid=db.max(axis=0)['kdup'] 
        if lastdownid>lastupid : #current is down so preseg is up then preseg is down
            mod='down'
            headid=lastdownid
            tailid=lastupid
            preid=db[(db.index<lastupid)].max(axis=0)['kddown']
            if preid==0:
                preid=db[(db.index<lastupid)&(db.kdup!=0)].min(axis=0)['kdup']             
                preid=preid-1
            return "down{}-{}".format(int(lastupid-preid),int(lastdownid-lastupid))
        else:
            headid=lastupid
            tailid=lastdownid
            preid=db[(db.index<lastdownid)].max(axis=0)['kdup']
            if preid==0:
                preid=db[(db.index<lastdownid)&(db.kddown!=0)].min(axis=0)['kddown'] 
                preid=preid-1      
            return "up{}-{}".format(int(lastdownid-preid),int(lastupid-lastdownid))
    def keymod(self,x):
        return "s{}-k{}".format(x.segchanges,x.kdchanges)      
                    
    def getHeadTail(self,db,mod,headid,tailid,lastid):
        _dbhead=db[(db.index==headid)][['angflag','posmacd','id']]
        _dbhead.columns=['anghead','posmacdhead','headid']
        _dbhead.loc[:,'newid']='1'
        _dbhead=_dbhead.set_index('newid') 

        _dbtail=db[(db.index==tailid)][['angflag','posmacd','id']]
        _dbtail.columns=['angtail','posmacdtail','tailid']
        _dbtail.loc[:,'newid']='1'
        _dbtail=_dbtail.set_index('newid')   
        _dbpre=pd.DataFrame()
        if 'down' in mod: # current is down ,so get the current seg area 
            _dbpre =db[(db.index>tailid)].mean()[['segdown20','segdown55']]
        else:  # current is up get previous seg area
            _dbpre =db[(db.index>lastid)&(db.index<=tailid)].mean()[['segdown20','segdown55']]

        #_dbpre=pd.DataFrame(_dbpre).applymap(np.int64)
        gp= pd.concat([_dbhead,_dbtail],axis=1)
        # seedmod first mode 
        gp['seedmod']=gp.apply(lambda x:'{posmacdtail}{posmacdhead}{anghead}'.format(**x),axis=1)
        if _dbpre.values[0]>0.5: #segdown20
            gp['area20']=1
        else:
            gp['area20']=0
        if _dbpre.values[1]>0.8:
            gp['area55']=1
        else:
            gp['area55']=0
        # areamod second mode 
        gp['areamod']=gp.apply(lambda x:'{area55}{area20}'.format(**x),axis=1)
        
        gp['segchanges'] =mod
        gp['kdchanges'] =self.getKDseg(db)
        # keymod third mode 
        gp['keymod']=gp.apply(self.keymod,axis=1)        
        gp['sn']=self.sn
        return gp[['sn','seedmod','areamod','keymod']]
    
   
    def seed(self):
        db=self.getexdb()
        if db.empty==False and len(db)>60:
            lastdownid=db.max(axis=0)['segdown']
            lastupid=db.max(axis=0)['segup']  
            headid=0
            tailid=0
            preid=0
            _dbhead=pd.DataFrame()
            _dbtail=pd.DataFrame()
            mod='up'
            
            if lastdownid>lastupid : #current is down so preseg is up then preseg is down
                mod='down'
                headid=lastdownid
                tailid=lastupid
                preid=db[(db.index<lastupid)].max(axis=0)['segdown']
                if preid==0:
                    preid=db[(db.index<lastupid)&(db.segup!=0)].min(axis=0)['segup']             
                    preid=preid-1
                mod="down{}-{}".format(int(lastupid-preid),int(lastdownid-lastupid))
            else:
                headid=lastupid
                tailid=lastdownid
                preid=db[(db.index<lastdownid)].max(axis=0)['segup']
                if preid==0:
                    preid=db[(db.index<lastdownid)&(db.segdown!=0)].min(axis=0)['segdown'] 
                    preid=preid-1
                mod="up{}-{}".format(int(lastdownid-preid),int(lastupid-lastdownid))
          
            
            return self.getHeadTail(db,mod,headid,tailid,preid) 
    
   
    
class STWTB(STDTB):

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
       
        self.addload()
  
    def getexdb(self):
        try:
  
            exdb=self.db
            #trix
            a=exdb[['macd','id',]].values
            exdb.loc[:,'segdown']= np.where(a[:,0]<0,a[:,1],0)   #exdb.apply(lambda x:x.id if (x.k<x.d)   else 0,axis=1)
            exdb.loc[:,'segup']= np.where(a[:,0]>0,a[:,1],0)   #exdb.apply(lambda x:x.id if (x.k>x.d)   else 0,axis=1)            
            cols=['segdown','segup','posmacd','segdown20','segdown55']
            exdb[cols]=exdb[cols].applymap(np.int64)           
            exdb.loc[:,'ang']= talib.LINEARREG_ANGLE(np.array(exdb.dif),3)
            exdb=exdb.fillna(0)
            a=exdb[['ang']].values
            exdb.loc[:,'angflag']=np.where(a[:,0]>0,1,0)  #exdb.apply(lambda x :1 if x.ang>0 else 0 ,axis=1) 
            exdb=np.round(exdb,decimals=2)
            
            return exdb
        except:
            return None  
  
   
   
class STMTB(STDTB):
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
