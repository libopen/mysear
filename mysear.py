import pandas as pd
import math
from datetime import timedelta,date
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
        filePath=self.dbPath+'gngroup.csv'
        result.to_csv(filePath,index=False)
   
    #load old gngroupdata   
    def imp_gngroup(self):
        filePath=self.dbPath+'gngroup.csv'
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
             # print(' %d %d %d %d %d %d %d '%(g1.maType,r1.ph,r2.ph,g1.pl,g2.pl,r2.maType,g2.maType))
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
    
    """--------b 3 -----------
      Order:  r4 g3 r2 g1
              r2(ph)>r4(ph) g1(pl)>r4(ph) g3(abs(ma)<r4(ma)
    ------- end b3 --------"""
    def validB3(self,retdf,nLow=1):
        isValid=0
        ldf=len(retdf)
        if ldf>5 :
        # cur = r so r(num)=1  is ok
           gnlist=self.getGnlist(retdf.tail(5))
           
           gnbase=gnlist[4]
           if gnbase.maType==nLow :
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
              if (abs(g1.maType)>10) and  (r1.ph>r2.ph) and (r2.ph >=g1.pl>=g2.pl) and (abs(r2.maType)>abs(g2.maType)) :
                  isValid=1
              else:
                  isValid=0  
                          
        return isValid
     
    def searB3(self,nLow=1) :
        result=pd.DataFrame(columns=['begindate','maType','zu','zd','pl','ph','minmacd','ti'])
        for t in self.Allti:
             retdf=self.get_gngroup(t)
             if self.validB3(retdf,nLow)==1 :
                result=result.append(retdf.tail(1))
        return result

    """ m851 """
    def validB3_2(self,retdf,nLow=1) :
        isValid=0
        ldf=len(retdf)
        if ldf>=6 :
        # cur = r so r(num)=1  is ok
           gnlist=self.getGnlist(retdf.tail(6))
           
           gnbase=gnlist[5] # the last
            
           if (gnbase.maType==nLow)  :
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
              if (abs(g1.maType)>10) and (r1.maType>10) and (abs(g2.maType)>abs(g1.maType)*1.1) and  (r2.ph>r1.ph*1.2) and (g2.pl>g1.pl*1.1) and (g2.macd>g1.macd) : 
                  isValid=1
              else:
                  isValid=0  
                          
        return isValid

    def searB3_2(self,nLow=1) :
        result=pd.DataFrame(columns=['begindate','maType','zu','zd','pl','ph','minmacd','ti'])
        for t in self.Allti:
             retdf=self.get_gngroup(t)
             if self.validB3_2(retdf,nLow)==1 :
                result=result.append(retdf.tail(1))
        return result
   
    """ B3_3                      """
    def validB3_3(self,retdf,nLow=1) :
        isValid=0
        ldf=len(retdf)
        if ldf>=6 :
        # cur = r so r(num)=1  is ok
           gnlist=self.getGnlist(retdf.tail(6))
           
           gnbase=gnlist[5] # the last
            
           if (gnbase.maType==nLow)   :
              r2=gnlist[1]
              r1=gnlist[3]
              g2=gnlist[2]
              g1=gnlist[4]
              if r1.maType>5 :
                 isValid=1
           elif gnbase.maType<-10 :
              r2=gnlist[2]
              r1=gnlist[4]
              g2=gnlist[3]
              g1=gnlist[5]
              if r1.maType>5 :  
                   isValid=1
           
           if isValid==1 :
              if (g2.macd>g1.macd) and (g2.pl>g1.pl) and (g2.macd>r1.macd) and  (g1.pl>=r2.pl) and (r2.macd>g2.macd)  : 
                  isValid=1
              else:
                  isValid=0  
                          
        return isValid

    def searB3_3(self,nLow=1) :
        result=pd.DataFrame(columns=['begindate','maType','zu','zd','pl','ph','minmacd','ti'])
        for t in self.Allti:
             retdf=self.get_gngroup(t)
             if self.validB3(retdf,nLow)==1 :
                result=result.append(retdf.tail(1))
        return result

    """  60 line """
    def valid60(self,exdate,cdate=date.today()) :
        result=pd.DataFrame(columns=['begindate','maType','zu','zd','pl','ph','minmacd','ti'])
        begindate=cdate
        enddate=begindate-timedelta(days=5)
        for t in self.Allti:
            retdf=self.get_macd(t).tail(5)
            retdf=retdf[(retdf[1]>=enddate) & (retdf[1]<=begindate) & (retdf['EMA60']>=retdf[4])]
            if retdf.empty==False :
               result=result.append(self.get_gngroup(t).tail(1)) 
        exdf=self.exdb
        retdf=pd.merge(result,exdf,on='ti',how='left')
        retdf=retdf[(retdf.begindate_y.isnull())|(retdf.begindate_y<exdate)][['ti','begindate_x','maType','begindate_y','pl','ph']]          
        return retdf
        
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

    """  analysis every one state """
    """  1:current segment r or g and length """
    def collectInfo(self,ti):
        retdf=self.get_gngroup(ti)
        curpl=self.get_macd(ti).tail(1).iloc[0,5]
        if len(retdf)>5 :
            gnlist=self.getGnlist(retdf.tail(5)) 
            """current state"""
            cur=gnlist[4] 
            cur_1=gnlist[3]
            cur_2=gnlist[2]
            cur_3=gnlist[1]
            if cur.zu>0 and cur.zu>cur.zd :
                  tz='BM'
            elif cur.zu>0 and cur.zu<cur.zd:
                  tz='BL'
            else :
                  tz='S'
            ppos='{:.3f}-{:.3f}'.format((cur.ph-curpl)/cur.ph,curpl/cur.pl)
           
            p_1=cur.ph/cur_1.pl
            p_2=cur_2.ph/cur_3.pl 
            if cur.maType>0 :
               if cur.ph>cur_2.ph and cur.pl>cur_2.pl:
                  t_state='RU'
               elif cur.ph<cur_2.ph and cur.pl<cur_2.pl :
                  t_state='RD'
               else:
                  t_state='RM'
            else:
                if cur.pl<cur_2.pl and cur.ph<cur_2.ph:
                   t_state='GD'
                else:
                   t_state='GM'
                             
            return {'ti':ti,'state':t_state+tz,'per1':p_1,'per2':p_2,'ppos':ppos}
        else :
            return{}   
    
    def wholeSear(self):
        db=self.db
        row_list=[]
        for t in self.Allti:
            ret=self.collectInfo(t)
            if len(ret)>0:
               row_list.append(ret)
        df=pd.DataFrame(row_list)
        return df
                


def Main():
    p=dbSource('/home/user/programe/','mygd.csv')
 #   p.makedb()
#    p.exp_exright()

Main()
