import pandas as pd
import STTB,STS,imp,STFILE
import numpy as np
def getposdf(datatype='day'):
    imp.reload(STS)
    def computeposmacd(df):
        
        df.loc[df['posmacd']==1,'f1']=df.loc[df['posmacd']==1,'f1']+1
        df.loc[df['posmacd']==2,'f2']=df.loc[df['posmacd']==2,'f2']+1
        df.loc[df['posmacd']==3,'f3']=df.loc[df['posmacd']==3,'f3']+1
        df.loc[df['posmacd']==4,'f4']=df.loc[df['posmacd']==4,'f4']+1
        df['ftotal']=df['ftotal']+1
        return df
    
    
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
            .assign(ratf4=lambda x: x['f4']/x['ftotal'])
             )
    return np.round(df1,decimals=2)




def ddb(sn='ss123456',datatype='day'):
    imp.reload(STS)
    gp=STS.getdf(sn,datatype)
        #print(gp[-20:].to_csv(sep='\t'))
    if gp is not None:    
        return gp[-20:]
    else:
        return 'None'
      
def testkmt(sn='ss123456'):
    imp.reload(STS)
    return STS.getkmt(sn)
    

