import pandas as pd
import sys,os
import numpy as np
import talib 
from time import ctime,sleep
import time
def startTime():
      return time.time()
def ticT(startTime):
      useTime=time.time()-startTime
      return round(useTime,3)

ROOTPATH='/home/lib/mypython/export/'

  
 
     
      
class STDTB(object):
      
      def __init__(self,file,angtype='f'):
            self.sn=os.path.splitext(file)[0][-6:] 
            self.snpath=file
            self.angtype=angtype
            self.load()
      def load(self):
            self.db=pd.read_csv(self.snpath,header=None,names=['date','o','h','l','c','v','m'])
            
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
            exdb=self.db
            exdb['dif'],exdb['dea'],exdb['macd']=talib.MACD(np.array(exdb.c),10,20,6) # change
            exdb['trixl']=talib.TRIX(np.array(exdb.c),12) 
            exdb['trixs']=talib.SMA(np.array(exdb.trixl),9) 

            exdb['id']=exdb.index
            #exdb['ang']= talib.LINEARREG_ANGLE(np.array(exdb.dea),3)     #change use macd so much little perords 
            if self.angtype=='a':
                  exdb['ang']= talib.LINEARREG_ANGLE(np.array(exdb.dea),3)     #change
            elif self.angtype=='m':
                  exdb['ang']= talib.LINEARREG_ANGLE(np.array(exdb.macd),3)     #change
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
            # drop Nan rows
            #db=exdb.dropna(axis=0)
           
            return self.regroup(exdb)
      
      def creatgp(self,db):
                  # group by gpid get sum of md and gpred
            if db.empty==False and len(db)>60:
                  gp1=db.groupby('gpid').max()[['maxang','h','c']]  # compare power？ angle或stddev
                  gp1.columns=['maxang','maxh','maxc']
                  gp12=db.groupby('gpid').std()[['ang']]
                  #gp12.columns=['ang']
                  gp2=db.groupby('gpid').min()[['l']]
                  gp2.columns=['minl']
                  gp22=db.groupby('gpid').sum()[['len','lenmcd','lendif','postrix']]
            
                  #gp23=db.groupby('gpid')
                  idx=db.groupby('gpid')['id'].transform(min)==db['id']
                  gp3=db[idx][['gpid','date','h','l','o','c','v']]
                  gp3.columns=['gpid','startdate','starth','startl','starto','startc','startv']
                  gp3=gp3.set_index('gpid')
                  idx2=db.groupby('gpid')['id'].transform(max)==db['id']
                  gp32=db[idx][['gpid','date','l','c']]
                  gp32.columns=['gpid','lastdate','lastl','lastc']
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
                  gp['minl1']=gp.minl.shift(1)
                  gp['minl2']=gp.minl.shift(2)
                  gp['minl3']=gp.minl.shift(3)
                  gp['prlenmcd1']=gp.lenmcd.shift(1)
                  gp['prlenmcd2']=gp.lenmcd.shift(2)
                  gp['prlenmcd3']=gp.lenmcd.shift(3)
                  gp['prang1']=gp.ang.shift(1)
                  gp['prang2']=gp.ang.shift(2)
                  gp['maxang1']=gp.maxang.shift(1)
                  gp['maxang2']=gp.maxang.shift(2)
                  gp['prlendif1']=gp.lendif.shift(1)
                  gp['prlendif2']=gp.lendif.shift(2)
                  gp['postrix1']=gp.postrix.shift(1)
                  gp['postrix2']=gp.postrix.shift(2)
                  #gp['prred3']=gp.red.shift(3)
                  gp['startl1']=gp.startl.shift(1)
                  gp['sn']=self.sn
            
                  gp['rat']=(gp.maxc/gp.startc-1)*100
                  gp['prrat1']=gp.rat.shift(1)
                  gp['prrat2']=gp.rat.shift(2)
                  return gp        
      def getgp(self):
            db=self.getexdb()
            return self.creatgp(db)
      
class STWTB2(STDTB):
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
            
      def getexdb(self,dbtype='a'):
            exdb=self.db
            exdb['dif'],exdb['dea'],exdb['macd']=talib.MACD(np.array(exdb.c),10,20,6) # change
            exdb['id']=exdb.index
            #exdb['ang']= talib.LINEARREG_ANGLE(np.array(exdb.macd),3)     #change use macd so much little perords 
            exdb['ang']= talib.LINEARREG_ANGLE(np.array(exdb.dea),3)     #change
            exdb['nextang']=exdb.ang.shift(1)
            exdb['trn']=exdb.apply(self.poschange,axis=1)
            exdb['gpid']=0
            exdb['len']=exdb.apply(lambda x: 1 if x.ang>=0 else -1,axis=1)
            exdb['lenmcd']=exdb.apply(lambda x: 1 if x.macd>=0 else -1,axis=1)
            exdb['lendif']=exdb.apply(lambda x: 1 if x.dif>=0 else -1,axis=1)
            exdb['maxang']=abs(exdb.ang) 
            db=exdb.dropna(axis=0)
            return self.regroup(db) 
class SHWTB:
      
      def __init__(self,file):
            self.sn=os.path.splitext(file)[0][-6:] 
            self.db=pd.read_csv(file,header=None,names=['date','o','h','l','c','v','m'])
      def getexdb(self,dbtype='a'):
            exdb=self.db
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
            wdb['dif'],wdb['dea'],wdb['macd']=talib.MACD(np.array(wdb.c),10,20,6)
            wdb['ang']= talib.LINEARREG_ANGLE(np.array(wdb.dif),3)     #change
            wdb['nextang']=wdb.ang.shift(1)
            wdb['trn']=wdb.apply(poschange,axis=1)
            wdb['gpid']=0
            wdb['len']=wdb.apply(lambda x: 1 if x.ang>=0 else -1,axis=1)
            wdb['lenmcd']=wdb.apply(lambda x: 1 if x.macd>=0 else -1,axis=1)
            wdb['lendif']=wdb.apply(lambda x: 1 if x.dif>=0 else -1,axis=1)
            wdb['maxang']=abs(wdb.ang)
            wdb['date']=wdb.index
            regroup(wdb)          
            return wdb
      def creatgp(self,db):
            
            gp1=db.groupby('gpid').max()[['maxang','h','c']]  # compare power？ angle或stddev
            gp1.columns=['maxang','maxh','maxc']
            gp2=db.groupby('gpid').min()[['l']]
            gp2.columns=['minl']
            gp22=db.groupby('gpid').sum()[['len','lenmcd','lendif']]
      
            #gp23=db.groupby('gpid')
            idx=db.groupby('gpid')['id'].transform(min)==db['id']
            gp3=db[idx][['gpid','date','h','l','o','c','v']]
            gp3.columns=['gpid','startdate','starth','startl','starto','startc','startv']
            gp3=gp3.set_index('gpid')
            idx2=db.groupby('gpid')['id'].transform(max)==db['id']
            gp32=db[idx][['gpid','date','l','c']]
            gp32.columns=['gpid','lastdate','lastl','lastc']
            gp32=gp32.set_index('gpid')
      
      
            gp=pd.concat([gp1,gp2,gp22,gp3,gp32],axis=1,join="inner")
            #gp=pd.concat([gp,gp33],axis=1,join="inner")
            #return gp33,gp
            gp['fur1']=gp.updown.shift(-1)
            gp['fur2']=gp.updown.shift(-2)
            gp['pre1']=gp.updown.shift(1)
            gp['pre2']=gp.updown.shift(2)
            gp['pre3']=gp.updown.shift(3)
            gp['maxh1']=gp.maxh.shift(1).abs()
            gp['maxh2']=gp.maxh.shift(2).abs()
            gp['maxh3']=gp.maxh.shift(3).abs()
            gp['minl1']=gp.minl.shift(1)
            gp['minl2']=gp.minl.shift(2)
            gp['minl3']=gp.minl.shift(3)
            gp['mpre1']=gp.mupdown.shift(1)
            gp['mpre2']=gp.mupdown.shift(2)
            gp['maxlina1']=gp.maxlina.shift(1)
            gp['maxlina2']=gp.maxlina.shift(2)
            gp['mupdown1']=gp.mupdown.shift(1)
            gp['mupdown2']=gp.mupdown.shift(2)      
            gp['startl1']=gp.startl.shift(1)
            gp['sn']=sn
      
            gp['rat']=(gp.maxc/gp.startc-1)*100
            return gp 
 













def getallfile(rootpath,pat):
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

def dofinddetail(snlist,findtype='m4'):
      result=pd.DataFrame()
      for path in snlist:
            #print (path)
            dbcurrent=result
            sn,db=getdb(path, findtype[0])
            gp =  getgp(sn,db,findtype[0])
            if gp is not None:
                  try:
                        if findtype=='a1':
                              result=dbcurrent.append(keyfinda1(gp))
                        elif findtype=='a2':
                              result=dbcurrent.append(keyfinda2(gp))
                        elif findtype=='m4':
                              result=dbcurrent.append(keyfindm4(gp))  
                        elif findtype=='m7':
                              result=dbcurrent.append(keyfindm7(gp))  
                  except:
                        print(sn)
                        continue                         
                         
                           
    
#result.to_csv('myfind.csv')   
      if result.empty==False:
            analysis(result)
            result[result.rat<3].to_csv("{}3.csv".format(findtype))
 


def batsavegp(pat,cyctype='D',angtype='a'):
      snlist=getallfile(ROOTPATH,pat)
      result=pd.DataFrame()
      i=0
      for path in snlist:
            dbcurrent=result
            if cyctype=='D':
                  stobj=STDTB(path,angtype)
            else:
                  stobj=STWTB2(path)
            gp = stobj.getgp()
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
            result.to_csv("gp{}{}{}.csv".format(pat,angtype,cyctype)) 	   

def wbatsavegp(pat,findtype='a1'):
      snlist=getallfile(ROOTPATH,pat)
      result=pd.DataFrame()
      for path in snlist:
            dbcurrent=result
            sn,db=wgetdb(path,findtype[0])
            gp = wgetgp(sn,db,findtype[0])
            if gp is not None:
                  try:
                        result=dbcurrent.append(gp)
                  except:
                        print(sn)
                        continue
      if result.empty == False:
            result.to_csv("wgp{}{}.csv".format(pat,findtype[0])) 	   

				 
def batfind(pat,findtype,cyctype='D'):
      gp=pd.read_csv("gp{}{}{}.csv".format(pat,findtype[0],cyctype))
      if findtype=='a1':
            result=keyfinda1(gp)
      elif findtype=='a2':
            result=keyfinda2(gp)
      if result.empty==False:
            analysis(result)	
      return result
      

def wbatfind(pat,findtype='m4'):
      gp=pd.read_csv("wgp{}{}.csv".format(pat,findtype[0]))
      if findtype=='a1':
            result=keyfinda1(gp)
      elif findtype=='a2':
            result=keyfinda2(gp)
      elif findtype=='m4':
            result=keyfindm4(gp)
      if result.empty==False:
            analysis(result)
     



def survey(mark='SH6',findtype='m4'):
      snlist=getallfile(ROOTPATH,mark)
      dofinddetail(snlist,findtype)      



def singlefind(sn,findtype='m4'):
      if findtype[0]=='a':
            sn,db=createdb_a(ROOTPATH+sn+'.txt')
      elif findtype[0]=='m':
            sn,db=createdb_m(ROOTPATH+sn+'.txt')
                  #print(path)
      result=None
      if db.empty==False and len(db)>60:
            if findtype[0]=='a':
                  gp=makegp_a(sn, db)   
                  if findtype=='a1':
                        result=keyfinda1(gp)
                  elif findtype=='a2':
                        result=keyfinda2(gp)
  
            elif findtype[0]=='m':
                  gp=makegp_m(sn, db)
                  if findtype=='m4':
                        result=keyfindm4(gp)
                  elif findtype=='m7':
                        result=keyfindm7(gp)
      return result


#class a
CONa1=['startdate','len1','len3','maxh2','maxh3','len2','minl2','minl3','minl1','rat','sn','maxang1','maxang2']
def keyfinda1(gp):
      return gp[(gp.len1.abs()<gp.len3.abs())&(gp.maxh2*1.2<gp.maxh3)&
                (gp.len1<0)&(gp.len3<0)&
                (gp.len2>5)&(gp.len2<20)&
                (gp.minl2<gp.minl3)&
                (abs(gp.minl1-gp.minl2)<gp.minl2*0.1)&
                (gp.maxang1>1)
      ][CONa1]

CONa2=['len1','len2','len3','prlendif1','prlendif2','postrix1','postrix2','minl1','minl2','minl3','prrat1','prrat2','startdate','rat','len','sn','maxang1','maxang2','maxh1','maxh2','maxh3']
def keyfinda2(gp):
      return gp[(gp.len1<0)&(gp.len2>gp.len1.abs())&(gp.prlendif2<0)&(gp.len2>7)
                &(gp.postrix1>0)&(gp.minl1*1.03<gp.minl2)&(gp.prrat2>7)
                ][CONa2]

#class m
def keyfindm4(gp):
      
      # pos1:     important 
      # pos2:      rat>3 时，pre1.abs()>pre3.abs() 占90%
      # pos3:entrance
      # rat >3 77% (gp.pre1<0)&(gp.pre1.abs()>20)&(gp.pos_dif1<0)&(gp.pos_dif3>0) 
      return gp[ (gp.pre1<0) &                                                                                                                                        
                 (gp.pre1.abs()>20) & 
                 (gp.pos_dif1<0)&
                 (gp.pos_dif3>0)&
                 (gp.pre1.abs()>gp.pre3.abs())&
                 (gp.maxh1<gp.maxh2)&(gp.maxh2<gp.maxh3)
                 ][GPTITLE]



def keyfindm7(gp):
      #pos : 
      return gp[(gp.pre1<-3)&(gp.pre1>-10)&
                (gp.startl1==gp.minl1)&
                (gp.minl1>gp.minl3)&(abs(gp.minl1-gp.minl3)<gp.minl1*0.02)&
                (gp.pre2>abs(gp.pre1))&
                (abs(gp.pre3)>gp.pre2)][GPTITLE]




def analysis(df):
      df['startdate']=pd.to_datetime(df['startdate'],format='%Y-%m-%d')

      print ("total:")
      #print("success 3 rate:{}".format(df[(df.rat>=3)]['sn'].count()/df.sn.count()))
      print("success 5 rate:{}".format(df[df.rat>=5]['sn'].count()/df.sn.count()))
      print("success 10 rate:{}".format(df[df.rat>=10]['sn'].count()/df.sn.count()))
      #print("furture 10 rate:{}".format(df[(df.rat<3)&(df.furrat2>10)]['sn'].count()/df[(df.rat<3)]['sn'].count()))
      print ("15:")
      #print("success 3 rate:{}".format(df[(df.rat>=3)&(df.startdate>'2015/01/01/')&(df.startdate<'2015/12/31')]['sn'].count()/df[(df.startdate>'2015/01/01/')&(df.startdate<'2015/12/31')].sn.count()))
      print("success 5 rate:{}".format(df[(df.rat>=5)&(df.startdate>'2014/01/01/')&(df.startdate<'2015/12/31')]['sn'].count()/df[(df.startdate>'2014/01/01/')&(df.startdate<'2015/12/31')].sn.count()))
      print("success 10 rate:{}".format(df[(df.rat>=10)&(df.startdate>'2014/01/01/')&(df.startdate<'2015/12/31')]['sn'].count()/df[(df.startdate>'2014/01/01/')&(df.startdate<'2015/12/31')].sn.count()))
      print ("16:")
      #print("success 3 rate:{}".format(df[(df.rat>=3)&(df.startdate>'2016/01/01/')&(df.startdate<'2016/12/31')]['sn'].count()/df[(df.startdate>'2016/01/01/')&(df.startdate<'2016/12/31')].sn.count()))
      print("success 5 rate:{}".format(df[(df.rat>=5)&(df.startdate>'2016/01/01/')&(df.startdate<'2016/12/31')]['sn'].count()/df[(df.startdate>'2016/01/01/')&(df.startdate<'2016/12/31')].sn.count()))
      print("success 10 rate:{}".format(df[(df.rat>=10)&(df.startdate>'2016/01/01/')&(df.startdate<'2016/12/31')]['sn'].count()/df[(df.startdate>'2016/01/01/')&(df.startdate<'2016/12/31')].sn.count()))

      find1=pd.DatetimeIndex(df.startdate).to_period("M")
      gp=df.sn.groupby(find1).count()
      print(gp[gp.index>'2015-1-31'].to_csv(sep='\t'))



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
      dofindsh6(findtype='m4')
      

if __name__=="__main__":
      #findall(sys.argv[1])
      #main()
      
      #for t in threads:
            #t.setDaemon(False)
            #t.start()

      #for t in threads:
            #t.join() 
      dofindsh6()
      #main()
 
      

