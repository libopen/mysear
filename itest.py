import pandas as pd
import STTB,imp
def ddb(sn='ss123456'):
    imp.reload(STTB)
    s=STTB.STDTB(sn)
    gp=s.getexdb()[s.DBF]
    return gp[-20:]

def wdb(sn='ss123456'):
    imp.reload(STTB)
    s=STTB.STWTB(sn)
    gp=s.getexdb()[s.DBF]
    return gp[-20:]


def dseed(sn='ss123456'):
    imp.reload(STTB)
    s=STTB.STDTB(sn)
    exdb=s.seed()
    return exdb
def wseed(sn='ss123456'):
    imp.reload(STTB)
    s=STTB.STWTB(sn)
    gp=s.seed()
    return gp
      
def testkmt(sn='ss123456'):
    _std=STTB.STDTB(sn)
    _stw=STTB.STWTB(sn)
    if _stw.seed() is not None:
        _gp=_stw.seed()[['sn','seedmod','areamod','keymod']]
        _dgp=_std.seed()[['seedmod','areamod','keymod']]
        _dgp.columns=['dseedmod','dareamod','dkeymod']
        gp=pd.concat([_gp,_dgp],axis=1)[['sn','seedmod','areamod','keymod','dseedmod','dareamod','dkeymod']]
        return gp
    