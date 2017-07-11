import pandas as pd
import sys,os
import numpy as np
import talib 
from time import ctime,sleep
import time
import datetime
from datetime import timedelta
from talib import MA_Type
from zigzag import *
#goodkey hope to slove 
#1 the minl always lower startc
#2 the maxh is not the starth
#3 the minlc is the lastc
#4 the minl is provious show at maxh

def startTime():
      return time.time()
def ticT(startTime):
      useTime=time.time()-startTime
      return round(useTime,3)

ROOTPATH='/home/lib/mypython/export/'
   
      
class STDTB(object):
      
      def __init__(self,file,angtype='z'):
            self.name='STDTB'
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
            
      def gettrn(self,x):
            if (x.prez13mode==-1 and x.z13mode==1) or (x.prez13mode==1 and x.z13mode==-1):
                  return x.id
            else:
                  return 0 
            
 
      def regroup13(self,db):
            curid=0
            for index,row in db.iterrows():
                  if row['prez13mode']!=row['z13mode']:
                        curid=index
                  
                  db.loc[index,'gpid']=curid
            return db 
      def getexdb(self):
            try:
                  exdb=self.db
                  
                  z6=peak_valley_pivots(np.array(exdb.c),0.06,-0.06)
                  z13=peak_valley_pivots(np.array(exdb.c),0.13,-0.13)
                  z6mode=pivots_to_modes(z6)
                  z13mode=pivots_to_modes(z13)
                  
                  exdb['z6']=pd.Series(z6,index=exdb.index)
                  exdb['z13']=pd.Series(z13,index=exdb.index)
                  exdb['z6mode']=pd.Series(z6mode,index=exdb.index)
                  exdb['z13mode']=pd.Series(z13mode,index=exdb.index)
                  exdb['prez13mode']=exdb.z13mode.shift(1).fillna(0).astype(int)
                  exdb['gpid']=0
                  #exdb=exdb[1:]  #drop the first rows that is not realy segment
                  #exdb['prez13mode']=exdb['prez13mode'].astype(int)
                  exdb['id']=exdb.index
                  #exdb['trn']=exdb.apply(self.gettrn,axis=1)
                  exdb['segment6']=exdb.apply(lambda x:1 if ((x.z6==-1 )&(x.z13mode==1))|((x.z6==1)&(x.z13==-1)) else 0 ,axis=1)

     
                  return self.regroup13(exdb)
                  #return exdb
            except:
                  pass
                  #print (self.sn)
      def getrat(self,x):
                  if x.len>0:
                        return (x.maxc/x.startc-1)*100
                  elif x.len<0 and x.len2<0  :
                        return -(x.minc1/x.minc-1)*100
                  elif x.len<0 and x.minc>x.minc1 :
                        return  (x.minc/x.minc1-1)*100
      def downrat(self,x):
            if (x.len<0 and x.len1>0 and x.minc>x.minc1):
                  return -((x.maxc-x.minc)/(x.maxc-x.minc1))*100
                  
      def ProvPattern(self,x):
            if x.len>0 and x.len1<0 and x.maxc<x.maxc1 and x.trendtype1=='u' :
                  return '+f'
      def compheight(self,x):
            if x.len>0 and x.len1<0 and x.len2>0 :
                  if x.height>x.proheight:
                        return 'fastup'
                  else:
                        return 'slowup'
            elif x.len<0 and x.len1>0 and x.len2<0 :
                  if x.height<x.proheight:
                        return 'fastdown'
                  else:
                        return 'slowdown'

      def getpromaxc(self,x):
            if (x.len<0 and x.len1<0 and x.len2>0) :
                  return x.maxc3
            elif (x.len<0 and x.len1>0 and x.len2<0):
                  return x.maxc2
            elif (x.len<0 and x.len1>0 and x.len2>0):
                  return x.maxc3
            elif (x.len>0 and x.len1<0 and x.len2>0):
                  return x.maxc2
            elif (x.len>0 and x.len1>0 and x.len2<0):
                  return x.maxc3
            elif (x.len>0 and x.len1<0 and x.len2<0):
                  return x.maxc3
      
      def getprominc(self,x):
            if (x.len>0 and x.len1<0 and x.len2>0) :
                  return x.minc2
            elif (x.len>0 and x.len1<0 and x.len2<0):
                  return x.minc3
            elif (x.len>0 and x.len1>0 and x.len2<0):
                  return x.minc3
            elif (x.len<0 and x.len1>0 and x.len2<0):
                  return x.minc2
            elif (x.len<0 and x.len1<0 and x.len2>0):
                  return x.minc3
            elif (x.len<0 and x.len1>0 and x.len2>0):
                  return x.minc3
            
             
      def gettrendtype(self,x):
                        
            if (x.len>0 and x.len1<0 and x.len2>0 and x.maxc<x.maxc2 and x.minc<x.minc2):
                  return 'd'
            #elif (x.len>0 and x.maxc>x.promaxc and x.minc<x.prominc):
                  #return '+)'
            #elif (x.len>0 and x.maxc>x.promaxc and x.minc>x.prominc):
                  #return '+^'
            #elif (x.len>0 and x.maxc<x.promaxc and x.minc>x.prominc):
                  #return '+F'         #Flag model
            elif  (x.len<0 and x.len1>0 and x.len2<0 and  x.maxc>x.maxc2 and x.minc>x.minc2) :
                  return 'u'
            #elif (x.len<0 and x.maxc>x.promaxc and x.minc<x.prominc):
                  #return '-)'
            #elif (x.len<0 and x.maxc<x.promaxc and x.minc>x.prominc):
                  #return '-F'
            #elif (x.len<0 and x.maxc<x.promaxc and x.minc<x.prominc):
                  #return '-v'
            else:
                  return 'm'

      #def getturn(self,x):
            #if (x.len<0 and x.len1>0 and x.trendtype1=='d' and x.minc>x.minc1 ):
                  #return 'bt' 
      def TopBotton(self,x):
            if (x.len>0 and x.len1<0 and x.maxc<x.maxc1 and x.trendtype1=='u'):
                  return 't'
            elif (x.len<0 and x.len1>0 and x.minc>x.minc1 and x.trendtype1=='d'):  #compare len2<0 and len2's 
                  return 'b'
           
           
      def middlerat(self,x):
            if (x.len<0 and x.len1>0 and x.minc>x.minc1):
                  return (x.minc-x.minc1)/(x.maxc-x.minc1)

      def middletoprat(self,x):                        # use to judge is middle
            if (x.len<0 and x.len1>0 and x.minc>x.minc2):
                  return (x.maxc/x.minc-1)*100
      
      def middlekey(self,x):                        # use to judge is middle
            if (x.len<0 and x.len1>0 and x.minc>x.minc1 and x.compheight=='ds'):
                  return 'k'
            
            
      def creatgp(self,db):
                  # group by gpid get sum of md and gpred
            if db.empty==False and len(db)>60:
                  gp22=db.groupby('gpid').sum()[['z13mode','segment6']]
                  gp22.columns=['len','segment6']
                  #gp23=db.groupby('gpid')
                  idx=db.groupby('gpid')['id'].transform(min)==db['id']
                  gp3=db[idx][['gpid','date','h','l','o','c','v'                              ]]
                  gp3.columns=['gpid','startdate','starth','startl','starto','startc','startv']
                  gp3=gp3.set_index('gpid')
                  idx2=db.groupby('gpid')['id'].transform(max)==db['id']
                  gp32=db[idx2][['gpid','date','l','c']]
                  gp32.columns=['gpid','lastdate','lastl','lastc']
                  gp32=gp32.set_index('gpid')
                  
                  gp=pd.concat([gp22,gp3,gp32],axis=1,join="inner")
                  #gp=pd.concat([gp,gp33],axis=1,join="inner")
                  #return gp33,gp
                  gp['sn']=self.sn
                  gp['len1']=gp.len.shift(1) 
                  gp=gp.dropna(axis=0)  #drop the first row that is not really segment
                  
                  gp['len2']=gp.len.shift(2)
                  gp['len3']=gp.len.shift(3)
                  gp['segment1']=gp.segment6.shift(1)
                  p13=peak_valley_pivots(np.array(db['c']),0.13,-0.13)
                  segdrawdown=compute_segment_returns(np.array(db['c']),p13)
                  #segdrawdown=np.insert(segdrawdown,0,0)
                  gp['segdrawdown']=pd.Series(segdrawdown,index=gp.index)
                  gp['segdrawdown1']=gp.segdrawdown.shift(1)
                  gp['segdrawdown2']=gp.segdrawdown.shift(2)

                 
 
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
            return gp[gp.index>=refid][['len','minc','maxc','len1']].head()
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
      
       
      
      
      def batsavegp(self,pat,cyctype='D',angtype='t'):
            snlist=self.getallfile(ROOTPATH,pat)
            result=pd.DataFrame()
            result1=pd.DataFrame()
            i=0
            j=0
            gp=pd.DataFrame()
            for path in snlist:
                  dbcurrent=result
                  db1=result1
                  if cyctype=='D':
                        stobj=STDTB(path,angtype)
                        #stwobj=STWTB(path,angtype)
                        #gpd=stobj.getgp()
                        #wdb=stwobj.getexdb()
                        #if wdb is None:
                        #      continue
                        #w=wdb[['date','tmacd']]
                        #w.columns=[['wdate','wtmacd']] 
                        #try:
                        #      gp=pd.merge(w,gpd ,left_on='wdate',right_on='lastwdate')
                        #except:
                        #      continue
                        gp=stobj.getgp()
                  else:
                        stobj=STWTB(path,angtype)
                        gp = stobj.getgp()
                  
                  if gp is not None:
                              try:
                                    
                                    result=dbcurrent.append(gp)
                                    if cyctype=='D':
                                          result1=db1.append(gp.tail(1)[['sn','startdate','len','len1','segdrawdown','segdrawdown1']])
                                    else:
                                          result1=db1.append(gp.tail(1)[['sn','startdate','len','len1','segdrawdown','segdrawdown1']])
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
            return result
      def batfindinres(self,db,year,month):
            return db[(db.startdate.dt.year==year)&(db.startdate.dt.month==month)][['startdate','sn','len','len1']]
      
      def singlefind(self,sn,findtype='t'):
            stobj=STDTB("{}{}.txt".format(ROOTPATH,sn),findtype[0])
            stwobj=STWTB("{}{}.txt".format(ROOTPATH,sn),findtype[0])
            #week obj?
            gp=stobj.getgp()
            
            
            finddb=self.keyfindt(gp)
            #wdb=stwobj.getexdb()
            
            return finddb[['sn','startdate','len','len1','len2','segdrawdown','segdrawdown1','segdrawdown2']]
      
      
      # angtype :a
                       
      # angtype :t   
      CONt=['sn','startdate','len','len1','len2','segdrawdown','segdrawdown1','segdrawdown2']
      def keyfindt(self,gp):
            return gp[(gp.len1<0)&(gp.len2>0)&(gp.segdrawdown2.abs()>gp.segdrawdown1.abs())
                      ][self.CONt]
            
      def keyfindt2(self,gp):
            return gp[(gp.len<0)&(gp.lastang58>gp.startang58)][['startdate','len','len1','len2','compheight','trendtype','trendtype1','startang58','lastang58']]
            
      def fustatics(self,df):
            # begin the startc that is not the most lower point the lowest
            print("success fumaxc2 below minc   rate:{}".format(df[df.fumaxc2<df.minc]['sn'].count()/df.sn.count()))
            print("success fumaxc2 higher starto  rate:{}".format(df[df.fumaxc2>=df.starto]['sn'].count()/df.sn.count()))
            print("success fumaxc2 higher fuminc1  rate:{}".format(df[df.fumaxc2>=df.minc]['sn'].count()/df.sn.count()))

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
 
      

