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
                  if self.angtype=='t':
                        exdb['ang']= exdb.tmacd
                  else: #default dif
                        exdb['ang']= talib.LINEARREG_ANGLE(np.array(exdb.dif),3)
                  exdb['nextang1']=exdb.ang.shift(1)
                  exdb['nextang2']=exdb.ang.shift(2)
                  
                  exdb['trn']=exdb.apply(self.poschange,axis=1)
                  exdb['gpid']=0
                  exdb['len']=exdb.apply(lambda x: 1 if x.ang>=0 else -1,axis=1)
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
                  gp1=db.groupby('gpid').max()[['h','c']]  # compare power？ angle或stddev
                  gp1.columns=['maxh','maxc']
                  gp2=db.groupby('gpid').min()[['l','c']]
                  gp2.columns=['minl','minc']
                  gp22=db.groupby('gpid').sum()[['len']]
            
                  #gp23=db.groupby('gpid')
                  idx=db.groupby('gpid')['id'].transform(min)==db['id']
                  gp3=db[idx][['gpid','date','h','l','o','c','v'                              ,'sma20','sma30','sma58','sma89','sma120','ang20','ang58','ang89','ang120','trixlang']]
                  gp3.columns=['gpid','startdate','starth','startl','starto','startc','startv','sma20','sma30','sma58','sma89','sma120','ang20','ang58','ang89','ang120','trixlang']
                  gp3=gp3.set_index('gpid')
                  idx2=db.groupby('gpid')['id'].transform(max)==db['id']
                  gp32=db[idx2][['gpid','date','l','c','sma20']]
                  gp32.columns=['gpid','lastdate','lastl','lastc','lastsma20']
                  gp32=gp32.set_index('gpid')
                  idx4 = db.groupby('gpid')['l'].transform(min)==db['l']
                  gp4 = db[idx4][['gpid','id']]
                  gp4=gp4.set_index('gpid')
                  gp=pd.concat([gp1,gp2,gp22,gp3,gp32],axis=1,join="inner")
                  #gp=pd.concat([gp,gp33],axis=1,join="inner")
                  #return gp33,gp
                  gp['len1']=gp.len.shift(1)
                  gp['len2']=gp.len.shift(2)
                  gp['len3']=gp.len.shift(3)
                  gp['maxh1']=gp.maxh.shift(1).abs()
                  gp['maxh2']=gp.maxh.shift(2).abs()
                  gp['maxh3']=gp.maxh.shift(3).abs()
                  gp['minl1']=gp.minl.shift(1)
                  gp['minl2']=gp.minl.shift(2)
                  gp['minc1']=gp.minc.shift(1)
                  gp['ang581']=gp.ang58.shift(1)
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
                  gp['startc1']=gp.startc.shift(1)
                  gp['startc2']=gp.startc.shift(2)
                  gp['startc3']=gp.startc.shift(3)
                  gp['lastc1']=gp.lastc.shift(1)
                  gp['lastc2']=gp.lastc.shift(2)
                  gp['lastc3']=gp.lastc.shift(3)
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
            wdb.c=exdb.c.resample('w').min()
            wdb.v=exdb.v.resample('w').sum()
            #wdb=wdb[wdb.o.notnull()]
            wdb=wdb.dropna(axis=0) 
            wdb['id']=pd.Series(range(len(wdb)),index=wdb.index)
            wdb['date']=wdb.index
            
            self.db=wdb.set_index('id')
            self.db.date=pd.to_datetime(self.db.date)



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
            if findtype=='t':
                  result=self.keyfindt(gp)
            if result.empty==False:
                  self.statics(result)	
            cur=datetime.datetime.now().strftime('%Y-%m-01')
            return result, result[result.startdate>cur][['startdate','sn','len','len1']]
      
      
      def singlefind(self,sn,findtype='t'):
            stobj=STDTB("{}{}.txt".format(ROOTPATH,sn),findtype[0])
            #week obj?
            gp=stobj.getgp()
            
            if findtype=='t':
                  return self.keyfindt(gp)
            
      
      
      # angtype :a
                       
      # angtype :t   
      CONt=['sn','startdate','rat','len','len1','sma20','sma58','startc','lastc','minc','minl','minl1','ang58']
      def keyfindt(self,gp):
            return gp[(gp.len1<0)&(gp.ang581<0)&(gp.ang58>0)&(gp.startc>gp.sma20)&(gp.startc>gp.sma58)          
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
            

def main():
    #main1()
      #dofindsh6(findtype='a1')
      #dofindsh6(findtype='m4')
      
      a=ANALYSIS()
      a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2])
      #if (sys.argv[2]=='t'):
            #a.batsavegp(pat=sys.argv[1],angtype=sys.argv[2],cyctype='W')
      

if __name__=="__main__":
      main()
 
      

