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
        self.clstype='D'
        if len(file)==8:
            self.sn=file[-6:]
            self.snpath="{}{}.txt".format(ROOTPATH,file)            
        else:
            self.sn=os.path.splitext(file)[0][-6:] 
            self.snpath=file
        
        self.load()

    def addload(self):
        exdb=self.db
        exdb['dif'],exdb['dea'],exdb['macd']=talib.MACD(np.array(exdb.c),20,55,6) 
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
    DBF=['date','kdup','kddown','segup','segdown','posmacd','macd','tmacd','ang','angflag','c','segdown55','segdown20','ang20']
    def getexdb(self):
        try:
  
            exdb=self.db
            #trix
            #a=exdb[['tmacd','id']].values
            a=exdb[['macd','id']].values
            exdb.loc[:,'segup']  = np.where(a[:,0]>0,a[:,1],0)   #exdb.apply(lambda x:x.id if (x.k<x.d)   else 0,axis=1)
            exdb.loc[:,'segdown']= np.where(a[:,0]<=0,a[:,1],0)   #exdb.apply(lambda x:x.id if (x.k>x.d)   else 0,axis=1)            
            cols=['segdown','segup','posmacd','segdown20','segdown55','kdup','kddown']
            exdb[cols]=exdb[cols].applymap(np.int64)
            
            exdb.loc[:,'ang']= talib.LINEARREG_ANGLE(np.array(exdb.trixl),3)
            exdb.loc[:,'ang20']= talib.LINEARREG_ANGLE(np.array(exdb.sma20),3)
            exdb.loc[:,'ang55']= talib.LINEARREG_ANGLE(np.array(exdb.sma55),3)
            exdb=exdb.fillna(0)
            a=exdb[['ang']].values
            exdb.loc[:,'angflag']=np.where(a[:,0]>=0,1,0)  #exdb.apply(lambda x :1 if x.ang>0 else 0 ,axis=1) 
            exdb=np.round(exdb,decimals=2)
            
            return exdb
        except:
            return None
      
   
    
   
    
   
   
    def seed(self):
        #get big segment trend
        def getSegMode(db):
            #get posmacdtail-posmacdhead-anghead
            _IdLastdown=db.max(axis=0)['segdown']
            _IdLastup=db.max(axis=0)['segup'] 
            _posmacdLastdown=db.loc[_IdLastdown]['posmacd']
            _posmacdLastup=db.loc[_IdLastup]['posmacd']
            if _IdLastdown>_IdLastup: 
                return "S{}:{}{}{}".format(self.clstype,_posmacdLastup,_posmacdLastdown,db.loc[_IdLastdown]['angflag'])
            else:
                return "S{}:{}{}{}".format(self.clstype,_posmacdLastdown,_posmacdLastup,db.loc[_IdLastup]['angflag'])
        #get kdj segemnt trend
        def getKDseg(db):
            def getSumPosmacd(startid,endid,db):
                if (endid-startid)==db.loc[startid:endid]['posmacd'].sum():
                    return 'in'
                else:
                    return 'out'
                
            _IdLastdown=db.max(axis=0)['kddown']
            _IdLastup=db.max(axis=0)['kdup'] 
            # id3--segPre ---id2 --segCur--id1
            curkdjmod='up'
            _id1,_id2,_id3=0,0,0
            if _IdLastdown>_IdLastup : #current is down so preseg is up then preseg is down
                _id1=_IdLastdown
                _id2=_IdLastup
                # kdj is down
                _id3=db.loc[(db.index<_id2)].max(axis=0)['kddown']
                if _id3==0:
                    _id3=db[(db.index<_id2)&(db.kdup!=0)].min(axis=0)['kdup']             
                    _id3=_id3-1
                curkdjmod='do'
            else: # lastupid>lastdownid
                _id1=_IdLastup
                _id2=_IdLastdown
                _id3=db[(db.index<_IdLastdown)].max(axis=0)['kdup']
                if _id3==0:
                    _id3=db[(db.index<_IdLastdown)&(db.kddown!=0)].min(axis=0)['kddown'] 
                    _id3=_id3-1      
            return "{}[{}-{}]_{}{}{}".format(curkdjmod,int(_id2-_id3),int(_id1-_id2),curkdjmod,getSumPosmacd(_id3,_id2,db),getSumPosmacd(_id2,_id1,db))        
        
        db=self.getexdb()
        if db is not None and len(db)>60:
            return "{},{}".format(getSegMode(db),getKDseg(db))
        else:
            return None
    
   
    
class STWTB(STDTB):

    def __init__(self,file):
        self.name='STWTB'
        self.clstype='W'
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
        if len(wdb)>=40:
            self.addload()
        else:
            self.db=None
  
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
