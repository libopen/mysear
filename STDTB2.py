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

 
    def regroup(self,db):
        curid13=0
        curid6=0
        for index,row in db.iterrows():
            if row['prez6mode']!=row['z6mode']:
                curid6=index
            if row['prez13mode']!=row['z13mode']:
                curid13=index

            db.loc[index,'gpid6']=curid6
            db.loc[index,'gpid']=curid13
        return db 
    
    def posmacd(self,x):
        if (x.dif<0)&(x.dea<0):
            if x.macd>0:
                return 1
            else :
                return 4
        else:
            if x.macd>0:
                return 2
            else:
                return 3
    
    DBF=['date','c','k','d','j','kd4','kd1','kdj','posmacd','macd','tmacd','angflag']
    def getexdb(self):
        try:
            self.load()
            exdb=self.db
            #macd
            exdb['dif'],exdb['dea'],exdb['macd']=talib.MACD(np.array(exdb.c),10,20,6) # change
            
            
            exdb.loc[:,'posmacd']=exdb.apply(self.posmacd,axis=1)
            #exdb=self.posmacd2(exdb)
            #trix
            exdb['trixl']=talib.TRIX(np.array(exdb.c),12) 
            exdb['trixs']=talib.SMA(np.array(exdb.trixl),9)
            exdb['tmacd']=exdb.apply(lambda x :1 if (x.trixl>=x.trixs)and (x.posmacd==1) else 0 ,axis=1)  
            #kdj
            exdb['k'],exdb['d']=talib.STOCH(np.array(exdb.h),np.array(exdb.l),np.array(exdb.c),9)
            exdb.loc[:,'j']=exdb.k*3-exdb.d*2
            exdb.loc[:,'kd4']= exdb.apply(lambda x:1 if (x.k>x.d) and (x.posmacd==4)  else 0,axis=1)
            exdb.loc[:,'kd1']= exdb.apply(lambda x:1 if (x.k>x.d) and (x.posmacd==1)  else 0,axis=1)
            exdb.loc[:,'trixang']=talib.LINEARREG_ANGLE(np.array(exdb.trixs),3)
            exdb.loc[:,'trixangflag']=exdb.apply(lambda x :1 if x.trixang>0 else 0 ,axis=1)
            exdb.loc[:,'seed']= exdb.apply(lambda x:1 if (x.j<x.k) and (x.j<x.d) and (x.k<x.d) and (x.tmacd==1) and (x.trixangflag==1)  else 0 ,axis=1)
            #my para
            exdb.loc[:,'tmacd1']=exdb.tmacd.shift(1)
            exdb.loc[:,'kdkey']=exdb.apply(lambda x:1 if (x.posmacd==1) and (x.tmacd==1) and (x.tmacd1==1) and (x.kd4==0) and (x.kd1==0) else 0,axis=1)
            exdb.loc[:,'id']=exdb.index
            exdb.loc[:,'dmzu']=exdb.apply(lambda x:-x.macd if (x.posmacd==3) else 0 ,axis=1) #zero axis down macd
            exdb.loc[:,'dmzd']=exdb.apply(lambda x:-x.macd if (x.posmacd==4) else 0 ,axis=1)
            exdb.loc[:,'umzu']=exdb.apply(lambda x:x.macd if (x.posmacd==2) else 0 ,axis=1)
            exdb.loc[:,'umzd']=exdb.apply(lambda x:x.macd if (x.posmacd==1) else 0 ,axis=1)
            exdb.loc[:,'posm4']=exdb.apply(lambda x:1 if (x.posmacd==4) else 0 ,axis=1)
            exdb.loc[:,'posm1']=exdb.apply(lambda x:1 if (x.posmacd==1) else 0 ,axis=1)
            exdb.loc[:,'ang']= talib.LINEARREG_ANGLE(np.array(exdb.dea),3)
            exdb.loc[:,'angflag']= exdb.apply(lambda x :1 if x.ang>0 else 0 ,axis=1)
            exdb=np.round(exdb,decimals=2)
            exdb=exdb.fillna(0)
        
            z6=peak_valley_pivots(np.array(exdb.c),0.10,-0.10)
            z13=peak_valley_pivots(np.array(exdb.c),0.20,-0.20)
            z6mode=pivots_to_modes(z6)
            z13mode=pivots_to_modes(z13)
            #print(time.time())
            exdb.loc[:,'z6']=pd.Series(z6,index=exdb.index)
            exdb.loc[:,'z13']=pd.Series(z13,index=exdb.index)
            exdb.loc[:,'z6mode']=pd.Series(z6mode,index=exdb.index)
            exdb.loc[:,'z13mode']=pd.Series(z13mode,index=exdb.index)
            exdb.loc[:,'prez13mode']=exdb.z13mode.shift(1).fillna(0).astype(int)
            exdb.loc[:,'prez6mode']=exdb.z6mode.shift(1).fillna(0).astype(int)

            exdb.loc[:,'gpid']=0
            exdb.loc[:,'gpid6']=0

            #print(time.time())
            #exdb=self.regroup13(exdb)
            #exdb=self.regroup6(exdb)
            exdb=self.regroup(exdb)
            exdb.loc[:,'s6id']=exdb.id-exdb.gpid6+1 #use for get the current position in current seg
            exdb.loc[:,'s13id']=exdb.id-exdb.gpid+1
            #print(time.time())
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
            a=exdb[['k','d','id','j']].values
            exdb.loc[:,'kd4']= np.where(a[:,0]<a[:,1],a[:,2],0)   #exdb.apply(lambda x:x.id if (x.k<x.d)   else 0,axis=1)
            exdb.loc[:,'kd1']= np.where(a[:,0]>a[:,1],a[:,2],0)   #exdb.apply(lambda x:x.id if (x.k>x.d)   else 0,axis=1)            
            exdb.loc[:,'kdj']= np.where((a[:,0]>a[:,3]) &(a[:,1]>a[:,3]),1,0)
            #exdb.loc[:,'trixang']=talib.LINEARREG_ANGLE(np.array(exdb.trixs),3)
            #exdb.loc[:,'trixangflag']=exdb.apply(lambda x :1 if x.trixang>0 else 0 ,axis=1)
            #exdb.loc[:,'seed']= exdb.apply(lambda x:1 if (x.j<x.k) and (x.j<x.d) and (x.k<x.d) and (x.tmacd==1) and (x.trixangflag==1)  else 0 ,axis=1)
            exdb.loc[:,'ang']= talib.LINEARREG_ANGLE(np.array(exdb.dea),3)
            exdb=exdb.fillna(0)
            a=exdb[['ang']].values
            exdb.loc[:,'angflag']=np.where(a[:,0]>0,1,0)  #exdb.apply(lambda x :1 if x.ang>0 else 0 ,axis=1)            
            return exdb
        except:
            return None
    def getexdbforseed(self):
        try:
            
            exdb=self.db
            #macd
            exdb['dif'],exdb['dea'],exdb['macd']=talib.MACD(np.array(exdb.c),10,20,6) # change
            exdb.loc[:,'posmacd']=exdb.apply(self.posmacd,axis=1)
            #exdb=self.posmacd2(exdb)
            #trix
            exdb['trixl']=talib.TRIX(np.array(exdb.c),12) 
            exdb['trixs']=talib.SMA(np.array(exdb.trixl),9)
            exdb['tmacd']=exdb.apply(lambda x :1 if (x.trixl>=x.trixs)and (x.posmacd==1) else 0 ,axis=1)  
            #kdj
            exdb.loc[:,'id']=exdb.index
            exdb['k'],exdb['d']=talib.STOCH(np.array(exdb.h),np.array(exdb.l),np.array(exdb.c),9)
            exdb.loc[:,'j']=exdb.k*3-exdb.d*2
            exdb.loc[:,'kd4']= exdb.apply(lambda x:x.id if (x.k<x.d)   else 0,axis=1)
            exdb.loc[:,'kd1']= exdb.apply(lambda x:x.id if (x.k>x.d)   else 0,axis=1)
            #exdb.loc[:,'trixang']=talib.LINEARREG_ANGLE(np.array(exdb.trixs),3)
            #exdb.loc[:,'trixangflag']=exdb.apply(lambda x :1 if x.trixang>0 else 0 ,axis=1)
            #exdb.loc[:,'seed']= exdb.apply(lambda x:1 if (x.j<x.k) and (x.j<x.d) and (x.k<x.d) and (x.tmacd==1) and (x.trixangflag==1)  else 0 ,axis=1)
            exdb.loc[:,'ang']= talib.LINEARREG_ANGLE(np.array(exdb.dea),3)
            
            exdb.loc[:,'angflag']= exdb.apply(lambda x :1 if x.ang>0 else 0 ,axis=1)            #my para
          
            exdb=exdb.fillna(0)
        
   
            #print(time.time())
            #exdb=self.regroup13(exdb)
            #exdb=self.regroup6(exdb)
            #print(time.time())
            return exdb
        except:
            pass
            #print (self.sn)



    def creatgp13(self,db):
            # group by gpid get sum of md and gpred
        if db.empty==False and len(db)>60:
            gp22=db.groupby('gpid').sum()[['z13mode','kd4'   ,'kd1'   ,'tmacd'   ,'posm4'   ,'posm1']]
            gp22.columns=['s13len'                  ,'s13kd4','s13kd1','s13tmacd','s13posm4','s13posm1']
            gp23=db.groupby('gpid').max()[['dmzu','umzu','umzd','dmzd','c']]
            gp23.columns=['s13maxdmzu','s13maxumzu','s13maxumzd','s13maxdmzd','s13maxc']
            gp24=db.groupby('gpid').min()[['c']]
            gp24.columns=['s13minc'] 
            #gp23=db.groupby('gpid')
            idx=db.groupby('gpid')['id'].transform(min)==db['id']
            gp3=db[idx][['gpid','date','c','dea']]
            gp3.columns=['gpid','s13startdate','s13startc','s13startdea']
            gp3=gp3.fillna(0)
            gp3=gp3.set_index('gpid')
            idx2=db.groupby('gpid')['id'].transform(max)==db['id']  #the current and the last position
            gp32=db[idx2][['gpid','date'       ,'c'       ,'s13id','macd'       ,'angflag'       ,'tmacd'       ,'dea']]
            gp32.columns=['gpid' ,'s13lastdate','s13lastc','s13id','s13lastmacd','s13lastangflag','s13lasttmacd','s20lastdea']
            gp32=gp32.fillna(0)
            gp32=gp32.set_index('gpid')
            s6=db.groupby('gpid').gpid6.nunique()
            gp6=pd.DataFrame(s6)
            gp6.columns=['s6segs']
            gp=pd.concat([gp22,gp23,gp24,gp3,gp32,gp6],axis=1,join="inner")

            gp['s13len1']=gp.s13len.shift(1) 
            gp=gp.dropna(axis=0)  #drop the first row that is not really segment

            gp['s13len2']=gp.s13len.shift(2)
            gp['s13len3']=gp.s13len.shift(3)
            gp['s13len4']=gp.s13len.shift(4)
            p13=peak_valley_pivots(np.array(db['c']),0.20,-0.20)
            s13sdd=compute_segment_returns(np.array(db['c']),p13)
            #segdrawdown=np.insert(segdrawdown,0,0)
            gp['s13sdd']=pd.Series(s13sdd,index=gp.index)
            gp['s13sdd1']=gp.s13sdd.shift(1)
            gp['s13sdd2']=gp.s13sdd.shift(2)
            gp['s13sdd3']=gp.s13sdd.shift(3)
            gp['s13sdd4']=gp.s13sdd.shift(4)
                        
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
            gp=np.round(gp,decimals=2)
            gp.loc[:,'kmt']=gp.apply(lambda x:'[{s13kd4},{s13kd1}]-[{s13posm4},{s13posm1}]-[{s13tmacd}]'.format(**x),axis=1)
            return gp        

    

    def creatgp6(self,db):
            # group by gpid get sum of md and gpred
        if db.empty==False and len(db)>60:
            gp22=db.groupby('gpid6').sum()[['z6mode']]
            gp22.columns=['s6len'] #len6 :seg6 
            #gp23=db.groupby('gpid')
            gp23=db.groupby('gpid6').max()[['dmzu','umzu','umzd','dmzd','c']]
            gp23.columns=['s6maxdmzu','s6maxumzu','s6maxumzd','s6maxdmzd','s6maxc']                  
            gp24=db.groupby('gpid6').min()[['c']]
            gp24.columns=['s6minc']                  
            idx=db.groupby('gpid6')['id'].transform(min)==db['id']
            gp3=db[idx][['gpid6','date','c','macd', 'dea','tmacd']]
            gp3.columns=['gpid6','s6startdate','s6startc','s6startmacd','s6startdea','s6starttmacd']
            gp3=gp3.fillna(0)
            gp3=gp3.set_index('gpid6')
            idx2=db.groupby('gpid6')['id'].transform(max)==db['id']
            gp32=db[idx2][['gpid6','date'     ,'c'      ,'gpid','s6id','macd'      ,'ang'       ,'tmacd'       ,'posmacd'      ,'dea']]
            gp32.columns=['gpid6','s6lastdate','s6lastc','gpid','s6id','s6lastmacd','s6lastang','s6lasttmacd','s6lastposmacd','s6lastdea']
            gp32=gp32.fillna(0)
            gp32=gp32.set_index('gpid6')
            gp=pd.concat([gp22,gp23,gp24,gp3,gp32],axis=1,join="inner")



            
            gp['s6len1']=gp.s6len.shift(1) 
            gp=gp.dropna(axis=0)  #drop the first row that is not really segment

            gp['s6len2']=gp.s6len.shift(2)
            gp['s6len3']=gp.s6len.shift(3)
            gp['s6len4']=gp.s6len.shift(4)
            p6=peak_valley_pivots(np.array(db['c']),0.10,-0.10)
            #segdrawdown: sdd6
            s6sdd=compute_segment_returns(np.array(db['c']),p6)
            #segdrawdown=np.insert(segdrawdown,0,0)
            gp['s6sdd']=pd.Series(s6sdd,index=gp.index)
            gp['s6sdd1']=gp.s6sdd.shift(1)
            gp['s6sdd2']=gp.s6sdd.shift(2)
            gp['s6sdd3']=gp.s6sdd.shift(3)
            gp['s6sdd4']=gp.s6sdd.shift(4)
            # seg3 up seg seg2 down seg seg1 up seg seg current seg is also key entry               
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


    CONfmore=['sn','s13startdate','s13sdd','s6startdate','s6maxc','s6sdd','s6minc','s13minc','s6lastc','gp6no','s6lastdate'] 
    CONf=['sn','s6startdate','s6sdd','s6minc','s6lastc','gp6no','kmt','s6lastdate']
    CONf13= ['sn','s13startdate','s13sdd','s13minc','s13maxc','s13lastc','s13len','kmt','s6segs','s13lastdate','s13lastangflag']
    def getgp13(self):
        exdb=self.getexdb()
        gp13=self.creatgp13(exdb) 
        gp13['sn']=self.sn
        return gp13
    
    def getgp(self):
        exdb=self.getexdb()
        gp6=self.creatgp6(exdb)
        #gp6['seg1dm']=gp6.apply(lambda x:'{s6sumdmzd1}-{s6sumdmzu1}'.format(**x),axis=1)
        gp13=self.creatgp13(exdb)

        gpn=pd.merge(gp6,gp13 ,left_on='gpid',right_on='gpid') 
        gpn['id']=gpn.index
        gpn=self.sortgpid6(gpn)
        
        
        gpn=np.round(gpn,decimals=3)
        gpn['sn']=self.sn
        return gpn
  
    
    
    
    def getseed1(self):
        db=self.getexdb1()
        try:
            lastkd4id=db.max(axis=0)['kd4']
            lastkd1id=db.max(axis=0)['kd1']
            if lastkd4id>lastkd1id :
                #kd4>kd1 so find the provious kd4's maxid
                kd1proid=db[(db.index<lastkd1id)].max(axis=0)['kd4']
                _dbpro=db[(db.index==kd1proid)][['posmacd','id']]
                _dbpro.columns=['posmacdpro','kdproid']
                _dbpro.loc[:,'newid']='1'
                _dbpro=_dbpro.set_index('newid')                
                _db4=db[(db.index==lastkd4id)][['posmacd','id']]
        
                _db4.columns=['posmacd4','kd4id']
                _db4.loc[:,'newid']='1'
                _db4=_db4.set_index('newid')
                _db1=db[(db.index==lastkd1id)][['posmacd','id']]
                _db1.columns=['posmacd1','kd1id']
                _db1.loc[:,'newid']='1'
                _db1=_db1.set_index('newid')        
                gp= pd.concat([_dbpro,_db1,_db4],axis=1)
                gp.loc[:,'totalkey']=gp.apply(lambda x:  x.kd1id-x.kd4id if x.kd1id>x.kd4id else -(x.kd4id-x.kd1id),axis=1)
                gp.loc[:,'keypos']=gp.apply(self.keypos,axis=1)
                gp.loc[:,'sn']=self.sn
                return gp['keypos'].values[0]
            else:
                return None
            
        except:
            return None

    def keypos(self,x):
        # if x.kd1id>x.kd4id  :
        return "{}{}{}".format(int(x.posmacdpro),int(x.posmacd1),int(x.posmacd4))
       
    def getseed(self):
        db=self.getexdbforseed()
        try:
            lastkd4id=db.max(axis=0)['kd4']
            lastkd1id=db.max(axis=0)['kd1']
            if lastkd4id>lastkd1id :
                #kd4>kd1 so find the provious kd4's maxid
                kd1proid=db[(db.index<lastkd1id)].max(axis=0)['kd4']
                _dbpro=db[(db.index==kd1proid)][['posmacd','id']]
                _dbpro.columns=['posmacdpro','kdproid']
                _dbpro.loc[:,'newid']='1'
                _dbpro=_dbpro.set_index('newid')                
                _db4=db[(db.index==lastkd4id)][['posmacd','id']]
        
                _db4.columns=['posmacd4','kd4id']
                _db4.loc[:,'newid']='1'
                _db4=_db4.set_index('newid')
                _db1=db[(db.index==lastkd1id)][['posmacd','id']]
                _db1.columns=['posmacd1','kd1id']
                _db1.loc[:,'newid']='1'
                _db1=_db1.set_index('newid')        
                gp= pd.concat([_dbpro,_db1,_db4],axis=1)
                gp['totalkey']=gp.apply(lambda x:  x.kd1id-x.kd4id if x.kd1id>x.kd4id else -(x.kd4id-x.kd1id),axis=1)
                gp['keypos']=gp.apply(self.keypos,axis=1)
                gp['sn']=self.sn
                return gp['keypos'].values[0]
            else:
                return None
            
        except:
            return None