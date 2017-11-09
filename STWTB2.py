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
        
  
    #DBF=['date','c','k','d','j','segdown','segup','posmacd','macd','tmacd','angflag','kd','difup1']
    DBF=['date','kd','segup','segdown','posmacd','macd','tmacd','ang','angflag','c','k','d']
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
            exdb['sma20']=talib.SMA(np.array(exdb.c),20)
            exdb['sma55']=talib.SMA(np.array(exdb.c),55)
            exdb['trixl']=talib.TRIX(np.array(exdb.c),12) 
            exdb['trixs']=talib.SMA(np.array(exdb.trixl),9)
            exdb=exdb.fillna(0)
            a=exdb[['trixl','trixs','posmacd']].values
            exdb['tmacd']= np.where(((a[:,0]>a[:,1])&(a[:,2]==1)),1,0)# exdb.apply(lambda x :1 if (x.trixl>=x.trixs)and (x.posmacd==1) else 0 ,axis=1)             
            exdb.loc[:,'id']=exdb.index
            exdb['k'],exdb['d']=talib.STOCH(np.array(exdb.h),np.array(exdb.l),np.array(exdb.c),9)
            exdb=exdb.fillna(0)
            exdb.loc[:,'j']=exdb.k*3-exdb.d*2
            a=exdb[['macd','id','k','d','posmacd','dif','c','sma20','sma55']].values
            exdb.loc[:,'segdown']= np.where(a[:,0]<0,a[:,1],0)   #exdb.apply(lambda x:x.id if (x.k<x.d)   else 0,axis=1)
            exdb.loc[:,'segup']= np.where(a[:,0]>0,a[:,1],0)   #exdb.apply(lambda x:x.id if (x.k>x.d)   else 0,axis=1)            
            exdb.loc[:,'segdown20']= np.where((a[:,0]<0)&(a[:,6]>a[:,7]),1,0)
            exdb.loc[:,'segdown55']= np.where((a[:,0]<0)&(a[:,6]>a[:,8]),1,0)
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
            cols=['segdown','segup','posmacd','kd','ang0id','ang1id','difup1','segdown20','segdown55']
            exdb[cols]=exdb[cols].applymap(np.int64)
            return exdb
        except:
            return None

  
    def keypos(self,x):
        return "{}-{}".format(int(x.seedmod),int(x.changes))

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
        if mod=='down': # current is down ,so get the current seg area 
            _dbpre =db[(db.index>tailid)].mean()[['segdown20','segdown55']]
        else:  # current is up get previous seg area
            _dbpre =db[(db.index>lastid)&(db.index<=tailid)].mean()[['segdown20','segdown55']]
         
        #_dbpre=pd.DataFrame(_dbpre).applymap(np.int64)
        gp= pd.concat([_dbhead,_dbtail],axis=1)
        gp['seedmod']=gp.apply(lambda x:'{posmacdtail}{posmacdhead}{anghead}'.format(**x),axis=1)
        if _dbpre.values[0]>0.5: #segdown20
            gp['area20']=1
        else:
            gp['area20']=0
        if _dbpre.values[1]>0.8:
            gp['area55']=1
        else:
            gp['area55']=0
        #return _dbhead,_dbtail,_dbpre,gp
        gp['area']=gp.apply(lambda x:'{area55}{area20}'.format(**x),axis=1)
        gp['changes'] =headid-tailid
        
        gp['keypos']=gp.apply(self.keypos,axis=1)        
        gp['sn']=self.sn
        return gp[['sn','seedmod','area','keypos']]
    
    
    def seedmod(self,db):
        lastdownid=db.max(axis=0)['segdown']
        lastupid=db.max(axis=0)['segup']  
        lastdifup1id=db.max(axis=0)['difup1']
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
        else:
            headid=lastupid
            tailid=lastdownid
            preid=db[(db.index<lastdownid)].max(axis=0)['segup']
            if preid==0:
                preid=db[(db.index<lastdownid)&(db.segdown!=0)].min(axis=0)['segdown'] 
                preid=preid-1
        
        return self.getHeadTail(db,mod,headid,tailid,preid)
        #return mod,headid,tailid,preid
        
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
                # current seg is down compute segdown20 and segdown55
                
            else:
                gp['seedmod']=gp.apply(lambda x:'{posmacddown}{posmacdup}{difturn}'.format(**x),axis=1)
                # is previous downseg
                
                
                
            gp['macdturn']=lastupid-lastdifup1id
            gp['keypos']=gp.apply(self.keypos,axis=1)
            
            gp['sn']=self.sn
            #return gp,self.seedmod(db)
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
