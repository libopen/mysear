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
                        

    def exp_gngroup(self) :
        result=pd.DataFrame(columns=['begindate','maType','zu','zd','pl','ph','minmacd','ti'])
        for t in self.Allti:
            retdf=self.makegroup(t)
            result=result.append(retdf)
        filePath=self.dbPath+'gngroup_d.csv'
        result.to_csv(filePath,index=False)
   
    #load old gngroupdata   
    def imp_gngroup(self):
        filePath=self.dbPath+'gngroup_d.csv'
        self.gndb=pd.read_csv(filePath,parse_dates=['begindate'])
        self.gndb.set_index('ti')
        filePath=self.dbPath+'exright.csv'
        self.exdb=pd.read_csv(filePath,parse_dates=['begindate'])

    # first do imp_gngroup
    def get_gngroup(self,ti):
        df=self.gndb[self.gndb['ti']==ti]
        return df

    def get_macd(self,ti):
        db=self.db
        df=db[db[0]==ti].copy()
        df.set_index(1)
        df.sort(1,ascending=0)
        ema_list=[12,26,60]
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
    
    def exp_exright(self):
        db=self.db
        row_list=[]
        for t in self.Allti:
            df=db[db[0]==t].copy()
            df.set_index(1)
            df.sort(1,ascending=0)
            ret=self.isexright(df)
            if len(ret)>0:
               row_list.append(ret)
        df=pd.DataFrame(row_list)
        filePath=self.dbPath+'exright.csv'
        df.to_csv(filePath,index=False)
    
    def get_exright(self):
        return self.exdb
            
    def isexright(self,df):
        last=df.irow(0)
        t=last[0]
        isValid=0
        for i in range(0,df.shape[0]):
            cur=df.irow(i)
            # use the last pla 
            if (last[5]/cur[5])>1.15 :
                cdate=cur[1]
                isValid=1
            last=cur
        if isValid==1:
            return {'ti':t,'begindate':cdate}
        else :
            return {}

    def make_tiw(self,ti):
        db=self.db
        df=db[db[0]==ti]
        df=df.set_index(1)
        dfw=df.resample('W',how='last')
        dfw[2]=df[2].resample('W',how='first')
        dfw[3]=df[3].resample('W',how='max')
        dfw[4]=df[4].resample('W',how='min')
        dfw[6]=df[6].resample('W',how='sum')
        #dfw.columns=['cdate','ti','op','hi','lo','la','vo']
        return dfw
                      
    def exp_w(self):
        result=pd.DataFrame()
        for t in self.Allti:
            dfw=self.make_tiw(t)
            result=result.append(dfw)
        #result.set_index('ti')
        filePath=self.dbPath+'mygdw.csv'
        result.to_csv(filePath,index=True)


    def exp_m(self):
        result=pd.DataFrame()
        for t in self.Allti:
            dfm=self.make_tim(t)
            result=result.append(dfm)
        #result.set_index('ti')
        filePath=self.dbPath+'mygdm.csv'
        result.to_csv(filePath,index=True)

    def make_tim(self,ti):
        db=self.db
        df=db[db[0]==ti]
        df=df.set_index(1)
        dfw=df.resample('M',how='last')
        dfw[2]=df[2].resample('M',how='first')
        dfw[3]=df[3].resample('M',how='max')
        dfw[4]=df[4].resample('M',how='min')
        dfw[6]=df[6].resample('M',how='sum')
        return dfw

           
               

def Main():
    p=dbSource('/home/user/programe/','mygd.csv')
    #p.makedb()
    #p.exp_w()

Main()
