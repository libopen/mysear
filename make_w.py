import pandas as pd
import math
from datetime import timedelta,date



class dbSource:

    def __init__(self,dbPath,dbName):
        self.dbPath=dbPath
        self.dbName=dbName

    def makedb(self) :
        filePath=self.dbPath + self.dbName
        self.db=pd.read_csv(filePath,header=None,parse_dates=[1])
        self.Allti=self.db.loc[:,0].drop_duplicates()
        self.db.set_index(0)

    def getAllti(self):
       return self.Allti
                        

    def make_tiw(self,ti):
        db=self.db
        df=db[db[0]==ti]
        df=df.set_index(1)
        dfw=df.resample('W',how='last')
        dfw['ti']=dfw[0]
        dfw['cdate']=dfw.index
        dfw['op']=df[2].resample('W',how='first')
        dfw['hi']=df[3].resample('W',how='max')
        dfw['lo']=df[4].resample('W',how='min')
        dfw['la']=dfw[5]
        dfw['vo']=df[6].resample('W',how='sum')
        return dfw.iloc[:,6:13]
                      
    def exp_w(self):
        result=pd.DataFrame()
        for t in self.Allti:
            dfw=self.make_tiw(t)
            result=result.append(dfw)
        
        self.dbw=result
        filePath=self.dbPath+'mygdw.csv'
        result.to_csv(filePath,index=False)      

   
    #load old gngroupdata   
    def imp_gngroupw(self):
        filePath=self.dbPath+'gngroup_w.csv'
        self.gnwdb=pd.read_csv(filePath,parse_dates=['begindate'])
        return self.gnwdb

    # first do imp_gngroup
    def get_gngroupw(self,ti):
        df=self.gnwdb[self.gndb['ti']==ti]
        return df

    def imp_dbw(self) :
        filePath=self.dbPath+'mygdw.csv'
        self.dbw=pd.read_csv(filePath,parse_dates=['cdate'])
        #return self.dbw

    def get_wmacd(self,ti):
        dbw=self.dbw
        df=dbw[dbw['ti']==ti].copy()
        df.set_index('cdate')
        df.sort('cdate',ascending=1)
        ema_list=[12,26,60]
        for ema in ema_list:
            df.loc[:,'EMA'+str(ema)]=pd.ewma(df['la'],span=ema)

        df.loc[:,'DIF']=df['EMA12']-df['EMA26']
        df.loc[:,'DEA']=pd.ewma(df['DIF'],span=9)
        df.loc[:,'MACD']=(df['DIF']-df['DEA'])*2
        df.loc[(df['DIF']> 0) & (df['DEA']>0) ,'location']=1
        df.loc[(df['DIF']<0)   |  (df['DEA']<0) ,'location']=-1
        df.loc[(df['MACD']>=0)  ,'color']=1
        df.loc[(df['MACD']<0)  ,'color']=-1
        df['gn']=0
        return df    

    def makewgroup(self,ti):
        df=self.get_wmacd(ti)
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


        dfg_date=df.groupby('gn').apply(lambda x: x['cdate'].min())
        dfg_pl=df.groupby('gn').apply(lambda x: x['lo'].min())
        dfg_ph=df.groupby('gn').apply(lambda x: x['hi'].max())
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
    
    def exp_wgngroup(self) :
        result=pd.DataFrame(columns=['begindate','maType','zu','zd','pl','ph','minmacd','ti'])
        for t in self.Allti:
            retdf=self.makewgroup(t)
            result=result.append(retdf)
        filePath=self.dbPath+'gngroup_w.csv'
        result.to_csv(filePath,index=False)
           
               

def Main():
    p=dbSource('/home/user/programe/','mygd.csv')
    #p.makedb()
    #p.exp_w()

Main()
