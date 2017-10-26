import pandas as pd
import STWTB,imp
def wexdb(sn='ss123456'):
    imp.reload(STWTB)
    s=STWTB.STWTB(sn)
    exdb=s.getexdb()[s.DBF]
    return exdb

def wcurstate(sn='ss123456'):
    imp.reload(STWTB)
    s=STWTB.STWTB(sn)
    db=s.curstate()
    return db