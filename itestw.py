import pandas as pd
import STWTB,imp,STDTB2
def wexdb(sn='ss123456'):
    imp.reload(STWTB)
    s=STWTB.STWTB(sn)
    exdb=s.getexdb()[s.DBF]
    return exdb
def wexdb1(sn='ss123456'):
    imp.reload(STWTB)
    s=STWTB.STWTB(sn)
    exdb=s.getexdb1()[s.DBF]
    return exdb
def wseed(sn='ss123456'):
    imp.reload(STWTB)
    s=STWTB.STWTB(sn)
    db=s.seed()
    return db
def wseed1(sn='ss123456'):
    imp.reload(STWTB)
    s=STWTB.STWTB(sn)
    db=s.seed1()
    return db


def testkmt(sn='ss123456'):
    _std=STDTB2.STDTB(sn)
    _stw=STWTB.STWTB(sn)
    if _stw.seed() is not None:
        gp=_stw.seed()[['sn','keypos','seedmod']]
        gp['seed']='0'
        seed=_std.getseed1()
        if 'u' in seed   :
            gp['seed']=seed
        return gp
      