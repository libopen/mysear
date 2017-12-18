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



#def gettmacd(sn='ss123456'):
    #imp.reload(STTB)
    #s=STTB.STDTB(sn)
    #exdb=(s.getexdb()[['date','tmacd']]
           #.set_index(['date'])
           #.loc['2015-1-1':]
           #)
    #return exdb

#def getdtmacd(sn='ss123456'):
    #imp.reload(STTB)
    #s=STTB.STDTB(sn)
    #try:
        #exdb=(s.getexdb()[['date','tmacd']]
               #.set_index(['date'])
               #.loc['2015-1-1':]
               #.assign(sn=lambda x:sn)
               #)
        #return exdb
    #except:
        #return None

#def getwtmacd(sn='ss123456'):
    #imp.reload(STTB)
    #s=STTB.STWTB(sn)
    #try:
        #exdb=(s.getexdb()[['date','tmacd']]
               #.set_index(['date'])
               #.loc['2015-1-1':]
               #.assign(sn=lambda x:sn)
               #)
        #return exdb
    #except:
        #return None
    
