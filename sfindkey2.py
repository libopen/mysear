import pandas as pd
import sys,os
import numpy as np
import talib 
from time import ctime,sleep
import time
import datetime
from datetime import timedelta
def startTime():
      return time.time()
def ticT(startTime):
      useTime=time.time()-startTime
      return round(useTime,3)

ROOTPATH='/home/lib/mypython/export/'
   
      
class STDTB(object):
      
      def __init__(self,file,angtype='f'):
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
            
      def poschange(self,x):
            if (x.nextang1>0 and x.nextang2>0 and x.ang<0 ) or (x.nextang1<0 and x.nextang2<0 and x.ang>0):
                  return x.id
            else:
                  return 0     
      def regroup(self,db):
            curid=0
            for index,row in db.iterrows():
                  if row['trn']!=0:
                        curid=row['trn']
                  db.loc[index,'gpid']=curid
            return db 
      def getexdb(self):
            try:
                  exdb=self.db
                  exdb['dif'],exdb['dea'],exdb['macd']=talib.MACD(np.array(exdb.c),10,20,6) # change
                  exdb['trixl']=talib.TRIX(np.array(exdb.c),12) 
                  exdb['trixs']=talib.SMA(np.array(exdb.trixl),9)
                  exdb['trixlang']=talib.LINEARREG_ANGLE(np.array(exdb.trixl),3) 
                  exdb['difang']  =talib.LINEARREG_ANGLE(np.array(exdb.dif),3) 
                  exdb['tmacd']=exdb.trixl-exdb.trixs
                  exdb['id']=exdb.index
                  exdb['ang10']= talib.LINEARREG_ANGLE(np.array(exdb.dif),3)
                  exdb['sma20']=talib.SMA(np.array(exdb.c),20)
                  exdb['up20']=exdb.apply(lambda x: 1 if (x.c>=x.sma20) else 0 ,axis=1)
                  exdb['ang20']= talib.LINEARREG_ANGLE(np.array(exdb.sma20),3)     #change
                  exdb['sma30']=talib.SMA(np.array(exdb.c),30)
                  exdb['ang30']= talib.LINEARREG_ANGLE(np.array(exdb.sma30),3)
                  exdb['sma58']=talib.SMA(np.array(exdb.c),58)
                  exdb['sma89']=talib.SMA(np.array(exdb.c),89)
                  exdb['sma120']=talib.SMA(np.array(exdb.c),120)
                  exdb['ang58']=talib.LINEARREG_ANGLE(np.array(exdb.sma58),3)
                  exdb['ang89']=talib.LINEARREG_ANGLE(np.array(exdb.sma89),3)
                  exdb['ang120']=talib.LINEARREG_ANGLE(np.array(exdb.sma120),3)
                  exdb['uphelf']=exdb.apply(lambda x: 1 if (x.sma89>=x.sma120)&(x.ang120>0) else 0 ,axis=1)
                  #exdb['ang']= talib.LINEARREG_ANGLE(np.array(exdb.dea),3)     #change use macd so much little perords 
                  if self.angtype=='a':
                        exdb['ang']= talib.LINEARREG_ANGLE(np.array(exdb.dea),3)     #change
                  elif self.angtype=='m':
                        #exdb['ang']= talib.LINEARREG_ANGLE(np.array(exdb.macd),3)     #change
                        exdb['ang']= exdb.macd
                  elif self.angtype=='ma':
                        exdb['ang']= talib.LINEARREG_ANGLE(np.array(exdb.macd),3)     #change
                  elif self.angtype=='t':
                        #exdb['ang']= talib.LINEARREG_ANGLE(np.array(exdb.macd),3)     #change
                        exdb['ang']= exdb.tmacd
                  elif self.angtype=='2':
                        exdb['ang']= exdb['ang20']     #change
                  elif self.angtype=='5':
                        exdb['ang']= exdb.ang55     #change						
                  else: #default dif
                        exdb['ang']= talib.LINEARREG_ANGLE(np.array(exdb.dif),3)
                  exdb['nextang1']=exdb.ang.shift(1)
                  exdb['nextang2']=exdb.ang.shift(2)
                  
                  exdb['trn']=exdb.apply(self.poschange,axis=1)
                  exdb['gpid']=0
                  exdb['len']=exdb.apply(lambda x: 1 if x.ang>=0 else -1,axis=1)
                  exdb['lenmcd']=exdb.apply(lambda x: 1 if x.macd>=0 else -1,axis=1)
                  exdb['lendif']=exdb.apply(lambda x: 1 if x.dif>=0 else -1,axis=1)
                  exdb['maxang']=abs(exdb.ang) 
                  exdb['postrix']=exdb.apply(lambda x: 1 if x.trixl>x.trixs else -1,axis=1)
                  exdb['wdate']=(exdb.date+timedelta(days=1)).dt.to_period('W').apply(lambda r:r.start_time)-timedelta(days=1)
                  #exdb['doji5']=exdb.apply(lambda x: 1 if (x.h>=x.l*1.05) and x.c>=(x.l+((x.h-x.l)/3.0)) and  x.c<(x.l+((x.h-x.l)*2.0/3.0)) and x.o>=(x.l+((x.h-x.l)/3.0)) and x.o<(x.l+((x.h-x.l)*2.0/3.0))  else 0,axis=1)
                  
                  
            # drop Nan rows
            #db=exdb.dropna(axis=0)
           
                  return self.regroup(exdb)
            except:
                  pass
                  #print (self.sn)
                  
                  
      
      def creatgp(self,db):
                  # group by gpid get sum of md and gpred
            if db.empty==False and len(db)>60:
                  gp1=db.groupby('gpid').max()[['maxang','h','c']]  # compare power？ angle或stddev
                  gp1.columns=['maxang','maxh','maxc']
                  gp12=db.groupby('gpid').std()[['ang']]
                  #gp12.columns=['ang']
                  gp2=db.groupby('gpid').min()[['l','c']]
                  gp2.columns=['minl','minc']
                  gp22=db.groupby('gpid').sum()[['len','lenmcd','lendif','postrix','up20','uphelf']]
            
                  #gp23=db.groupby('gpid')
                  idx=db.groupby('gpid')['id'].transform(min)==db['id']
                  gp3=db[idx][['gpid','date','h','l','o','c','v','trixl','macd','postrix','sma20','ang20','sma30','sma58','ang58','sma89','sma120','ang89','ang120','trixlang']]
                  gp3.columns=['gpid','startdate','starth','startl','starto','startc','startv','starttrixl1','startmacd','startpostrix','start20','startang20','sma30','sma58','ang58','sma89','sma120','ang89','ang120','trixlang']
                  gp3=gp3.set_index('gpid')
                  idx2=db.groupby('gpid')['id'].transform(max)==db['id']
                  gp32=db[idx2][['gpid','date','l','c','trixl','postrix']]
                  gp32.columns=['gpid','lastdate','lastl','lastc','lasttrixl','lastpostrix']
                  gp32=gp32.set_index('gpid')
            
            
                  gp=pd.concat([gp1,gp12,gp2,gp22,gp3,gp32],axis=1,join="inner")
                  #gp=pd.concat([gp,gp33],axis=1,join="inner")
                  #return gp33,gp
                  gp['len1']=gp.len.shift(1)
                  gp['len2']=gp.len.shift(2)
                  gp['len3']=gp.len.shift(3)
                  gp['maxh1']=gp.maxh.shift(1).abs()
                  gp['maxh2']=gp.maxh.shift(2).abs()
                  gp['maxh3']=gp.maxh.shift(3).abs()
                  gp['maxh4']=gp.maxh.shift(4).abs()
                  gp['minl1']=gp.minl.shift(1)
                  gp['minl2']=gp.minl.shift(2)
                  gp['minl3']=gp.minl.shift(3)
                  gp['minl4']=gp.minl.shift(4)
                  gp['prlenmcd1']=gp.lenmcd.shift(1)
                  gp['prlenmcd2']=gp.lenmcd.shift(2)
                  gp['prlenmcd3']=gp.lenmcd.shift(3)
                  gp['prang1']=gp.ang.shift(1)
                  gp['prang2']=gp.ang.shift(2)
                  gp['ang581']=gp.ang58.shift(1)
                  gp['maxang1']=gp.maxang.shift(1)
                  gp['maxang2']=gp.maxang.shift(2)
                  gp['prlendif1']=gp.lendif.shift(1)
                  gp['prlendif2']=gp.lendif.shift(2)
                  gp['prlendif3']=gp.lendif.shift(3)
                  gp['prstarttrixl2']=gp.starttrixl1.shift(1)
                  gp['prstarttrixl3']=gp.starttrixl1.shift(2)
                  gp['prstarttrixl4']=gp.starttrixl1.shift(3)
                  gp['postrix1']=gp.postrix.shift(1)
                  gp['postrix2']=gp.postrix.shift(2)
                  #gp['prred3']=gp.red.shift(3)
                  gp['startl1']=gp.startl.shift(1)
                  gp['sn']=self.sn
                  gp['gpid']=gp.index
                  gp['rat']=gp.apply(lambda x: (x.maxh/x.startc-1)*100 if x.len>0 else  -(x.maxh1/x.minl-1)*100,axis=1)
                  gp['prrat1']=gp.rat.shift(1)
                  gp['prrat2']=gp.rat.shift(2)
                  #future 
                  gp['fuminl1']=gp.minl.shift(-1)
                  gp['fulen1']=gp.len.shift(-1)
                  gp['fumaxh2']=gp.maxh.shift(-2)
                  gp['fulen2']=gp.len.shift(-2)
                  gp['fuminl2']=gp.minl.shift(-3)
                  gp['min23']=gp.apply(lambda x :min(x.minl2,x.minl3),axis=1)
                  gp['lentrix']=gp.apply(lambda x :x.starttrixl1-x.lasttrixl if x.starttrixl1>x.lasttrixl else x.lasttrixl-x.starttrixl1,axis=1)
                  gp['lentrix1']=gp.lentrix.shift(1)
                  gp['lentrix2']=gp.lentrix.shift(2)
                  gp['lentrix3']=gp.lentrix.shift(3)
                  gp['lentrix4']=gp.lentrix.shift(4)
                  gp['startc1']=gp.startc.shift(1)
                  gp['startc2']=gp.startc.shift(2)
                  gp['startc3']=gp.startc.shift(3)
                  gp['lastc1']=gp.lastc.shift(1)
                  gp['lastc2']=gp.lastc.shift(2)
                  gp['lastc3']=gp.lastc.shift(3)
                  gp['startpostrix1']=gp.startpostrix.shift(1)
                  gp['startpostrix2']=gp.startpostrix.shift(2)
                  gp['lastpostrix1']=gp.lastpostrix.shift(1)
                  gp['lastpostrix2']=gp.lastpostrix.shift(2)
                  gp['lasttrixl1']=gp.lasttrixl.shift(1)
                  gp['starttrixl2']=gp.starttrixl1.shift(2)
                  gp['ifup20']=gp.apply(lambda x :1 if x.startc>x.start20 else 0,axis=1)
                  gp['startang20_1']=gp.startang20.shift(1)
                  gp['startang20_2']=gp.startang20.shift(2)
                  gp['prup201']=gp.up20.shift(1)
                  gp['prup202']=gp.up20.shift(2)
                  return gp        
      def getgp(self):
            try:
                  db=self.getexdb()
                  return self.creatgp(db)
            except:
                  #print('get gp failure')
                  return None
      def getgpbyno(self,refid):
            db=self.getexdb()
            gp=self.creatgp(db)
            return gp[gp.index>=refid][['len','minl','maxh','maxang','lendif']].head()
      def mainstream(self):
            try:
                  db=self.getexdb()[['date','gpid','h','c']]
                  if db is not None:
                        gp=self.getgp()[['gpid','len','len1','len2','len3']]
                        df1=pd.merge(db,gp,left_on='gpid',right_on='gpid')
                        df1['up']=df1.apply(lambda x:1 if x.len>0 else 0,axis=1)
                        df1['do']=df1.apply(lambda x:1 if x.len<0 else 0,axis=1)
                        return df1
            except:
                  pass
            
class STWTB(STDTB):
     
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
      #def getexdb(self):
            #exdb=self.db
            #exdb['dif'],exdb['dea'],exdb['macd']=talib.MACD(np.array(exdb.c),10,20,6) # change
            #exdb['id']=exdb.index
            ##exdb['ang']= talib.LINEARREG_ANGLE(np.array(exdb.macd),3)     #change use macd so much little perords 
            #if self.angtype=='a':
                  #exdb['ang']= talib.LINEARREG_ANGLE(np.array(exdb.dea),3)     #default
            #elif self.angtype=='m':
                  #exdb['ang']= talib.LINEARREG_ANGLE(np.array(exdb.macd),3)     #change
            #else: #default dif
                  #exdb['ang']= talib.LINEARREG_ANGLE(np.array(exdb.dif),3)            
            #exdb['nextang']=exdb.ang.shift(1)
            #exdb['trn']=exdb.apply(self.poschange,axis=1)
            #exdb['gpid']=0
            #exdb['len']=exdb.apply(lambda x: 1 if x.ang>=0 else -1,axis=1)
            #exdb['lenmcd']=exdb.apply(lambda x: 1 if x.macd>=0 else -1,axis=1)
            #exdb['lendif']=exdb.apply(lambda x: 1 if x.dif>=0 else -1,axis=1)
            #exdb['maxang']=abs(exdb.ang) 
            #db=exdb.dropna(axis=0)
            #return self.regroup(db) 









class ANALYSIS:
              

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
      
       
      
      
      def batsavegp(self,pat,cyctype='D',angtype='a'):
            snlist=self.getallfile(ROOTPATH,pat)
            result=pd.DataFrame()
            result1=pd.DataFrame()
            i=0
            j=0
            for path in snlist:
                  dbcurrent=result
                  db1=result1
                  if cyctype=='D':
                        stobj=STDTB(path,angtype)
                  else:
                        stobj=STWTB(path,angtype)
                  gp = stobj.getgp()
                  if gp is not None:
                              try:
                                    result=dbcurrent.append(gp)
                                    result1=db1.append(gp.tail(1)[['sn','startdate','len','len1','len2','len3']])
                                    i=i+1
                              except:
                                    print(a.sn)
                                    continue
                  else:
                        j=j+1
                        
                  #if i>3:
                        #break
            if result.empty == False:
                  print("{}{}{}total:{} ,failure:{}".format(pat,angtype,cyctype,i,j))
                  result.to_csv("gp{}{}{}.csv".format(pat,angtype,cyctype)) 	   
                  return result1
            
 
      
                                       
      def batfind(self,pat,findtype,cyctype='D'):
            gp=pd.read_csv("gp{}{}{}.csv".format(pat,findtype[0],cyctype))
            if findtype=='a1':
                  result=self.keyfinda1(gp)
            elif findtype=='a2':
                  result=self.keyfinda2(gp)
            elif findtype=='m1':
                  result=self.keyfindm1(gp)
            elif findtype=='m12':
                  result=self.keyfindm12(gp)
            elif findtype=='m22':
                  result=self.keyfindm22(gp)
            elif findtype=='m2':
                  result=self.keyfindm2(gp)
            elif findtype=='t1':
                  result=self.keyfindt1(gp)
            elif findtype=='t2':
                  result=self.keyfindt2(gp)
            if result.empty==False:
                  self.statics(result)	
            cur=datetime.datetime.now().strftime('%Y-%m-01')
            return result, result[result.startdate>cur][['startdate','sn','len','len1']]
      
      # only find current 
      def cbatfind(self,pat,findtype,cyctype='D',timedelt=10):
            cur=datetime.datetime.now()
            pr10=timedelta(days=timedelt)
            cur=cur-pr10
            gp=pd.read_csv("gp{}{}{}.csv".format(pat,findtype[0],cyctype))
            gp['startdate']=pd.to_datetime(gp['startdate'],format='%Y-%m-%d')
            
            stargp=gp[(gp.startdate>cur.strftime('%Y-%m-%d'))&(gp.len<0)&(gp.len>-4)]
            stargp['minl12']=(stargp['minl']/stargp['minl1']-1)*100
            if findtype=='a1':
                  result=self.ckeyfinda1(stargp)
            elif findtype=='a2':
                  result=self.ckeyfinda2(stargp)
            ##if result.empty==False:
                  ##self.statics(result)	
            return result            
      
      
      
      
      
      def singlefind(self,sn,findtype='a1'):
            stobj=STDTB("{}{}.txt".format(ROOTPATH,sn),findtype[0])
            #week obj?
            gp=stobj.getgp()
            
            if findtype=='a1':
                  return self.keyfinda1(gp)
            elif findtype=='a2':
                  return self.keyfinda2(gp)
            elif findtype=='m1':
                  return self.keyfindm1(gp)
            elif findtype=='m12':
                  return self.keyfindm12(gp)
            elif findtype=='m22':
                  return self.keyfindm22(gp)
            
            elif findtype=='m2':
                  return self.keyfindm2(gp)
            elif findtype=='t1':
                  return self.keyfindt1(gp)
            elif findtype=='t2':
                  return self.keyfindt2(gp)
        
            
      
      
      # angtype :a
      CONa=['startdate','len','len1','minl1','prrat1','len2','minl2','maxh2','prrat2','len3','maxh3','minl3','rat','sn','maxang1','maxang2','fulen1','fuminl1','fulen2','fumaxh2','fuminl2']
      def keyfinda1(self,gp):
            return gp[(gp.len1.abs()<gp.len3.abs())&(gp.maxh2*1.2<gp.maxh3)&
                      (gp.len1<0)&(gp.len3<0)&
                      (gp.len2>5)&(gp.len2<20)&
                      (gp.minl2<gp.minl3)&
                      (abs(gp.minl1-gp.minl2)<gp.minl2*0.1)&
                      (gp.maxang1>1)
            ][self.CONa]
      # at current position use  a1 method to find key 
      def ckeyfinda1(self,gp):
                return gp[(gp.len.abs()<gp.len2.abs())&(gp.maxh1*1.2<gp.maxh2)&
                          (gp.len<0)&(gp.len2<0)&
                          (gp.len1>5)&(gp.len1<30)&
                          (gp.minl1<gp.minl2)&
                          (gp.maxang>1)&
                          (gp.minl12<0)
                ][self.CONa]      
                
      
      
      def keyfinda2(self,gp):
            return gp[(gp.len1<0)&(gp.len2>gp.len1.abs())&(gp.prlendif2<0)&(gp.len2>7)
                      &(gp.postrix1>0)&(gp.minl1*1.03<gp.minl2)&(gp.prrat2>7)
                      ][self.CONa]
 
      def ckeyfinda2(self,gp):
            return gp[(gp.len<0)&(gp.len1>gp.len.abs())&(gp.prlendif1<0)&(gp.len1>7)
                      &(gp.postrix>0)&(gp.minl*1.03<gp.minl1)&(gp.prrat1>7)
                      ][self.CONa2]
      
      # angtype :m 
      CONm=['startdate','len','len1','len2','len3','maxh2','maxh3','minl2','minl3','minl1','rat','sn','postrix1','postrix2','prrat2','fulen1','fuminl1','fumaxh2','fuminl2','fulen2','prlendif1','prlendif2','prlendif3']
      def keyfindm1(self,gp):
            
            # pos1:    turn by macd angtype f
            # pos2:   1. len1 in (3,4)  2.len2 in (8,13)
            # pos3:entrance
            # 
            return gp[ (gp.len1>=-4)&(gp.len1<=-2) & 
                       (gp.len2>=10)&(gp.len2<=15)&
                       (gp.len2<gp.len3.abs())&                                                                                                                                   
                       (gp.postrix1==gp.len1.abs())&
                       (gp.prlendif2<0)&
                       (gp.prrat2>=10) #change this param 
                       
                       
                       ][self.CONm]
      def keyfindm12(self,gp):
            #entrance: len1,len2 is engative and len1<len2
            # 
            # 
            # 
            # 
            return gp[ (gp.len1<0)&(gp.len2>0) & (gp.len1<-6)&
                       (gp.len1.abs()<gp.len2.abs())&(gp.len2>20)&
                       (gp.prlendif1>0)&(gp.prlendif1==gp.len1.abs())                                   
                       
                       ][self.CONm]
      def keyfindm22(self,gp):
            #test
            # 
            # 
            # 
            # 
            return gp[ (gp.len1<0)&(gp.len1>-10)&(gp.len2>0)&(gp.len2<20)&(gp.len3<0)&(gp.len3<-20)&
                       (gp.ifup20==1)&(gp.minl2<=gp.min23)&(gp.startang20_1>0)&(gp.startang20_2>0)&
                       (gp.prstarttrixl2>gp.prstarttrixl3)
                                                          
                       ][self.CONm]      
      
      
      def keyfindm2(self,gp):
            #pos : 
            return gp[ (gp.len1>=-7)&(gp.len1<=-3) & 
                       (gp.len2>=10)&(gp.len2<=15)&
                       (gp.len2<gp.len3.abs())&                                                                                                                                   
                       (gp.postrix1==gp.len1.abs())&(gp.postrix1>0)&
                       #(gp.postrix2>0)&
                       (gp.minl1<gp.minl2)&(gp.minl1>gp.minl2*0.9)
                       #(gp.minl1<gp.min23)
                       ][self.CONm]                                #change this param 
                       
      # angtype :t   
      CONt=['sn','startdate','rat','len','len1','start20','sma58','minc','minl','minl1','ang58']
      def keyfindt1(self,gp):
            # starttrixl1  pos1
            # starttrixl2 pos2
            # starttrixl3 pos3
            # starttrixl4 pos4   1 between 2,3 and 23<34
            return gp[#(gp.len1>-10)&(gp.len1.abs()<gp.len2.abs())&(gp.len2.abs()<gp.len3.abs())&
                      (gp.starttrixl1<gp.prstarttrixl2)&(gp.starttrixl1>gp.prstarttrixl3)&  # 1<2 and 1>3 
                      (gp.prstarttrixl2>gp.prstarttrixl3)&#(gp.prstarttrixl2>gp.prstarttrixl4)&   # 2>3 and 2<4                             # 2>3 2<4
                      (gp.prstarttrixl3<gp.prstarttrixl4)                                 # 3<4 
                      &(gp.minl2<=gp.min23)
                      &(gp.starttrixl1<0)
                      
                    ][self.CONt]      
      def keyfindt2(self,gp):
              # starttrixl1  pos1
              # starttrixl2 pos2
              # starttrixl3 pos3
              # starttrixl4 pos4   1 between 2,3 and 23<34
              #return gp[(gp.len1<0)&(gp.len1.abs()>gp.len2)&(gp.len2.abs()<gp.len3.abs())&
              #          (gp.lentrix1>gp.lentrix2)&(gp.lentrix1<gp.lentrix3)&(gp.lentrix2<gp.lentrix3)&
              #          (gp.maxh3>gp.maxh2)&(gp.maxh2>gp.maxh1)&   # 2>3 and 2<4                             # 2>3 2<4
              #          (gp.minl1<gp.minl3)&(gp.minl1<gp.minl2)
              return gp[(gp.len1<0)&(gp.ang581<0)&(gp.ang58>0)&(gp.startc>gp.start20)&(gp.startc>gp.sma58)          
                      ][self.CONt]            

      def fustatics(self,df):
            print("success fuminl1 below minl1  rate:{}".format(df[df.fuminl1>df.minl1*0.9]['sn'].count()/df.sn.count()))
            print("success fuminl1 below minl2  rate:{}".format(df[df.fuminl1>df.minl2*0.9]['sn'].count()/df.sn.count()))
            print("success fuminl1 below minl3  rate:{}".format(df[df.fuminl1>df.minl3*0.9]['sn'].count()/df.sn.count()))
            print("success fuminl2 below minl1  rate:{}".format(df[df.fuminl2>df.minl1*0.9]['sn'].count()/df.sn.count()))
            print("success fuminl2 below minl2  rate:{}".format(df[df.fuminl2>df.minl2*0.9]['sn'].count()/df.sn.count()))
            print("success fuminl2 below minl3  rate:{}".format(df[df.fuminl2>df.minl3*0.9]['sn'].count()/df.sn.count()))

      def statics(self,df):
            df['startdate']=pd.to_datetime(df['startdate'],format='%Y-%m-%d')
      
            print ("total:")
            for i in [3,5,10]:
                  print("success {} rate:{}".format(i,round(float(df[df.rat>i]['sn'].count()/df.sn.count()),3)))
            
            #print("furture 10 rate:{}".format(df[(df.rat<3)&(df.furrat2>10)]['sn'].count()/df[(df.rat<3)]['sn'].count()))
            for myyear in [2014,2015,2016,2017]:
                  print ("{}:{}".format(myyear,df[(df.startdate.dt.year==myyear)].sn.count()))
                  for i in [3,5,10]:
                        print("success {} rate:{}".format(i,round(float(df[(df.rat>=i)&(df.startdate.dt.year==myyear)]['sn'].count()/df[df.startdate.dt.year==myyear].sn.count()),3)))
                  
  
            find1=pd.DatetimeIndex(df.startdate).to_period("M")
            gp=df.sn.groupby(find1).count()
            print(gp[gp.index>'2014-1-1'].to_csv(sep='\t'))
            
     

      

def main1():
      threadpool=[]
      tasks=[('SH6','m4'),('SZ0','m4'),('SZ3','m4')]
      begintime=startTime()
      pool=threadPoolManager(tasks,threadNum=3)
      pool.waitAllComplete()
      threadpool.append(ticT(begintime))
      print("all finish{}".format(ctime(),))      
def main():
    #main1()
      #dofindsh6(findtype='a1')
      #dofindsh6(findtype='m4')
      
      a=ANALYSIS()
      a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2])
      if (sys.argv[2]=='t'):
            a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2],cyctype='W')
      if (sys.argv[2]=='2'):
            a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2],cyctype='W')
      

if __name__=="__main__":
      #findall(sys.argv[1])
      #main()
      
      #for t in threads:
            #t.setDaemon(False)
            #t.start()

      #for t in threads:
            #t.join() 
      #dofindsh6()
      main()
 
      

