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
        
def getdf(sn='ss123456',datatype='day'):
    if datatype=='day':
        s=STTB.STDTB(sn)
        return s.getexdb()[s.DBF]
    elif datatype=='week':
        s=STTB.STWTB(sn)
        if s.getexdb() is not None:
            return s.getexdb()[s.DBF]
