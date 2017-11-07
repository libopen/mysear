import pandas as pd
import STDTB3,imp
import numpy as np

def dexdb(sn='ss123456'):
    imp.reload(STDTB3)
    s=STDTB3.STDTB(sn)
    exdb=s.getexdb()[s.DBF]
    return exdb

    
def seed(sn='ss123456'):
    imp.reload(STDTB3)
    s=STDTB3.STDTB(sn)
    return s.getseed()
