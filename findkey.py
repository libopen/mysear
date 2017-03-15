import pandas as pd
import sys,os
import numpy as np
import talib 


ROOTPATH='/home/lib/mypython/export/'
#GPTITLE=['sn','startdate','startc','maxc','rat','updown','aft1','pre1','pre2','pre3','absmacd1','absmacd2','absmacd3','minl1','minl2','minl3']

GPTITLE=['sn','startdate','rat','updown','pre1','pre2','fur1','furmaxh1','minl','startl','minl2']
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
   
def poschange(x):
   if (x.mt>0 and x.macd<0 ) or (x.mt<0 and x.macd>0):
      return x.id
   else:
      return 0
   
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
      db['redcount']=db.red.rolling(8).sum()
      #db.loc[:,'EMA12']=pd.ewma(db.c,span=12)
      #db.loc[:,'EMA26']=pd.ewma(db.c,span=26)
      db.loc[:,'EMA12']=db.c.ewm(adjust=True,span=12,min_periods=0,ignore_na=False).mean()
      db.loc[:,'EMA26']=db.c.ewm(adjust=True,span=26,min_periods=0,ignore_na=False).mean()
      db.loc[:,'DIF']=db.EMA12-db.EMA26
      #db.loc[:,'DEA']=pd.ewma(db.DIF,span=9)
      db.loc[:,'DEA'] =db.DIF.ewm(adjust=True,span=9,min_periods=0,ignore_na=False).mean()
      db.loc[:,'MACD']=(db.DIF-db.DEA)*2
      db['up5']=db.MACD.rolling(window=5,center=False).max()
      
      db2=db.sort_values(['date'],ascending=False)
      db2['id']=db2.index
      db2['max5cd']=db2.MACD.rolling(window=5,center=False).max()
      #db2['max5cd']=pd.rolling_max(db2.MACD,5)
      #db2['max3']=pd.rolling_max(db2.h,3)
      #db2['max5']=pd.rolling_max(db2.h,5)
      #db3=db2[(db2.redcount>4)&(db2.min8==db2.l)&(db2.cl>3)][['sn','date','o','c','redcount','cl','MACD','max5cd']]
   finally:
      return db2
   

def createdb1(file):
   #file=sys.argv[1]
   db=None
   try:
      base=os.path.splitext(file)[0]
      sn=base[-6:]
      #print(sn)
      db=pd.read_csv(file,header=None,names=['date','o','h','l','c','v','m'])
      db['id']=db.index
      db['dif'],db['dea'],db['macd']=talib.MACD(np.array(db.c),12,26,9)
      db['absmacd']=db.macd.abs()
      db['mt']=db.macd.shift(1)
      db['trn']=db.apply(poschange,axis=1)
      db['gpid']=0
      db['red']=db.apply(red,axis=1)
      db['updown']=db.apply(lambda x: 1 if x.macd>=0 else -1,axis=1)
      db['pos_dif']=db.apply(lambda x: 1 if x.dif>=0 else -1,axis=1)
      db['mom']= talib.MOM(np.array(db.c))
      regroup(db)
      
   finally:
      return sn,db

def makegp(sn,db):
   # group by gpid get sum of md and gpred
    gp1=db.groupby('gpid').sum()[['updown','pos_dif','red','mom']]
    gp2=db.groupby('gpid').max()[['h','c','absmacd']]
    gp2.columns=['maxh','maxc','absmacd']
    gp22=db.groupby('gpid').min()[['l']]
    gp22.columns=['minl']
    idx=db.groupby('gpid')['id'].transform(min)==db['id']
    gp3=db[idx][['gpid','date','h','l','o','c','v']]
    gp3.columns=['gpid','startdate','starth','startl','starto','startc','startv']
    gp3=gp3.set_index('gpid')
    idx2=db.groupby('gpid')['id'].transform(max)==db['id']
    gp32=db[idx][['gpid','date','l','c']]
    gp32.columns=['gpid','lastdate','lastl','lastc']
    gp32=gp32.set_index('gpid')

    idx1=db.groupby('gpid')['dif'].transform(min)==db['dif']
    gp33=db[idx1][['gpid','id']]
    gp33.columns=['gpid','difid']
    gp33=gp33.set_index('gpid')
    
    gp=pd.concat([gp1,gp2,gp22,gp3,gp32,gp33],axis=1,join="inner")
    #gp=pd.concat([gp,gp33],axis=1,join="inner")
    #return gp33,gp
    gp['turnid']=gp.updown.abs()-(gp.difid-gp.index)
    gp['fur1']=gp.updown.shift(-1)
    gp['fur2']=gp.updown.shift(-2)
    gp['pre1']=gp.updown.shift(1)
    gp['pre2']=gp.updown.shift(2)
    gp['pre3']=gp.updown.shift(3)
    #gp['absmacd1']=gp.absmacd.shift(1).abs()
    #gp['absmacd2']=gp.absmacd.shift(2).abs()
    #gp['absmacd3']=gp.absmacd.shift(3).abs()
    gp['pos_dif1']=gp.pos_dif.shift(1)
    gp['pos_dif2']=gp.pos_dif.shift(2)
    gp['pos_dif3']=gp.pos_dif.shift(3)
    gp['minl1']=gp.minl.shift(1)
    gp['minl2']=gp.minl.shift(2)
    gp['minl3']=gp.minl.shift(3)
    gp['startl1']=gp.startl.shift(1)
    #gp['prmom2']=gp.mom.shift(2)
    #gp['prmom3']=gp.mom.shift(3)
    #gp['prred1']=gp.red.shift(1)
    #gp['prred2']=gp.red.shift(2)
    #gp['prred3']=gp.red.shift(3)
    #gp['prl1']=gp.startl.shift(1)
    gp['furmaxh1']=gp.maxh.shift(-1) #this highest at next scope 
    gp['furmaxh2']=gp.maxh.shift(-2) #this highest at next scope 
    gp['sn']=sn
    gp['rat']=(gp.maxc/gp.startc-1)*100
    return gp
    


def getallfile(rootpath):
   resultlist=[]
   for lists in os.listdir(rootpath):
      path=os.path.join(rootpath,lists)
      if os.path.isdir(path):
         pass
      else:
         if os.path.basename(path)[0]=='S' and os.stat(path).st_size!=0:
         #if os.path.basename(path)[0:5]=='SH600' and os.stat(path).st_size!=0: 
            resultlist.append(path)
   return resultlist
   


# find 
def Allfind(rootpath=ROOTPATH,findtype='4'):
   result=pd.DataFrame(columns=GPTITLE)
   snlist=getallfile(rootpath)
   
   for path in snlist:
         
      dbcurrent=result
      sn,db=createdb1(path)
            #print(path)
      if db is not None:
            try:
                  gp=makegp(sn, db)
                  if findtype=='1':
                     result=dbcurrent.append(keyfind1(gp))
                  elif findtype=='2':
                     result=dbcurrent.append(keyfind2(gp))
                  elif findtype=='3':
                     result=dbcurrent.append(keyfind3(gp))
                  elif findtype=='4':
                     result=dbcurrent.append(keyfind4(gp))
                  elif findtype=='5':
                     result=dbcurrent.append(keyfind5(gp))
                  elif findtype=='6':
                     result=dbcurrent.append(keyfind6(gp))                     
                  elif findtype=='7':
                    result=dbcurrent.append(keyfind7(gp))
            except:
                  print(sn)
                  continue
   #result.to_csv('myfind.csv')   
   return result



def singlefind(sn,findtype='4'):
   sn,db=createdb1(ROOTPATH+sn+'.txt')
              #print(path)
   result=None
   if db is not None:
      gp=makegp(sn, db)   
      if findtype=='1':
         result=keyfind1(gp)
      elif findtype=='2':
         result=keyfind2(gp)
      elif findtype=='3':
         result=keyfind3(gp)         
      elif findtype=='4':
         result=keyfind4(gp)         
      elif findtype=='5':
         result=keyfind5(gp)         
      elif findtype=='6':
         result=keyfind6(gp)         
      elif findtype=='7':
         result=keyfind7(gp)  
   return result
   
#keyfind
def keyfind0(file):
# the oldest ver of keyfind
   db2=createdb(file)
   if db2 is not None:
      #return db2[ (db2.redcount>4)
       #          &(db2.min8==db2.l)
       #          &(db2.cl>3) 
       #          & (db2.MACD<0)
       ##          & (db2.MACD==db2.up5)
       #          &(np.abs(db2.co)<1)
       #          &(db2.co>=0)                 
       #          ][['sn','date','o','c','redcount','cl','co','MACD','max5cd']]
      return db2[ (db2.redcount>4)
                 &(db2.min8==db2.l)
                 #&(db2.cl>3) 
                 &(db2.midp=='u')
                 & (db2.MACD<0)
                 & (db2.MACD==db2.up5)
                  &(np.abs(db2.co)<1)      
                 ][['sn','date','o','c','h','l','redcount','cl','co','MACD','max5cd','min8']]


def keyfind1(gp):
   # pos1:current(+),pre1(-) ,pre2(+),pre3(-) 
   # pos2:           pre1<10 pre2<=20 pre3>30
   #                 absmacd1<absmacd2<absmacd3
   # pos3:           minl1<minl3
   return gp[ (gp.updown>0) &
             (gp.pre2<3) ][GPTITLE]

def keyfind2(gp):
   # pos1:pre1>0 and pre1<6 and dif<0 and dea<0 and updown*2 <pre2
   # pos2:pre1*2<pre3 think about absmacd2 absmacd3
   # pos3:entrance
   return gp[ (gp.pre1<0) & 
              (gp.pre1.abs()>2) & 
              (gp.pre1.abs()<10) &
              (gp.pre3<gp.pre1)&
              (gp.pos_dif1<0)&
              (gp.pos_dif3<0)&
              (gp.pre2<gp.pre3.abs())
              ][GPTITLE]


def keyfind3(gp):
    # pos1   pre1 <0 
    #        startl1=minl1
    #        pre1<pre3
   return gp[(gp.pre1<0)&
            (gp.startl1==gp.minl1)&
            (gp.pre1>gp.pre3) &
            (gp.pre2<gp.pre3.abs()) &
            (gp.pos_dif1<0)&
            (gp.pos_dif3<0)
             ][GPTITLE]
             
def keyfind4(gp):
   # pos1:     important 
   # pos2:      rat>3 时，pre1.abs()>pre3.abs() 占90%
   # pos3:entrance
   # rat >3 77% (gp.pre1<0)&(gp.pre1.abs()>20)&(gp.pos_dif1<0)&(gp.pos_dif3>0) 
   return gp[ (gp.pre1<0) &                                                                                                                                        
              (gp.pre1.abs()>20) & 
              (gp.pos_dif1<0)&
              (gp.pos_dif3>0)&
              (gp.pre1.abs()>gp.pre3.abs())
              
              ][GPTITLE]

def keyfind5(gp):
   # pos1:     pre1<0 and pre1<30 posdif >0 
   # pos2:   
   # pos3:entrance
   return gp[ (gp.pre2>0) & 
              (gp.pre2<=30) & 
              (gp.pos_dif2<gp.pre2)&
	      (gp.pos_dif2>0)&
              (gp.minl1<gp.minl2)            
              ][GPTITLE]
   
def keyfind6(gp):
   # pos1:     pre1<0 and pre1.abs()>30 posdif >0 
   # pos2:   
   # pos3:entrance
   return gp[ (gp.pre1<0) & 
              (gp.pre1.abs()>30) & 
              (gp.pos_dif1>3)
             
              ][GPTITLE]

def keyfind7(gp):
   #pos : 
   #return gp[(gp.updown<0)&(gp.updown>-10)&
   #          (gp.startl==gp.minl)&
   #          (abs(gp.minl-gp.minl2)<gp.minl*0.03)&
   #          (gp.pre1>abs(gp.updown))&
   #          (abs(gp.pre2)>gp.pre1)][GPTITLE]
   return gp[(gp.pre1<0 )&(gp.pre1>-10)&
             (gp.startl1==gp.minl1)&
             (gp.minl1>=gp.minl3) &
            #(abs(gp.minl1-gp.minl3)<gp.minl1*0.03)&
              (gp.pre2>abs(gp.pre1))&
              (abs(gp.pre3)>gp.pre2)
               
             ][GPTITLE]

             
def readgp(csvfile):
    return pd.read_csv(csvfile,header=None,skiprows=1,names=GPTITLE)
   
def analysis(df):
      df['startdate']=pd.to_datetime(df['startdate'],format='%Y-%m-%d')
      
      print ("total:")
      print("success 3 rate:{}".format(df[(df.rat>=3)]['sn'].count()/df.sn.count()))
      print("success 5 rate:{}".format(df[df.rat>=5]['sn'].count()/df.sn.count()))
      print("success 10 rate:{}".format(df[df.rat>=10]['sn'].count()/df.sn.count()))
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
      print(gp[gp.index>'2015-12-31'].to_csv(sep='\t'))

def main():
   #path=sys.argv[1]
   #db=keyfindall(path)
   #result=db.sort('date')
   #result.to_csv('myfind.csv')
   #analysis(db)
    findtypeid=sys.argv[1]
    gp= Allfind( findtype=findtypeid)
    analysis(gp)
     	
   


if __name__=="__main__":
   #findall(sys.argv[1])
   #find('/home/lib/mypython/export/export/SZ300376.txt')
   main()

