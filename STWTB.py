import pandas as pd
import numpy as np
import talib 
import csv
from talib import MA_Type
from zigzag import *
import os
ROOTPATH='/home/lib/mypython/export/'
class STWTB(object):
    def regroup(self,db):
        curid20=0
        for index,row in db.iterrows():
            if row['prez20mode']!=row['z20mode']:
                curid20=index
            db.loc[index,'gpid']=curid20
        return db 
    
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
        
    def posmacd(self,x):
        if (x.macd>0):
            if (x.dif<0)&(x.dea<0):
                return 1
            else :
                return 2
        else: #macd <0
            if (x.dif>0)&(x.dea>0):
                return 3
            else:
                return 4    
    DBF=['date','c','k','d','j','kd4','kd1','posmacd','macd','tmacd','angflag','ang0id','ang1id']
    def getexdb(self):
        try:
            exdb=self.db
            #print(time.time())
            exdb['dif'],exdb['dea'],exdb['macd']=talib.MACD(np.array(exdb.c),10,20,6) # change
            exdb.loc[:,'trixl']=talib.TRIX(np.array(exdb.c),12) 
            exdb.loc[:,'trixs']=talib.SMA(np.array(exdb.trixl),9)
            exdb.loc[:,'posmacd']=exdb.apply(self.posmacd,axis=1)
            exdb['tmacd']=exdb.apply(lambda x :1 if (x.trixl>=x.trixs) and (x.posmacd==1) else 0 ,axis=1)
            #exdb['k'],exdb['d']=talib.STOCHF(np.array(exdb.h),np.array(exdb.l),np.array(exdb.c))
            exdb['k'],exdb['d']=talib.STOCH(np.array(exdb.h),np.array(exdb.l),np.array(exdb.c),9)
            exdb.loc[:,'j']=exdb.k*3-exdb.d*2
            exdb.loc[:,'kd4']= exdb.apply(lambda x:1 if (x.k>x.d) and (x.posmacd==4)  else 0,axis=1)
            exdb.loc[:,'kd1']= exdb.apply(lambda x:1 if (x.k>x.d) and (x.posmacd==1)  else 0,axis=1)
            
            exdb.loc[:,'id']=exdb.index
            exdb.loc[:,'dmzu']=exdb.apply(lambda x:-x.macd if (x.macd<0)&(x.posmacd==3) else 0 ,axis=1) #zero axis down macd
            exdb.loc[:,'dmzd']=exdb.apply(lambda x:-x.macd if (x.macd<0)&(x.posmacd==4) else 0 ,axis=1)
            exdb.loc[:,'umzu']=exdb.apply(lambda x:x.macd if (x.macd>0)&(x.posmacd==2) else 0 ,axis=1)
            exdb.loc[:,'umzd']=exdb.apply(lambda x:x.macd if (x.macd>0)&(x.posmacd==1) else 0 ,axis=1)
            exdb.loc[:,'posm4']=exdb.apply(lambda x:1 if (x.posmacd==4) else 0 ,axis=1)
            exdb.loc[:,'posm1']=exdb.apply(lambda x:1 if (x.posmacd==1) else 0 ,axis=1)
            exdb.loc[:,'ang']= talib.LINEARREG_ANGLE(np.array(exdb.macd),3)
            exdb.loc[:,'angflag']= exdb.apply(lambda x :1 if x.ang>0 else 0 ,axis=1)
            exdb.loc[:,'ang1id']= exdb.apply(lambda x :x.id if x.ang>0 else 0 ,axis=1)
            exdb.loc[:,'ang0id']= exdb.apply(lambda x :x.id if x.ang<0 else 0 ,axis=1)
            #exdb.loc[:,'ang']= talib.LINEARREG_ANGLE(np.array(exdb.dea),3)
            exdb=exdb.fillna(0)
            
            
            z20=peak_valley_pivots(np.array(exdb.c),0.20,-0.20)
            z20mode=pivots_to_modes(z20)  
            exdb.loc[:,'z20mode']=pd.Series(z20mode,index=exdb.index)
            exdb.loc[:,'prez20mode']=exdb.z20mode.shift(1).fillna(0).astype(int)

            exdb.loc[:,'gpid']=0
            exdd=self.regroup(exdb)
            exdb.loc[:,'s20id']=exdb.id-exdb.gpid+1
            exdb=np.round(exdb,decimals=2)
            return exdb
        
        except:
            pass
            #print (self.sn)

    def getexdb1(self):
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
            a=exdb[['k','d','id']].values
            exdb.loc[:,'kd4']= np.where(a[:,0]<a[:,1],a[:,2],0)   #exdb.apply(lambda x:x.id if (x.k<x.d)   else 0,axis=1)
            exdb.loc[:,'kd1']= np.where(a[:,0]>a[:,1],a[:,2],0)   #exdb.apply(lambda x:x.id if (x.k>x.d)   else 0,axis=1)            
            #exdb.loc[:,'trixang']=talib.LINEARREG_ANGLE(np.array(exdb.trixs),3)
            #exdb.loc[:,'trixangflag']=exdb.apply(lambda x :1 if x.trixang>0 else 0 ,axis=1)
            #exdb.loc[:,'seed']= exdb.apply(lambda x:1 if (x.j<x.k) and (x.j<x.d) and (x.k<x.d) and (x.tmacd==1) and (x.trixangflag==1)  else 0 ,axis=1)
            exdb.loc[:,'ang']= talib.LINEARREG_ANGLE(np.array(exdb.dif),3)
            exdb=exdb.fillna(0)
            a=exdb[['ang','id']].values
            exdb.loc[:,'angflag']=np.where(a[:,0]>0,1,0)  #exdb.apply(lambda x :1 if x.ang>0 else 0 ,axis=1) 
            exdb.loc[:,'ang1id']= np.where(a[:,0]>0,a[:,1],0)  #exdb.apply(lambda x :x.id if x.ang>0 else 0 ,axis=1)
            exdb.loc[:,'ang0id']= np.where(a[:,0]<0,a[:,1],0) #exdb.apply(lambda x :x.id if x.ang<0 else 0 ,axis=1)            
            #exdb=np.round(exdb,decimals=2)
            return exdb
        except:
            return None

    def creatgp(self,db):
                # group by gpid get sum of md and gpred
        if db.empty==False and len(db)>20:
            gp22=db.groupby('gpid').sum()[['z20mode','kd4'   ,'kd1'   ,'tmacd'   ,'posm4'   ,'posm1']]
            gp22.columns=['s20len'                  ,'s20kd4','s20kd1','s20tmacd','s20posm4','s20posm1'] #len6 :seg6 
            #gp23=db.groupby('gpid')
            gp23=db.groupby('gpid').max()[['dmzu','umzu','umzd','dmzd','c','ang1id','ang0id']]
            gp23.columns=['s20maxdmzu','s20maxumzu','s20maxumzd','s20maxdmzd','s20maxc','s20ang1id','s20ang0id']                  
            gp24=db.groupby('gpid').min()[['c',]]
            gp24.columns=['s20minc']                  
            idx=db.groupby('gpid')['id'].transform(min)==db['id']
            gp3=db[idx][['gpid','date'        ,'c'        ,'macd'        ]]
            gp3.columns=['gpid','s20startdate','s20startc','s20startmacd']
            gp3=gp3.fillna(0)
            gp3=gp3.set_index('gpid')
            idx2=db.groupby('gpid')['id'].transform(max)==db['id']
            gp32=db[idx2][['gpid','date'     ,'c'        ,'s20id','macd'       ,'angflag'       ,'tmacd'       ,'posmacd'      ]]
            gp32.columns=['gpid','s20lastdate','s20lastc','s20id','s20lastmacd','s20lastangflag','s20lasttmacd','s20lastposmacd']
            gp32=gp32.fillna(0)
            gp32=gp32.set_index('gpid')

            gp=pd.concat([gp22,gp23,gp24,gp3,gp32],axis=1,join="inner")



            #gp['sn']=self.sn
            gp['s20len1']=gp.s20len.shift(1) 
            gp=gp.dropna(axis=0)  #drop the first row that is not really segment

            gp['s20len2']=gp.s20len.shift(2)
            gp['s20len3']=gp.s20len.shift(3)
            gp['s20len4']=gp.s20len.shift(4)
            p20=peak_valley_pivots(np.array(db['c']),0.20,-0.20)
            ##segdrawdown: sdd6
            s20sdd=compute_segment_returns(np.array(db['c']),p20)
            ##segdrawdown=np.insert(segdrawdown,0,0)
            gp['s20sdd']=pd.Series(s20sdd,index=gp.index)
            gp['s20sdd1']=gp.s20sdd.shift(1)
            #gp['s20sdd2']=gp.s20sdd.shift(2)
            #gp['s20sdd3']=gp.s20sdd.shift(3)
            #gp['s20sdd4']=gp.s20sdd.shift(4)
            gp['s20startdate1']=gp.s20startdate.shift(1)
            gp['s20startdate2']=gp.s20startdate.shift(2)
            gp['s20startdate3']=gp.s20startdate.shift(3)
            gp['s20startdate4']=gp.s20startdate.shift(4)

            gp['gpid']=gp.index
            gp.loc[:,'lastangflag']=gp.s20ang1id-gp.s20ang0id
            gp.loc[:,'kmt']=gp.apply(lambda x:'[{s20kd4},{s20kd1}]-[{s20posm4},{s20posm1}]-[{s20tmacd}]'.format(**x),axis=1)

            return gp  

    
    
    CONf= ['sn','s20startdate','s20sdd','s20minc','s20lastc','s20len','kmt','s20lastdate','s20lastangflag','lastangflag']
    CONfm= ['sn','mstartdate','msdd','mminc','mlastc','mlen','mkmt','mlastdate','mlastangflag']
    CONfw= ['sn','wstartdate','wsdd','wminc','wlastc','wlen','wkmt','wlastdate','wlastangflag']
    CONf1=['s20startdate','s20sdd','s20minc','s20lastc','s20maxc','s20len','s20lastangflag','s20lastmacd','s20lasttmacd','s20lastdmzu','s20lastdate']

    def getgp(self):
        try:
            db=self.getexdb()
            #gp6=self.creatgp6(db)
            gp=self.creatgp(db)
            gp['sn']=self.sn
   
            gp=np.round(gp,decimals=3)
            return gp

        except:
            #print('get gp failure')
            return None

    def keypos(self,x):
        return "{}{}{}".format(int(x.posmacdp),int(x.posmacds),int(x.posmacdb))

    def seed(self):
        db=self.getexdb()
        try:
            lastang0id=db.max(axis=0)['ang0id']
            lastang1id=db.max(axis=0)['ang1id']
            _dbang0=db[(db.index==lastang0id)][['tmacd','trixs','posmacd','id']]
            
            _dbang0.columns=['tmacd0','trixs0','posmacd0','ang0id']
            _dbang0.loc[:,'newid']='1'
            _dbang0=_dbang0.set_index('newid')
            _dbang1=db[(db.index==lastang1id)][['tmacd','trixs','posmacd','id']]
            _dbang1.columns=['tmacd1','trixs1','posmacd1','ang1id']
            _dbang1.loc[:,'newid']='1'
            _dbang1=_dbang1.set_index('newid')        
            gp= pd.concat([_dbang0,_dbang1],axis=1)
            gp['totalkey']=gp.apply(lambda x: int (x.ang1id-x.ang0id) if x.ang1id>x.ang0id else int(x.ang1id-x.ang0id),axis=1)
            #gp['keypos']=gp.apply(self.keypos,axis=1)
            gp['sn']=self.sn
            return gp
        except:
            return None
    def seed1(self):
            db=self.getexdb1()
            try:
                lastang0id=db.max(axis=0)['ang0id']
                lastang1id=db.max(axis=0)['ang1id']
                idsmall=min(lastang0id,lastang1id)
                idbig  =max(lastang0id,lastang1id)
                _dbSmall=db[(db.index==idsmall)][['tmacd','trixs','posmacd','id']]
                _dbSmall.columns=['tmacds','trixss','posmacds','angsid']
                _dbSmall.loc[:,'newid']='1'
                _dbSmall=_dbSmall.set_index('newid')

                _dbBig=db[(db.index==idbig)][['tmacd','trixs','posmacd','id']]
                _dbBig.columns=['tmacdb','trixsb','posmacdb','angbid']
                _dbBig.loc[:,'newid']='1'
                _dbBig=_dbBig.set_index('newid')    
                idpro=db[(db.index<idsmall)].max(axis=0)[['ang0id','ang1id']].max()
                _dbpro=db[(db.index==idpro)][['tmacd','trixs','posmacd','id']]
                _dbpro.columns=['tmacdp','trixsp','posmacdp','angpid']
                _dbpro.loc[:,'newid']='1'
                _dbpro=_dbpro.set_index('newid')                
                    
                gp= pd.concat([_dbSmall,_dbBig,_dbpro],axis=1)
                if lastang0id>lastang1id:
                    gp['totalkey']=idsmall-idbig
                else:
                    gp['totalkey']=-(idsmall-idbig)
                
                gp['keypos']=gp.apply(self.keypos,axis=1)
                gp['sn']=self.sn
                return gp
            except:
                return None    
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
