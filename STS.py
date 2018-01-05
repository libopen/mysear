import pandas as pd
import STTB,imp
import numpy as np

def getposmacd(sn='ss123456',datatype='day'):
    imp.reload(STTB)
    if datatype=='day':
        s=STTB.STDTB(sn)
    else:  # by week
        s=s=STTB.STWTB(sn)
    try:
        exdb=(s.getexdb()[['date','posmacd']]
               .set_index(['date'])
               .loc['2014-6-1':]
               )
        return exdb
    except:
        return None

def get2055(sn='ss123456',datatype='day'):
    imp.reload(STTB)
    if datatype=='day':
        s=STTB.STDTB(sn)
    else:  # by week
        s=s=STTB.STWTB(sn)
    try:
        exdb=(s.getexdb()[['date','segdown20','segdown55']]
               .set_index(['date'])
               .loc['2014-6-1':]
               )
        return exdb
    except:
        return None

def GetPosmacdDetail(sn='ss123456',datatype='day'):
    imp.reload(STTB)
    if datatype=='day':
        s=STTB.STDTB(sn)
    else:  # by week
        s=STTB.STWTB(sn)
    try:
        exdb=(s.getexdb()[['date','posmacd']]
               .set_index(['date'])
               .loc['2014-6-1':]
               .assign(sn=lambda x:sn)
               )
        return exdb
    except:
        return None



def getkmt(sn='ss123456'):
  
    _std=STTB.STDTB(sn)
    _stw=STTB.STWTB(sn)
    if _stw.seed() is not None:
        return "{},{}".format(_stw.seed(),_std.seed())
        #_gp=_stw.seed()[['sn','seedmod','areamod','keymod']]
        #_dgp=_std.seed()[['seedmod','areamod','keymod']]
        #_dgp.columns=['dseedmod','dareamod','dkeymod']
        #gp=pd.concat([_gp,_dgp],axis=1)[['sn','seedmod','areamod','keymod','dseedmod','dareamod','dkeymod']]
        #gp['keymod_key']=gp['keymod'].str.split(':').str[0].astype(str)
        #gp['dkeymod_key']=gp['dkeymod'].str.split(':').str[0].astype(str)
        #cols=['sn','areamod','dareamod','seedmod','dseedmod','keymod_key','dkeymod_key','keymod','dkeymod']
       
        #return gp[cols]
        
def getdf(sn='ss123456',datatype='day',dbf='DBF'):
    def getdbf(s,dbf):
        if dbf=='DBF':
            return s.DBF
        else:
            return s.TRENDDBF
    
    if datatype=='day':
        s=STTB.STDTB(sn)
        return s.getexdb()[getdbf(s, dbf)]
    elif datatype=='week':
        s=STTB.STWTB(sn)
        if s.getexdb() is not None:
            return s.getexdb()[getdbf(s, dbf)]
           


def comTrend(sn='ss123456',datatype='day',begindate='2017-6-23'):
    def comp(df,datatype):
        a=df[['posmacd','ang20flag','ang55flag','isbigup','segdown20','segdown55']].values 
        if (datatype=='day'):  
            #                               ang20flag      ang55flag     isbigup     segdown20       segdown55
            df.loc[:,'comvalue']=np.where(((a[:,1]==1) & ( a[:,2]==0) & (a[:,3]==0) &(a[:,4]==1) &(a[:,5]==0)),1,0)
        else:
            df.loc[:,'comvalue']=np.where(((a[:,0]==3) & ( a[:,2]==1) & (a[:,3]==1)  ),1,0)        
        return df 

    EXPFIELD=['date','posmacd','ang20flag','ang55flag','isbigup','segdown20','segdown55']
    
    #week number
    n=-6
    if datatype=='day': #day number
        n=-10
    
    df1=(getdf(sn,datatype)[EXPFIELD]
                .set_index('date')
                .loc[:begindate][n:]
                .assign(comvalue=0)
                .pipe(comp,datatype)
                )
    ldate=len(df1.index)
    _t1=df1['comvalue'].sum()/df1['comvalue'].count() 
    df2=(df1[0:ldate-1].drop('comvalue',axis=1)
                       .assign(comvalue=0)
                       .pipe(comp,datatype)
            )
    _t2=df2['comvalue'].sum()/df2['comvalue'].count()
    _up55_1=df1['segdown55'].sum() #total  up55
    return df1 ,_t2>=_t1>0.6,round(_t1,3),_up55_1
