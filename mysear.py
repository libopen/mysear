import pandas as pd
import math
import time
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
    """------- end b3 --------
    def validB3(self,retdf):
        isValid=0
        ldf=len(retdf)
        if ldf>5 :
        # cur = r so r(num)=1  is ok
           retdf = retdf.tail(5)  
           r1=retdf.iloc[4,1]		
           if (r1==1)  :
              r4h=retdf.iloc[0,5]
              r2h=retdf.iloc[2,5]
              g1l=retdf.iloc[3,4]
              g3m=retdf.iloc[1,6]
              r4m=retdf.iloc[0,6]  
              if (r2h>r4h) and (g1l>r4h) and (r4m>g3m) :
                  isValid=1
           elif (r1<=-3)  :
              r4h=retdf.iloc[1,5]
              r2h=retdf.iloc[3,5]
              g1l=retdf.iloc[4,4]
              g3m=retdf.iloc[2,6]
              r4m=retdf.iloc[1,6]  
              if (r2h>r4h) and (g1l>r4h) and (r4m>g3m) :
                  isValid=1
        return isValid
     
    def searB3(self) :
        result=pd.DataFrame(columns=['begindate','maType','zu','zd','pl','ph','minmacd','ti'])
        for t in self.Allti:
             retdf=self.get_gngroup(t)
             if self.validB3(retdf)==1 :
                result=result.append(retdf.tail(1))
        #result.set_index('begindate')
        result.sort(['begindate'],ascending=[False])
        return result


    """--------B1 -----------
      Order:  r4 g3 r2 g1
              g1(pl)<=g3(pl) g1(ph)<g3(ph) g1(abs(ma)<g3(ma)
    """------- end b3 --------
    def validB1(self,retdf):
        isValid=0
        ldf=len(retdf)
        if ldf>5 :
        # cur = r so r(num)=1  is ok
           retdf = retdf.tail(5)  
           r1=retdf.iloc[4,1]		
           if (r1==1)  :
              r4h=retdf.iloc[0,5]
              r2h=retdf.iloc[2,5]
              g1h=retdf.iloc[3,5]
              g3h=retdf.iloc[1,5]
              g1l=retdf.iloc[3,4]
              g3l=retdf.iloc[1,4]
              g1m=retdf.iloc[3,6]
              g3m=retdf.iloc[1,6]  
              if (r4h>r2h) and (g3l>g1l) and (g3h>g1h) and (g3m>g1m) :
                 aa isValid=1
           elif (r1<=-3)  :
              r4h=retdf.iloc[1,5]
              r2h=retdf.iloc[3,5]
              g1h=retdf.iloc[4,5]
              g3h=retdf.iloc[2,5]
              g1l=retdf.iloc[4,4]
              g3l=retdf.iloc[2,4]
              g1m=retdf.iloc[4,6]
              g3m=retdf.iloc[2,6]  
              if (r4h>r2h) and (g3l>g1l) and (g3h>g1h) and (g3m>g1m) :
                  isValid=1
        return isValid



    """2 segment comp """		
    def valid2Seg(self,retdf):
        isValid=0
        seg1=retdf.iloc[len(retdf.index)-1,1]
        seg1begindate=retdf.iloc[len(retdf.index)-1,0]
        ldf=len(retdf.index)
        # [g4 r3 g2 (r1<3)  g4>g2   
        # [g5 r4 g3 r2 g1  then g3>g1
        if ldf>5 :		
           if (0<seg1<3)  :
              maType1=retdf.iloc[len(retdf.index)-2,1]
              maType3=retdf.iloc[len(retdf.index)-4,1]
              mac1=retdf.iloc[len(retdf.index)-2,6]
              mac3=retdf.iloc[len(retdf.index)-4,6]
              zu1=retdf.iloc[len(retdf.index)-2,2]
              zd1=retdf.iloc[len(retdf.index)-2,3]
              if (abs(maType3)>abs(maType1)) and (mac1>mac3) :
                  isValid=1
           elif (seg1<-3)  :
              maType1=retdf.iloc[len(retdf.index)-1,1]
              maType3=retdf.iloc[len(retdf.index)-3,1]
              mac1=retdf.iloc[len(retdf.index)-1,6]
              mac3=retdf.iloc[len(retdf.index)-3,6]
              zu1=retdf.iloc[len(retdf.index)-1,2]
              zd1=retdf.iloc[len(retdf.index)-1,3]
              if (abs(maType3)>abs(maType1)) and (mac1>mac3) :
                 isValid=1        
        return isValid
          
              
    def sear2Seg(self):
        print(time.strftime('%Y-%m-%d %H:%M:%S'))
        result=pd.DataFrame(columns=['begindate','maType','zu','zd','pl','ph','minmacd','ti'])
        for t in self.Allti:
             # if t<1000:
                   retdf=self.get_gngroup(t)
                   if self.valid2Seg(retdf)==1 :
                      result=result.append(retdf.tail(1))
        print(time.strftime('%Y-%m-%d %H:%M:%S'))
        #result.set_index('begindate')
        result.sort(['begindate'],ascending=[False])
        return result

    """ g1 > 20 or g2 >20 zu>zd  """      
    def valid1Seg(self,retdf):
        isvalid=0
        """ 1 seg1<-20 
            2 minmac<curmac
            3 pl(minmac)<curpl
            4.zu>zd
        """
        df = retdf.tail(2)
        if len(df)==2 :
            # r3 g2 r1 r1=1 then comp(g2)
            seg1=df.iloc[1]['maType']
            seg2=df.iloc[0]['maType']
            if (seg1==1) and (abs(seg2)>20) :
                  zu=df.iloc[0]['zu']
                  zd=df.iloc[0]['zd']
                  if (zu>zd>0) :
                      isvalid=1
            elif seg1<=-20 :
                  begindate=df.iloc[1]['begindate']
                  minMac= df.iloc[1]['minmacd']
                  ti=df.iloc[1]['ti']
                  curdf=self.get_macd(ti).tail(1)
                  curMac=curdf.iloc[0]['MACD']
                  zu=df.iloc[0]['zu']
                  zd=df.iloc[0]['zd']
                  if (zu>zd>0) and (curMac>minMac) :
                      isvalid=1
        return isvalid
        
          
    def sear1Seg(self):
         # 
         result=pd.DataFrame(columns=['begindate','maType','zu','zd','pl','ph','minmacd','ti'])
         for t in self.Allti:
             # if t<1000:
                retdf=self.get_gngroup(t)
                if self.valid1Seg(retdf)==1:
                   result=result.append(retdf.tail(1))
         print(time.strftime('%Y-%m-%d %H:%M:%S'))
         return result


    def valid1Seg2(self,retdf):
        """
		1 : seg1<=20
		2 : max(macd)
		3 : last > max(macd)
        """
        isvalid=0
        seg1=retdf.iloc[len(retdf.index)-1,1]
        ldf=len(retdf.index)
        if ldf>2:
           # g2(seg2) zu1>zd1 & r1(seg1)  zd1>1 
           seg2=retdf.iloc[len(retdf.index)-2,1]
           zu1=retdf.iloc[len(retdf.index)-1,2]
           zd1=retdf.iloc[len(retdf.index)-1,3]
           zu2=retdf.iloc[len(retdf.index)-2,2]
           zd2=retdf.iloc[len(retdf.index)-2,3]
          
           if (seg1>0) and ( zd1>0) and (zu2>zd2>0) :
               isvalid=1
        return isvalid
        
    """    
    def sear3Seg(self):
         # 
         print(time.strftime('%Y-%m-%d %H:%M:%S'))
         result=pd.DataFrame(columns=['begindate','maType','zu','zd','pl','ph','minmacd','ti'])
         for t in self.Allti:
             # if t<1000:
                retdf=self.makegroup(self,t)
                if dbSource.valid3df(self,retdf)==1:
                   result=result.append(retdf.tail(1))
         print(time.strftime('%Y-%m-%d %H:%M:%S'))
         return result
    """ 
    



