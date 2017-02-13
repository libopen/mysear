import pandas as pd
import sys,os
import numpy as np

def midpoint(x):
   if x.c>(x.l+(x.h-x.l)/2):
      return 'u'
   else:
      return 'd'
def red(x):
   if x.c>x.o :
      return 1
   else:
      return 0
   
   
def createdb(file):
   #file=sys.argv[1]
   db2=None
   try:
      base=os.path.splitext(file)[0]
      sn=base[-6:]
      #print(sn)
      db=pd.read_csv(file,header=None,names=['date','o','h','l','c','v','m'])
      
      db['sn']=sn
      db['min8']=db.l.rolling(8).min()
      db['midp']=db.apply(midpoint,axis=1)
      db['cl']=(db.c/db.l-1)*100
      db['co']=(db.c/db.o-1)*100
      db['red']=db.apply(red,axis=1)
      #db.loc[(db.c>db.o),'red']=1
      #db.loc[(db.c<=db.o),'red']=0
      db['redcount']=db.red.rolling(8).sum()
      #db.loc[:,'EMA12']=pd.ewma(db.c,span=12)
      #db.loc[:,'EMA26']=pd.ewma(db.c,span=26)
      db.loc[:,'EMA12']=db.c.ewm(adjust=True,span=12,min_periods=0,ignore_na=False).mean()
      db.loc[:,'EMA26']=db.c.ewm(adjust=True,span=26,min_periods=0,ignore_na=False).mean()
      db.loc[:,'DIF']=db.EMA12-db.EMA26
      #db.loc[:,'DEA']=pd.ewma(db.DIF,span=9)
      db.loc[:,'DEA'] =db.DIF.ewm(adjust=True,span=9,min_periods=0,ignore_na=False).mean()
      db.loc[:,'MACD']=(db.DIF-db.DEA)*2
      
      db2=db.sort_values(['date'],ascending=False)
      db2['id']=db2.index
      db2['max5cd']=db2.MACD.rolling(window=5,center=False).max()
      #db2['max5cd']=pd.rolling_max(db2.MACD,5)
      #db2['max3']=pd.rolling_max(db2.h,3)
      #db2['max5']=pd.rolling_max(db2.h,5)
      #db3=db2[(db2.redcount>4)&(db2.min8==db2.l)&(db2.cl>3)][['sn','date','o','c','redcount','cl','MACD','max5cd']]
   finally:
      return db2
   
def find(file):
   db2=createdb(file)
   if db2 is not None:
      return db2[ (db2.redcount>4)
                 &(db2.min8==db2.l)
                 &(db2.cl>3) 
                 & (db2.MACD<0)
                 &(np.abs(db2.co)<1)
                 &(db2.co>=0)                 
                 ][['sn','date','o','c','redcount','cl','co','MACD','max5cd']]

def findall(rootpath):
   result=pd.DataFrame(columns=['sn','date','o','c','redcount','cl','co','MACD','max5cd'])
   
   for lists in os.listdir(rootpath):
      dbcurrent=result
      path=os.path.join(rootpath,lists)
      
      if os.path.isdir(path):
         pass
      else:
         if os.path.basename(path)[0]=='S' and os.stat(path).st_size!=0:
            db=find(path)
            #print(path)
            if db is not None:
               result=dbcurrent.append(db)
            else:
               print(path)
   #result.to_csv('myfind.csv')   
   return result

def analysis(df):
   print("success rate:{}".format(df[df.MACD<df.max5cd]['sn'].count()/df.sn.count()))
   find1=pd.DatetimeIndex(df.date).to_period("M")
   gp=df.sn.groupby(find1).count()
   print(gp[gp.index>'2013-12-31'].to_csv(sep='\t'))

def main():
   path=sys.argv[1]
   db=findall(path)
   #db.to_csv('myfind.csv')
   analysis(db)
   


if __name__=="__main__":
   #findall(sys.argv[1])
   #find('/home/lib/mypython/export/export/SZ300376.txt')
   main()

