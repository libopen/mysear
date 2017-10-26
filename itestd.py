import pandas as pd
import STDTB2,imp
def dgp(sn='ss123456'):
    imp.reload(STDTB2)
    s=STDTB2.STDTB(sn)
    gp=s.getgp13()[s.CONf13]
    return gp[-10:]
def dgp6(sn='ss123456'):
    imp.reload(STDTB2)
    s=STDTB2.STDTB(sn)
    gp=s.getgp()[s.CONfmore]
    return gp[-10:]

def dexdb(sn='ss123456'):
    imp.reload(STDTB2)
    s=STDTB2.STDTB(sn)
    exdb=s.getexdb()[s.DBF]
    return exdb
CONf1=['mstartdate','msdd','mkmt','wstartdate','wsdd','wkmt','s13startdate','s13sdd','gp6no','s13lastdate','kmt'] 
CONfd= ['sn','s13startdate','s13sdd','s13minc','s13maxc','s13lastc','s13len','s13kmt','s6segs','s13lastdate']

