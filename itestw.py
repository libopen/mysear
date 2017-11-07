import pandas as pd
import STWTB2,imp,STDTB3
def wexdb(sn='ss123456'):
    imp.reload(STWTB2)
    s=STWTB2.STWTB(sn)
    exdb=s.getexdb()[s.DBF]
    return exdb

def wseed(sn='ss123456'):
    imp.reload(STWTB2)
    s=STWTB2.STWTB(sn)
    db=s.seed()
    return db


def testkmt(sn='ss123456'):
    _std=STDTB3.STDTB(sn)
    _stw=STWTB2.STWTB(sn)
    if _stw.seed() is not None:
        gp=_stw.seed()[['sn','keypos','seedmod']]
        dseed=_std.getseed()[['seedmod']].values[0]
        gp['dseed']=dseed
        return gp
      