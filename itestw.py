import pandas as pd
import STWTB,imp
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