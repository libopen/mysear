import pandas as pd
import math
import time
import pdb
class gnGroup:
    def __init__(self,df):
        self.begindate=df.iloc[0,0]
        self.maType=df.iloc[0,1]
        self.zu=df.iloc[0,2]
        self.zd=df.iloc[0,3]
        self.pl=df.iloc[0,4]
        self.ph=df.iloc[0,5]
        self.macd=df.iloc[0,6]
    def  maType(self) :
        return self.maType
  
    def  zu(self) :
        return self.zu
        
    def  zd(self) :
        return self.zd
    def  pl(self) :
        return self.pl

    def  ph(self) :
        return self.ph

    def  macd(self) :
        return self.macd

class dbSource:
    
    def __init__(self,dbPath,dbName):
        self.dbPath=dbPath
        self.dbName=dbName

    def makedb(self) :
        #print('makedb')
        filePath=self.dbPath + self.dbName
        self.db=pd.read_csv(filePath,header=None,parse_dates=[1])
        self.Allti=self.db.loc[:,0].drop_duplicates()
        self.db.set_index(0)

    def getAllti(self):
       return self.Allti
                        
    def getGnlist(self,retdf):
       gnlist=[]
       for i in range(len(retdf)):
           gnlist.append(gnGroup(retdf[i:i+1]))
       return gnlist

    def exp_gngroup(self) :
        result=pd.DataFrame(columns=['begindate','maType','zu','zd','pl','ph','minmacd','ti'])
        for t in self.Allti:
            retdf=self.makegroup(t)
            result=result.append(retdf)
        result.to_csv('/home/user/programe/gngroup.csv',index=False)
   
    #load old gngroupdata   
    def imp_gngroup(self):
        filePath=self.dbPath+'gngroup.csv'
        self.gndb=pd.read_csv(filePath,parse_dates=['begindate'])
        self.gndb.set_index('ti')
    
    # first do imp_gngroup
    def get_gngroup(self,ti):
        df=self.gndb[self.gndb['ti']==ti]
        return df

    def get_macd(self,ti):
        db=self.db
        df=db[db[0]==ti].copy()
        df.set_index(1)
        df.sort(1,ascending=0)
        ema_list=[12,26]
        for ema in ema_list:
            df.loc[:,'EMA'+str(ema)]=pd.ewma(df[5],span=ema)

        df.loc[:,'DIF']=df['EMA12']-df['EMA26']
        df.loc[:,'DEA']=pd.ewma(df['DIF'],span=9)
        df.loc[:,'MACD']=(df['DIF']-df['DEA'])*2
        df.loc[(df['DIF']> 0) & (df['DEA']>0) ,'location']=1
        df.loc[(df['DIF']<0)   |  (df['DEA']<0) ,'location']=-1
        df.loc[(df['MACD']>=0)  ,'color']=1
        df.loc[(df['MACD']<0)  ,'color']=-1
        df['gn']=0
        return df    

    def makegroup(self,ti):
        df=self.get_macd(ti)
        df['MACD']=abs(df['MACD'])      
        #loop construct group
        n=1
        curColor=df.iloc[0]['color'];
        for index ,row in df.iterrows():
            if row['color']==curColor :
                df.loc[index,'gn']=n
            else:
                n=n+1
                curColor=row['color']
                df.loc[index,'gn']=n


        dfg_date=df.groupby('gn').apply(lambda x: x[1].min())
        dfg_pl=df.groupby('gn').apply(lambda x: x[4].min())
        dfg_ph=df.groupby('gn').apply(lambda x: x[3].max())
        dfg_macd_type=df.groupby('gn').apply(lambda x: x['color'].sum())
        dfg_u=df.groupby('gn').apply(lambda x: x[x['location']==1]['location'].count())
        dfg_d=df.groupby('gn').apply(lambda x: x[x['location']==-1]['location'].count())
       # dfg_macd_min=df[df['color']==-1].groupby('gn').apply(lambda x: x['MACD'].min())
       # dfg_macd_min=df[df['color']==1].groupby('gn').apply(lambda x: x['MACD'].max())
        dfg_macd_min=df.groupby('gn').apply(lambda x: x['MACD'].max())
        result=pd.concat([dfg_date,dfg_macd_type,dfg_u,dfg_d,dfg_pl,dfg_ph,dfg_macd_min],axis=1)
        result.columns =['begindate','maType','zu','zd','pl','ph','minmacd']
        result.loc[:,'ti']=ti
        return result.tail(30) 
    
    """--------b 3 -----------
      Order:  r4 g3 r2 g1
              r2(ph)>r4(ph) g1(pl)>r4(ph) g3(abs(ma)<r4(ma)
    ------- end b3 --------"""
    def validB3(self,retdf):
        isValid=0
        ldf=len(retdf)
        if ldf>5 :
        # cur = r so r(num)=1  is ok
           gnlist=self.getGnlist(retdf.tail(5))
           
           gnbase=gnlist[4]
           if gnbase.maType==1 :
              r2=gnlist[0]
              r1=gnlist[2]
              g2=gnlist[1]
              g1=gnlist[3]
              isValid=1
           elif gnbase.maType<-10 :
              r2=gnlist[1]
              r1=gnlist[3]
              g2=gnlist[2]
              g1=gnlist[4]   
              isValid=1
           
           if isValid==1 :
             # print(' %d %d %d %d %d %d %d '%(g1.maType,r1.ph,r2.ph,g1.pl,g2.pl,r2.maType,g2.maType))
              if (abs(g1.maType)>10) and  (r1.ph>r2.ph) and (r2.ph >=g1.pl>=g2.pl) and (abs(r2.maType)>abs(g2.maType)) :
                  isValid=1
              else:
                  isValid=0  
                          
        return isValid
     
    def searB3(self) :
        result=pd.DataFrame(columns=['begindate','maType','zu','zd','pl','ph','minmacd','ti'])
        for t in self.Allti:
             retdf=self.get_gngroup(t)
             if self.validB3(retdf)==1 :
                result=result.append(retdf.tail(1))
        return result

    """ m851 """
    def validB3_2(self,retdf) :
        isValid=0
        ldf=len(retdf)
        if ldf>=6 :
        # cur = r so r(num)=1  is ok
           gnlist=self.getGnlist(retdf.tail(6))
           
           gnbase=gnlist[5] # the last
            
           if (gnbase.maType==1)  :
              r2=gnlist[1]
              r1=gnlist[3]
              g2=gnlist[2]
              g1=gnlist[4]
              isValid=1
           elif gnbase.maType<-10 :
              r2=gnlist[2]
              r1=gnlist[4]
              g2=gnlist[3]
              g1=gnlist[5]   
              isValid=1
           
           if isValid==1 :
              #pdb.set_trace()
              #print(' %d %d %d %d %d %d %d '%(g1.maType,r1.ph,r2.ph,g1.pl,g2.pl,r2.maType,g2.maType))
              if (abs(g1.maType)>10) and (r1.maType>10) and (abs(g2.maType)>abs(g1.maType)*1.1) and  (r2.ph>r1.ph*1.2) and (g2.pl>g1.pl*1.1) and (g2.macd>g1.macd) : 
                  isValid=1
              else:
                  isValid=0  
                          
        return isValid

    def searB3_2(self) :
        result=pd.DataFrame(columns=['begindate','maType','zu','zd','pl','ph','minmacd','ti'])
        for t in self.Allti:
             retdf=self.get_gngroup(t)
             if self.validB3_2(retdf)==1 :
                result=result.append(retdf.tail(1))
        return result



def Main():
    p=dbSource('/home/user/programe/','mygd.csv')
    p.makedb()
    p.imp_gngroup()
    df=p.get_gngroup(851)
    df=df.head(6)
    p.validB3_2(df)
    return p

Main()
