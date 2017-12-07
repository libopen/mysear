import pandas as pd
import STS,imp,STFILE
import numpy as np

def getposdf(sn='ss123456'):
    imp.reload(STS)
    df1=(STS.getposmacd('ss123456')
            .drop('posmacd',axis=1)
            .assign(f1=0)
            .assign(f2=0)
            .assign(f3=0)
            .assign(f4=0)
            .loc['2015-1-1':])
    a=STFILE.ANALYSIS()
    for sn in a.getallfile('SH8'):
        df2=STS.getposmacd(sn)
        df1=(pd.concat([df1,df2],axis=1,join='outer')
               .fillna(0)
           .pipe(compute)
           .drop('posmacd',axis=1))
      
    #cols=['f1','f2','f3','f4']
    #df1[cols]=df1[cols].applymap(np.int64)    
    return df1.to_csv('SH8.csv')

def compute(df):
    df.loc[df['posmacd']==1,'f1']=df.loc[df['posmacd']==1,'f1']+1
    df.loc[df['posmacd']==2,'f2']=df.loc[df['posmacd']==2,'f2']+1
    df.loc[df['posmacd']==3,'f3']=df.loc[df['posmacd']==3,'f3']+1
    df.loc[df['posmacd']==4,'f4']=df.loc[df['posmacd']==4,'f4']+1
    return df

def savesh8d():
    imp.reload(STS)
    a=STFILE.ANALYSIS()
    df=pd.DataFrame()
    for sn in a.getallfile('SH8'):
        df2=STS.getdposmacd(sn)
        df=df.append(df2)
    return df.to_csv('sh8d.txt')

def savesh8w():
    imp.reload(STS)
    a=STFILE.ANALYSIS()
    df=pd.DataFrame()
    for sn in a.getallfile('SH8'):
        df2=STS.getwposmacd(sn)
        df=df.append(df2)
    return df.to_csv('sh8w.txt')