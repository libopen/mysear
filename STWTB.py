import pandas as pd
import numpy as np
import talib 
import csv
from talib import MA_Type
from zigzag import *
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

    def getexdb(self):
        try:
            self.load()
            exdb=self.db
            #print(time.time())
            exdb['dif'],exdb['dea'],exdb['macd']=talib.MACD(np.array(exdb.c),10,20,6) # change
            exdb['trixl']=talib.TRIX(np.array(exdb.c),12) 
            exdb['trixs']=talib.SMA(np.array(exdb.trixl),9)
            exdb['tmacd']=exdb.apply(lambda x :1 if x.trixl>=x.trixs else 0 ,axis=1)
            exdb.loc[:,'id']=exdb.index
            exdb.loc[:,'dmzu']=exdb.apply(lambda x:-x.macd if (x.macd<0)&(x.dif>0)&(x.dea>0) else 0 ,axis=1) #zero axis down macd
            exdb.loc[:,'dmzd']=exdb.apply(lambda x:-x.macd if (x.macd<0)&(x.dmzu==0) else 0 ,axis=1)
            exdb.loc[:,'umzu']=exdb.apply(lambda x:x.macd if (x.macd>0)&(x.dif>0)&(x.dea>0) else 0 ,axis=1)
            exdb.loc[:,'umzd']=exdb.apply(lambda x:x.macd if (x.macd>0)&(x.umzu==0) else 0 ,axis=1)
            exdb.loc[:,'idmzu']=exdb.apply(lambda x:1 if (x.macd<0)&(x.dif>0)&(x.dea>0) else 0 ,axis=1)
            exdb.loc[:,'idmzd']=exdb.apply(lambda x:1 if (x.macd<0)&(x.idmzu==0) else 0 ,axis=1)
            exdb.loc[:,'iumzu']=exdb.apply(lambda x:1 if (x.macd>0)&(x.dif>0)&(x.dea>0) else 0 ,axis=1)
            exdb.loc[:,'iumzd']=exdb.apply(lambda x:1 if (x.macd>0)&(x.iumzu==0) else 0 ,axis=1)
            
            exdb.loc[:,'ang']= talib.LINEARREG_ANGLE(np.array(exdb.macd),3)
            
            exdb.loc[:,'se']= exdb.apply(lambda x:1 if (x.c<x.o) and (x.idmzd==1)  else 0,axis=1)
            exdb.loc[:,'se1']= exdb.se.shift(1)
            exdb.loc[:,'se2']= exdb.se.shift(2)
            exdb.loc[:,'buy']= exdb.apply(lambda x:1 if (x.c>x.o)&(x.o>x.l) and (x.idmzd==1)  else 0,axis=1)
            exdb.loc[:,'buy1']=exdb.buy.shift(1)
            exdb.loc[:,'buy2']=exdb.buy.shift(2)
            exdb.loc[:,'buycintue']=exdb.apply(lambda x:1 if (x.se2==1)&(x.buy1==1)&(x.buy==1) else 0,axis=1)
            exdb=exdb.fillna(0)
            
            
            z20=peak_valley_pivots(np.array(exdb.c),0.20,-0.20)
            z20mode=pivots_to_modes(z20)  
            exdb.loc[:,'z20mode']=pd.Series(z20mode,index=exdb.index)
            exdb.loc[:,'prez20mode']=exdb.z20mode.shift(1).fillna(0).astype(int)

            exdb.loc[:,'gpid']=0
            exdd=self.regroup(exdb)
            exdb.loc[:,'s20id']=exdb.id-exdb.gpid+1
            exdb.loc[:,'pd']=talib.PLUS_DI(np.array(exdb.h),np.array(exdb.l),np.array(exdb.c))
            exdb.loc[:,'stddev']=talib.STDDEV(np.array(exdb.c))
            return exdb
        except:
            pass
            #print (self.sn)

    def creatgp(self,db):
                # group by gpid get sum of md and gpred
        if db.empty==False and len(db)>20:
            gp22=db.groupby('gpid').sum()[['z20mode','idmzu','idmzd','iumzu','iumzd','buycintue']]
            gp22.columns=['s20len','s20sumdmzu','s20sumdmzd','s20sumumzu','s20sumumzd','s20buy'] #len6 :seg6 
            #gp23=db.groupby('gpid')
            gp23=db.groupby('gpid').max()[['dmzu','umzu','umzd','dmzd']]
            gp23.columns=['s20maxdmzu','s20maxumzu','s20maxumzd','s20maxdmzd']                  
            gp24=db.groupby('gpid').min()[['c',]]
            gp24.columns=['s20minc']                  
            idx=db.groupby('gpid')['id'].transform(min)==db['id']
            gp3=db[idx][['gpid','date'        ,'c'        ,'macd'        ,'dea']]
            gp3.columns=['gpid','s20startdate','s20startc','s20startmacd','s20startdea']
            gp3=gp3.fillna(0)
            gp3=gp3.set_index('gpid')
            idx2=db.groupby('gpid')['id'].transform(max)==db['id']
            gp32=db[idx2][['gpid','date'     ,'c'        ,'s20id','macd'       ,'ang'       ,'tmacd'       ,'idmzu'      ,'dea']]
            gp32.columns=['gpid','s20lastdate','s20lastc','s20id','s20lastmacd','s20lastang','s20lasttmacd','s20lastdmzu','s20lastdea']
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
            # seg3 up seg seg2 down seg seg1 up seg seg current seg is also key entry               
            gp['s20sumdmzu1']=gp.s20sumdmzu.shift(1) #down and zero 
            gp['s20sumdmzd1']=gp.s20sumdmzd.shift(1)
            gp['s20maxumzu1']=gp.s20maxumzu.shift(1)
            gp['s20maxumzd1']=gp.s20maxumzd.shift(1)
            gp['s20sumumzu1']=gp.s20sumumzu.shift(1) # up and zero 
            gp['s20sumumzd1']=gp.s20sumumzd.shift(1)
            gp['s20maxdmzu1']=gp.s20maxdmzu.shift(1)
            gp['s20maxdmzd1']=gp.s20maxdmzd.shift(1) 

            gp['s20sumdmzu2']=gp.s20sumdmzu.shift(2)
            gp['s20sumdmzd2']=gp.s20sumdmzd.shift(2)
            gp['s20sumumzu2']=gp.s20sumumzu.shift(2)
            gp['s20sumumzd2']=gp.s20sumumzd.shift(2)
            gp['s20maxumzu2']=gp.s20maxumzu.shift(2)
            gp['s20maxumzd2']=gp.s20maxumzd.shift(2)
            gp['s20maxdmzu2']=gp.s20maxdmzu.shift(2)
            gp['s20maxdmzd2']=gp.s20maxdmzd.shift(2) 

            gp['s20sumdmzu3']=gp.s20sumdmzu.shift(3)
            gp['s20sumdmzd3']=gp.s20sumdmzd.shift(3)
            gp['s20maxdmzu3']=gp.s20maxdmzu.shift(3)
            gp['s20maxdmzd3']=gp.s20maxdmzd.shift(3)
            gp['s20startdate1']=gp.s20startdate.shift(1)
            gp['s20startdate2']=gp.s20startdate.shift(2)
            gp['s20startdate3']=gp.s20startdate.shift(3)
            gp['s20startdate4']=gp.s20startdate.shift(4)

            gp['gpid']=gp.index


            return gp  
    def Level0(self,x):
        # zua :s20lastang>0 and s20lastdmzu 1 ---up zero and ang turn
        # zum:s20lastmacd>0 and s20lastdmzu 1 --up zero and macd turn 
        # zda :s20lastang>0 and s20lastdmzu 0 ---down zero and ang turn
        # zdm:s20lastmacd>0 and s20lastdmzd 0 --down zero and macd turn
        #     s20lasttmacd 1  ---trix as long index ,long trend  is up 
        #        zua -> zum, zda-> zdm       
        #     s20lasttmacd 0->1 --trend is turning down to up 
        #        zua -> zum, zda-> zdm
        if x.s20lasttmacd==1:
            if (x.s20sdd<0)  and (x.s20lastmacd<0) and (x.s20lastdmzu==0) and (x.s20lastc>x.s20minc):
                return '1_zd_m<0'
            elif (x.s20sdd<0) and  (x.s20lastmacd>0) and (x.s20lastdmzu==0) :
                return '1_zd_m>0'
            else:
                return 0  
        else:
            if (x.s20sdd<0)  and (x.s20lastmacd<0) and (x.s20lastdmzu==0) and (x.s20lastc>x.s20minc):
                return '0_zd_m<0'
            elif (x.s20sdd<0) and  (x.s20lastmacd>0) and (x.s20lastdmzu==0) :
                return '0_zd_m>0'

            else :
                return 0
    def Level1(self,x):
        # s20sdd1>0 s20startdea1 s20sdd<0 s20lastdea if s20lastdea>s20startdea1 or s20minc>s20minc1
        if (x.s20sdd<0) and (x.s20minc>x.s20minc1):
            return 1
        else :
            return 0
    CONf=['s20startdate','s20sdd','s20minc','s20lastc','s20len','Level0','s20lastdate']
    CONf1=['s20startdate','s20sdd','s20minc','s20lastc','s20len','s20lastang','s20lastmacd','s20lasttmacd','s20lastdmzu','s20lastdate','Level1','Level0','s20buy']

    def getgp(self):
        try:
            db=self.getexdb()
            #gp6=self.creatgp6(db)
            gp=self.creatgp(db)
            gp['sn']=self.sn
            gp.loc[:,'s20minc1']=gp.s20minc.shift(1)
            gp.loc[:,'Level0']=gp.apply(self.Level0,axis=1)
            gp.loc[:,'Level1']=gp.apply(self.Level1,axis=1)
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
