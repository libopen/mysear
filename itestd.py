import pandas as pd
import STDTB2,imp
import numpy as np

def dexdb1(sn='ss123456'):
    imp.reload(STDTB2)
    s=STDTB2.STDTB(sn)
    exdb=s.getexdb1()[s.DBF]
    return exdb

    
def seed1(sn='ss123456'):
    imp.reload(STDTB2)
    s=STDTB2.STDTB(sn)
    return s.getseed1()
