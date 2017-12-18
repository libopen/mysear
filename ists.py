import pandas as pd
import STS,imp,STFILE
import numpy as np

def getposdf(datatype='day'):
    imp.reload(STS)
    df1=(STS.getposmacd('ss123456',datatype)
         .drop('posmacd',axis=1)
         .assign(f1=0)
         .assign(f2=0)
         .assign(f3=0)
         .assign(f4=0)
         .assign(ftotal=0)
         .loc['2014-6-1':])
    a=STFILE.ANALYSIS()
    for sn in a.getallfile('SH8'):
        df2=STS.getposmacd(sn,datatype)
        if df2 is not None:
            df1=(pd.concat([df1,df2],axis=1,join='outer')
                 .fillna(0)
                 .pipe(computeposmacd)
                 .drop('posmacd',axis=1)

                 )

        #cols=['f1','f2','f3','f4']
        #df1[cols]=df1[cols].applymap(np.int64)  
    df1=(df1.assign(ratf1=lambda x: x['f1']/x['ftotal'])
         .assign(ratf2=lambda x: x['f2']/x['ftotal'])
         .assign(ratf3=lambda x: x['f3']/x['ftotal'])
         .assign(ratf4=lambda x: x['f4']/x['ftotal']) )
        
    return np.round(df1,decimals=2).to_csv("index_{}.csv".format(datatype))

def computeposmacd(df):
    df.loc[df['posmacd']==1,'f1']=df.loc[df['posmacd']==1,'f1']+1
    df.loc[df['posmacd']==2,'f2']=df.loc[df['posmacd']==2,'f2']+1
    df.loc[df['posmacd']==3,'f3']=df.loc[df['posmacd']==3,'f3']+1
    df.loc[df['posmacd']==4,'f4']=df.loc[df['posmacd']==4,'f4']+1
    df.loc[df['posmacd']>0,'ftotal']=df.loc[df['posmacd']>0,'ftotal']+1
    return df


def saveIndexDetail(datatype='day'):
    imp.reload(STS)
    a=STFILE.ANALYSIS()
    df=pd.DataFrame()
    for sn in a.getallfile('SH8'):
        df2=STS.GetPosmacdDetail(sn,datatype)
        df=df.append(df2)
    return df.to_csv("indexDetail_".format(datatype))





def get2055df(datatype='day'):
    imp.reload(STS)
    df1=(STS.get2055('ss123456',datatype)
         .drop('segdown20',axis=1)
         .drop('segdown55',axis=1)
         .assign(f20=0)
         .assign(f55=0)
         .assign(ftotal=0)
         .loc['2014-6-1':])
    a=STFILE.ANALYSIS()
    for sn in a.getallfile('SH8'):
        df2=STS.get2055(sn,datatype)
        if df2 is not None:
            df1=(pd.concat([df1,df2],axis=1,join='outer')
                 .fillna(0)
                 .pipe(compute2055)
                 .drop('segdown20',axis=1)
                 .drop('segdown55',axis=1)

                 )

        #cols=['f1','f2','f3','f4']
        #df1[cols]=df1[cols].applymap(np.int64)  
    df1=(df1.assign(ratf20=lambda x: x['f20']/x['ftotal'])
         .assign(ratf55=lambda x: x['f55']/x['ftotal']))
        
    return np.round(df1,decimals=2).to_csv("s2055_{}.csv".format(datatype))

def compute2055(df):
    df.loc[df['segdown20']==1,'f20']=df.loc[df['segdown20']==1,'f20']+1
    df.loc[df['segdown55']==1,'f55']=df.loc[df['segdown55']==1,'f55']+1
    df.loc[df['segdown20']>=0,'ftotal']=df.loc[df['segdown20']>0,'ftotal']+1
    return df



def getsh8():
    getposdf('day')
    getposdf('week')
    get2055df('day')
    get2055df('week')
   
    
    


def main():
    getsh8()

if __name__=="__main__":
    main()

    
