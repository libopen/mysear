import pandas as pd
import STTB,imp
import numpy as np

def getposmacd(sn='ss123456'):
    imp.reload(STTB)
    s=STTB.STDTB(sn)
    exdb=(s.getexdb()[['date','posmacd']]
           .set_index(['date'])
           .loc['2015-1-1':]
           )
    return exdb


def getdposmacd(sn='ss123456'):
    imp.reload(STTB)
    s=STTB.STDTB(sn)
    exdb=(s.getexdb()[['date','posmacd']]
           .set_index(['date'])
           .loc['2015-1-1':]
           .assign(sn=lambda x:sn)
           )
    return exdb

def getwposmacd(sn='ss123456'):
    imp.reload(STTB)
    s=STTB.STWTB(sn)
    try:
        exdb=(s.getexdb()[['date','posmacd']]
               .set_index(['date'])
               .loc['2015-1-1':]
               .assign(sn=lambda x:sn)
               )
        return exdb
    except:
        return None


def gettmacd(sn='ss123456'):
    imp.reload(STTB)
    s=STTB.STDTB(sn)
    exdb=(s.getexdb()[['date','tmacd']]
           .set_index(['date'])
           .loc['2015-1-1':]
           )
    return exdb

def getdtmacd(sn='ss123456'):
    imp.reload(STTB)
    s=STTB.STDTB(sn)
    try:
        exdb=(s.getexdb()[['date','tmacd']]
               .set_index(['date'])
               .loc['2015-1-1':]
               .assign(sn=lambda x:sn)
               )
        return exdb
    except:
        return None

def getwtmacd(sn='ss123456'):
    imp.reload(STTB)
    s=STTB.STWTB(sn)
    try:
        exdb=(s.getexdb()[['date','tmacd']]
               .set_index(['date'])
               .loc['2015-1-1':]
               .assign(sn=lambda x:sn)
               )
        return exdb
    except:
        return None
    
