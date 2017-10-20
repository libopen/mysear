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
    DBF=['date','c','macd','tmacd','k','d','kd4','kd1','posmacd']
    def getexdb(self):
        try:
            self.load()
            exdb=self.db
            #print(time.time())
            exdb['dif'],exdb['dea'],exdb['macd']=talib.MACD(np.array(exdb.c),10,20,6) # change
            exdb.loc[:,'trixl']=talib.TRIX(np.array(exdb.c),12) 
            exdb.loc[:,'trixs']=talib.SMA(np.array(exdb.trixl),9)
            exdb.loc[:,'posmacd']=exdb.apply(self.posmacd,axis=1)
            exdb['tmacd']=exdb.apply(lambda x :1 if (x.trixl>=x.trixs) and (x.posmacd==1) else 0 ,axis=1)
            #exdb['k'],exdb['d']=talib.STOCHF(np.array(exdb.h),np.array(exdb.l),np.array(exdb.c))
            exdb['k'],exdb['d']=talib.STOCH(np.array(exdb.h),np.array(exdb.l),np.array(exdb.c),9)
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

    def creatgp(self,db):
                # group by gpid get sum of md and gpred
        if db.empty==False and len(db)>20:
            gp22=db.groupby('gpid').sum()[['z20mode','kd4'   ,'kd1'   ,'tmacd'   ,'posm4'   ,'posm1']]
            gp22.columns=['s20len'                  ,'s20kd4','s20kd1','s20tmacd','s20posm4','s20posm1'] #len6 :seg6 
            #gp23=db.groupby('gpid')
            gp23=db.groupby('gpid').max()[['dmzu','umzu','umzd','dmzd','c']]
            gp23.columns=['s20maxdmzu','s20maxumzu','s20maxumzd','s20maxdmzd','s20maxc']                  
            gp24=db.groupby('gpid').min()[['c',]]
            gp24.columns=['s20minc']                  
            idx=db.groupby('gpid')['id'].transform(min)==db['id']
            gp3=db[idx][['gpid','date'        ,'c'        ,'macd'        ]]
            gp3.columns=['gpid','s20startdate','s20startc','s20startmacd']
            gp3=gp3.fillna(0)
            gp3=gp3.set_index('gpid')
            idx2=db.groupby('gpid')['id'].transform(max)==db['id']
            gp32=db[idx2][['gpid','date'     ,'c'        ,'s20id','macd'       ,'ang'       ,'tmacd'       ,'posmacd'      ]]
            gp32.columns=['gpid','s20lastdate','s20lastc','s20id','s20lastmacd','s20lastang','s20lasttmacd','s20lastposmacd']
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
            gp.loc[:,'kmt']=gp.apply(lambda x:'[{s20kd4},{s20kd1}]-[{s20posm4},{s20posm1}]-[{s20tmacd}]'.format(**x),axis=1)

            return gp  

    
    
    CONf= ['sn','s20startdate','s20sdd','s20minc','s20lastc','s20len','kmt','s20lastdate']
    CONfm= ['sn','mstartdate','msdd','mminc','mlastc','mlen','mkmt','mlastdate']
    CONfw= ['sn','wstartdate','wsdd','wminc','wlastc','wlen','wkmt','wlastdate']
    CONf1=['s20startdate','s20sdd','s20minc','s20lastc','s20maxc','s20len','s20lastang','s20lastmacd','s20lasttmacd','s20lastdmzu','s20lastdate']

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
