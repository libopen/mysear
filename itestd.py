import pandas as pd
import STDTB2,imp
import numpy as np
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
    exdb=s.getexdbforseed()[s.DBF]
    return exdb
def dexdb1(sn='ss123456'):
    imp.reload(STDTB2)
    s=STDTB2.STDTB(sn)
    exdb=s.getexdb1()[s.DBF]
    return exdb

def nptest():
    s=STDTB2.STDTB('ss123456')
    exdb=s.db
    exdb['dif'],exdb['dea'],exdb['macd']=talib.MACD(np.array(exdb.c),10,20,6) # c
    exdb=exdb.fillna(0)
    a=exdb[['macd','dif','dea']].values
    exdb['pos1']=np.where((a[:,0]>0) & (a[:,1]>0) & (a[:,2]>0),2,3)
    return exdb[-20:]
    
def seed(sn='ss123456'):
    imp.reload(STDTB2)
    s=STDTB2.STDTB(sn)
    return s.getseed()
def seed1(sn='ss123456'):
    imp.reload(STDTB2)
    s=STDTB2.STDTB(sn)
    return s.getseed1()
CONf1=['mstartdate','msdd','mkmt','wstartdate','wsdd','wkmt','s13startdate','s13sdd','gp6no','s13lastdate','kmt'] 
CONfd= ['sn','s13startdate','s13sdd','s13minc','s13maxc','s13lastc','s13len','s13kmt','s6segs','s13lastdate']

