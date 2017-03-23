import pandas as pd
import sys,os
import numpy as np
import talib 
from queue import Queue
from threading import Thread
from multiprocessing import process
import threading
from time import ctime,sleep
import time
#result = pd.DataFrame()
def startTime():
      return time.time()
def ticT(startTime):
      useTime=time.time()-startTime
      return round(useTime,3)


class threadPoolManager:
      def __init__(self,tasks,worknum=3,threadNum=3):
            self.workQueue=Queue()
            self.threadPool=[]
            self.__initWorkQueue(tasks)
            self.__initThreadPool(threadNum)
            
      def __initWorkQueue(self,tasks):
            for i in tasks:
                  self.workQueue.put((dofind,i))
                  
      def __initThreadPool(self,threadNum):
            for i in range(threadNum):
                  self.threadPool.append(work(self.workQueue))
                  
      def waitAllComplete(self):
            for i in self.threadPool:
                  if i.isAlive():
                        i.join()

class work(Thread):
      def __init__(self,workQueue):
            Thread.__init__(self)
            self.workQueue=workQueue
            self.start()
      def run(self):
            while True:
                  if self.workQueue.qsize():
                        do,args=self.workQueue.get(block=False)
                        do(args[0],args[1])
                        self.workQueue.task_done()
                  else:
                        break
                        
                  
            

ROOTPATH='/home/lib/mypython/export/'
GPTITLE=['sn','startdate','rat','updown','minl','maxh','furmaxh1','furminl1','furrat1','fur2','furmaxh2','furminl2','furrat2','nflat']
GPTITLE2=['sn','startdate','rat','updown','mupdown','minl','pre1','mpre1','pre2','mpre2','pre3','minl1','minl2','minl3']

# db method
def midpoint(x):
      if x.c>(x.l+(x.h-x.l)/2):
            return 'u'
      else:
            return 'd'
def red(x):
      if x.c>x.o :
            return 1
      else:
            return -1

def regroup(db):
      curid=0
      for index,row in db.iterrows():
            if row['trn']!=0:
                  curid=row['trn']
            db.loc[index,'gpid']=curid
      return db

def keyred(x):
      if x.macd>0 and x.dif>0 and x.dea<0 :
            return 1
      else :
            return 0



def poschange_a(x):
      if (x.mt>0 and x.lina<0 ) or (x.mt<0 and x.lina>0):
            return x.id
      else:
            return 0



def createdb_a(file):
      db=None
      try:
            base=os.path.splitext(file)[0]
            sn=base[-6:]
            db=pd.read_csv(file,header=None,names=['date','o','h','l','c','v','m'])
            db['dif'],db['dea'],db['macd']=talib.MACD(np.array(db.c),10,20,6) # change
            db['id']=db.index
            db['lina']= talib.LINEARREG_ANGLE(np.array(db.dea),3)     #change
            db['mt']=db.lina.shift(1)
            db['trn']=db.apply(poschange_a,axis=1)
            db['gpid']=0
            db['updown']=db.apply(lambda x: 1 if x.lina>=0 else -1,axis=1)
            db['mupdown']=db.apply(lambda x: 1 if x.macd>=0 else -1,axis=1)
            db['maxang']=abs(db.lina)
            regroup(db)

      finally:
            return sn,db


def makegp_a(sn,db):
      # group by gpid get sum of md and gpred
      gp1=db.groupby('gpid').max()[['maxang','h','c']]  # compare power？ angle或stddev
      gp1.columns=['maxlina','maxh','maxc']
      gp12=db.groupby('gpid').std()[['lina']]
      gp2=db.groupby('gpid').min()[['l']]
      gp2.columns=['minl']
      gp22=db.groupby('gpid').sum()[['updown','mupdown']]

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
      gp['lina1']=gp.lina.shift(1)
      gp['lina2']=gp.lina.shift(2)
      gp['maxlina1']=gp.maxlina.shift(1)
      gp['maxlina2']=gp.maxlina.shift(2)
      gp['mupdown1']=gp.mupdown.shift(1)
      gp['mupdown2']=gp.mupdown.shift(2)
      #gp['prred3']=gp.red.shift(3)
      gp['startl1']=gp.startl.shift(1)
      gp['sn']=sn

      gp['rat']=(gp.maxc/gp.startc-1)*100
      return gp



def wcreatedb_a(file):
      db=None
      try:
            base=os.path.splitext(file)[0]
            sn=base[-6:]
            db=pd.read_csv(file,header=None,names=['date','o','h','l','c','v','m'])
            db.date=pd.to_datetime(db.date)
            db=db.set_index('date')
            wdb=db.resample('w').last()
            wdb.h=db.h.resample('w').max()
            wdb.o=db.o.resample('w').first()
            wdb.c=db.c.resample('w').min()
            wdb.v=db.v.resample('w').sum()
            wdb=wdb[wdb.o.notnull()]
            wdb['id']=pd.Series(range(len(wdb)),index=wdb.index)
            wdb['dif'],wdb['dea'],wdb['macd']=talib.MACD(np.array(wdb.c),10,20,6)
            wdb['lina']= talib.LINEARREG_ANGLE(np.array(wdb.dif),3)     #change
            wdb['mt']=wdb.lina.shift(1)
            wdb['trn']=wdb.apply(poschange_a,axis=1)
            wdb['gpid']=0
            wdb['updown']=wdb.apply(lambda x: 1 if x.lina>=0 else -1,axis=1)
            wdb['mupdown']=wdb.apply(lambda x: 1 if x.macd>=0 else -1,axis=1)
            wdb['maxang']=abs(wdb.lina)
            wdb['date']=wdb.index
            regroup(wdb)          
      finally:
            return sn,wdb

def wmakegp_a(sn,db):
      # group by gpid get sum of md and gpred
      gp1=db.groupby('gpid').max()[['maxang','h','c']]  # compare power？ angle或stddev
      gp1.columns=['maxlina','maxh','maxc']
      gp2=db.groupby('gpid').min()[['l']]
      gp2.columns=['minl']
      gp22=db.groupby('gpid').sum()[['updown','mupdown']]

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


def poschange_m(x):
      if (x.mt>0 and x.macd<0 ) or (x.mt<0 and x.macd>0):
            return x.id
      else:
            return 0

def wcreatedb_m(file):
    db=None
    try:
          base=os.path.splitext(file)[0]
          sn=base[-6:]
          #print(sn)
          db=pd.read_csv(file,header=None,names=['date','o','h','l','c','v','m'])
          db.date=pd.to_datetime(db.date)
          db=db.set_index('date')
          wdb=db.resample('w').last()
          wdb.h=db.h.resample('w').max()
          wdb.o=db.o.resample('w').first()
          wdb.c=db.c.resample('w').min()
          wdb.v=db.v.resample('w').sum()
          wdb=wdb[wdb.o.notnull()]
          wdb['id']=pd.Series(range(len(wdb)),index=wdb.index)
          wdb['dif'],wdb['dea'],wdb['macd']=talib.MACD(np.array(wdb.c),10,20,6)
          wdb['mt']=wdb.macd.shift(1)
          wdb['trn']=wdb.apply(poschange_m,axis=1)
          wdb['gpid']=0 
          wdb['updown']=wdb.apply(lambda x: 1 if x.macd>=0 else -1,axis=1)
          wdb['lina']=talib.LINEARREG_ANGLE(np.array(wdb.dif),3)
          wdb['nflat']=wdb.apply(lambda x: 1 if abs(x.lina)<=0.3 else 0,axis=1)
          wdb['date']=wdb.index
          regroup(wdb)          
    finally:
          return sn,wdb

def wmakegp_m(sn,db):
      # group by gpid get sum of md and gpred
      gp1=db.groupby('gpid').sum()[['updown','nflat']]
      gp2=db.groupby('gpid').max()[['h','c',]]
      gp2.columns=['maxh','maxc']
      gp22=db.groupby('gpid').min()[['l']]
      gp22.columns=['minl']
      #gp23=db.groupby('gpid')
      idx=db.groupby('gpid')['id'].transform(min)==db['id']
      gp3=db[idx][['gpid','date','h','l','o','c','v']]
      gp3.columns=['gpid','startdate','starth','startl','starto','startc','startv']
      gp3=gp3.set_index('gpid')
      idx2=db.groupby('gpid')['id'].transform(max)==db['id']
      gp32=db[idx][['gpid','date','l','c']]
      gp32.columns=['gpid','lastdate','lastl','lastc']
      gp32=gp32.set_index('gpid')

      idx1=db.groupby('gpid')['l'].transform(min)==db['l']
      gp33=db[idx1][['gpid','id','macd']]
      gp33.columns=['gpid','minlid','minlmacd']
      gp33=gp33.set_index('gpid')

      gp=pd.concat([gp1,gp2,gp22,gp3,gp32,gp33],axis=1,join="inner")
      #gp=pd.concat([gp,gp33],axis=1,join="inner")
      #return gp33,gp
      gp['turnid']=gp.updown.abs()-(gp.minlid-gp.index)
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
  
      gp['startl1']=gp.startl.shift(1)
      gp['furmaxh1']=gp.maxh.shift(-1) #this highest at next scope 
      gp['furmaxh2']=gp.maxh.shift(-2) #this highest at next scope 
      gp['furminl1']=gp.minl.shift(-1)
      gp['furminl2']=gp.minl.shift(-2)
      
      gp['sn']=sn

      gp['rat']=(gp.maxc/gp.startc-1)*100
      gp['furrat1']=gp.rat.shift(-1)
      gp['furrat2']=gp.rat.shift(-2)
      return gp

          
def createdb_m(file):
      #file=sys.argv[1]
      db=None
      try:
            base=os.path.splitext(file)[0]
            sn=base[-6:]
            #print(sn)
            db=pd.read_csv(file,header=None,names=['date','o','h','l','c','v','m'])
            db['id']=db.index
            db['dif'],db['dea'],db['macd']=talib.MACD(np.array(db.c),10,20,9)
            db['absmacd']=db.macd.abs()
            db['mt']=db.macd.shift(1)
            db['trn']=db.apply(poschange_m,axis=1)
            db['gpid']=0
            db['red']=db.apply(red,axis=1)
            db['updown']=db.apply(lambda x: 1 if x.macd>=0 else -1,axis=1)
            db['pos_dif']=db.apply(lambda x: 1 if x.dif>=0 else -1,axis=1)
            db['lina']=talib.LINEARREG_ANGLE(np.array(db.dif),3)
            db['nflat']=db.apply(lambda x: 1 if abs(x.lina)<=0.3 else 0,axis=1)
            regroup(db)

      finally:
            return sn,db





def makegp_m(sn,db):
      # group by gpid get sum of md and gpred
      gp1=db.groupby('gpid').sum()[['updown','pos_dif','nflat']]
      gp2=db.groupby('gpid').max()[['h','c','absmacd']]
      gp2.columns=['maxh','maxc','absmacd']
      gp22=db.groupby('gpid').min()[['l']]
      gp22.columns=['minl']
      #gp23=db.groupby('gpid')
      idx=db.groupby('gpid')['id'].transform(min)==db['id']
      gp3=db[idx][['gpid','date','h','l','o','c','v']]
      gp3.columns=['gpid','startdate','starth','startl','starto','startc','startv']
      gp3=gp3.set_index('gpid')
      idx2=db.groupby('gpid')['id'].transform(max)==db['id']
      gp32=db[idx][['gpid','date','l','c']]
      gp32.columns=['gpid','lastdate','lastl','lastc']
      gp32=gp32.set_index('gpid')

      idx1=db.groupby('gpid')['l'].transform(min)==db['l']
      gp33=db[idx1][['gpid','id','macd']]
      gp33.columns=['gpid','minlid','minlmacd']
      gp33=gp33.set_index('gpid')

      gp=pd.concat([gp1,gp2,gp22,gp3,gp32,gp33],axis=1,join="inner")
      #gp=pd.concat([gp,gp33],axis=1,join="inner")
      #return gp33,gp
      gp['turnid']=gp.updown.abs()-(gp.minlid-gp.index)
      gp['fur1']=gp.updown.shift(-1)
      gp['fur2']=gp.updown.shift(-2)
      gp['pre1']=gp.updown.shift(1)
      gp['pre2']=gp.updown.shift(2)
      gp['pre3']=gp.updown.shift(3)
      gp['maxh1']=gp.maxh.shift(1).abs()
      gp['maxh2']=gp.maxh.shift(2).abs()
      gp['maxh3']=gp.maxh.shift(3).abs()
      gp['pos_dif1']=gp.pos_dif.shift(1)
      gp['pos_dif2']=gp.pos_dif.shift(2)
      gp['pos_dif3']=gp.pos_dif.shift(3)
      gp['minl1']=gp.minl.shift(1)
      gp['minl2']=gp.minl.shift(2)
      gp['minl3']=gp.minl.shift(3)
      #gp['prmom1']=gp.mom.shift(1)
      #gp['prmom2']=gp.mom.shift(2)
      #gp['prmom3']=gp.mom.shift(3)
      #gp['prred1']=gp.red.shift(1)
      #gp['prred2']=gp.red.shift(2)
      #gp['prred3']=gp.red.shift(3)
      gp['startl1']=gp.startl.shift(1)
      gp['furmaxh1']=gp.maxh.shift(-1) #this highest at next scope 
      gp['furmaxh2']=gp.maxh.shift(-2) #this highest at next scope 
      gp['furminl1']=gp.minl.shift(-1)
      gp['furminl2']=gp.minl.shift(-2)
      
      gp['sn']=sn

      gp['rat']=(gp.maxc/gp.startc-1)*100
      gp['furrat1']=gp.rat.shift(-1)
      gp['furrat2']=gp.rat.shift(-2)
      return gp






def getallfile(rootpath,pat):
      resultlist=[]
      for lists in os.listdir(rootpath):
            path=os.path.join(rootpath,lists)
            if os.path.isdir(path):
                  pass
            else:
                  # only get lines >60 
                  if os.path.basename(path)[0:3]==pat and os.stat(path).st_size>4000:
                  #if os.path.basename(path)[0:5]=='SH600' and os.stat(path).st_size!=0: 
                        resultlist.append(path)
      return resultlist

#the find in threading
def getgp(sn,db,gptype):
      if db.empty==False and len(db)>60 and gptype=='a':
            return makegp_a(sn,db)
      elif db.empty==False and len(db)>60 and gptype=='m':
            return makegp_m(sn,db)
      
def getdb(filepath,dbtype):
      if dbtype=='a':
            return createdb_a(filepath)
      elif dbtype=='m':
            return createdb_m(filepath)

def wgetgp(sn,db,gptype):
      if db.empty==False and len(db)>60 and gptype=='a':
            return wmakegp_a(sn,db)
      elif db.empty==False and len(db)>60 and gptype=='m':
            return wmakegp_m(sn,db)


def wgetdb(filepath,dbtype):
      if dbtype=='a':
            return wcreatedb_a(filepath)
      elif dbtype=='m':
            return wcreatedb_m(filepath)


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
 

def batsavegp(pat,findtype="m4"):
      snlist=getallfile(ROOTPATH,pat)
      result=pd.DataFrame()
      for path in snlist:
            dbcurrent=result
            sn,db=getdb(path,findtype[0])
            gp = getgp(sn,db,findtype[0])
            if gp is not None:
                  try:
                        result=dbcurrent.append(gp)
                  except:
                        print(sn)
                        continue
      if result.empty == False:
            result.to_csv("gp{}{}.csv".format(pat,findtype[0])) 	   

def wbatsavegp(pat,findtype="m4"):
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

				 
def batfind(pat,findtype='m4'):
      gp=pd.read_csv("gp{}{}.csv".format(pat,findtype[0]))
      if findtype=='a1':
            result=keyfinda1(gp)
      elif findtype=='a2':
            result=keyfinda2(gp)
      elif findtype=='m4':
            result=keyfindm4(gp)
      if result.empty==False:
            analysis(result)	
      

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
     


def dofindsh6(findtype='m4',gp='1'):
            
      print('sh6{}'.format(threading.currentThread().getName()))
      if gp=='1':
            snlist=getallfile(ROOTPATH,'SH6')
            dofinddetail(snlist,findtype)
      else:
            batfind('SH6',findtype)
      
def dofindsz0(findtype='m4',gp='1'):
      
      print('sz0'.format(threading.currentThread().getName()))
      if gp=='1':
            snlist=getallfile(ROOTPATH,'SZ0')
            dofinddetail(snlist,findtype)
      else:
            batfind('SH0',findtype)
        
def dofindsz3(findtype='m4'):
      print('sz3'.format(threading.currentThread().getName()))
      snlist=getallfile(ROOTPATH,'SZ3')
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
def keyfinda1(gp):
      return gp[(gp.pre1.abs()<gp.pre3.abs())&(gp.maxh2*1.2<gp.maxh3)&
                (gp.pre1<0)&(gp.pre3<0)&
                (gp.pre2>5)&(gp.pre2<20)&
                (gp.minl2<gp.minl3)&
                (gp.minl1<gp.minl2)
                
                
               
      ][GPTITLE2]

def keyfinda2(gp):
      return gp[(gp.pre1<0)&(gp.mupdown>0)&(gp.maxlina1>gp.maxlina2)

                
                ][GPTITLE2]

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



def readgp(csvfile):
      return pd.read_csv(csvfile,header=None,skiprows=0,names=GPTITLE)

def analysis(df):
      df['startdate']=pd.to_datetime(df['startdate'],format='%Y-%m-%d')

      print ("total:")
      print("success 3 rate:{}".format(df[(df.rat>=3)]['sn'].count()/df.sn.count()))
      print("success 5 rate:{}".format(df[df.rat>=5]['sn'].count()/df.sn.count()))
      print("success 10 rate:{}".format(df[df.rat>=10]['sn'].count()/df.sn.count()))
      #print("furture 10 rate:{}".format(df[(df.rat<3)&(df.furrat2>10)]['sn'].count()/df[(df.rat<3)]['sn'].count()))
      print ("15:")
      print("success 3 rate:{}".format(df[(df.rat>=3)&(df.startdate>'2015/01/01/')&(df.startdate<'2015/12/31')]['sn'].count()/df[(df.startdate>'2015/01/01/')&(df.startdate<'2015/12/31')].sn.count()))
      print("success 5 rate:{}".format(df[(df.rat>=5)&(df.startdate>'2015/01/01/')&(df.startdate<'2015/12/31')]['sn'].count()/df[(df.startdate>'2015/01/01/')&(df.startdate<'2015/12/31')].sn.count()))
      print("success 10 rate:{}".format(df[(df.rat>=10)&(df.startdate>'2015/01/01/')&(df.startdate<'2015/12/31')]['sn'].count()/df[(df.startdate>'2015/01/01/')&(df.startdate<'2015/12/31')].sn.count()))
      print ("16:")
      print("success 3 rate:{}".format(df[(df.rat>=3)&(df.startdate>'2016/01/01/')&(df.startdate<'2016/12/31')]['sn'].count()/df[(df.startdate>'2016/01/01/')&(df.startdate<'2016/12/31')].sn.count()))
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
 
      

