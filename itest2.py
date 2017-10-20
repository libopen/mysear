import pandas as pd
def dgp():
    imp.reload(STDTB2)
    s=STDTB2.STDTB('ss123456')
    gp=s.getgp13()[s.CONf13]
    return gp[-10:]

def wgp():
    imp.reload(STWTB)
    s=STWTB.STWTB('ss123456')
    gp=s.getgp()[s.CONf]
    return gp[-1:]


def dexdb():
    imp.reload(STDTB2)
    s=STDTB2.STDTB('ss123456')
    exdb=s.getexdb()[s.DBF]
    return exdb
def wexdb():
    imp.reload(STWTB)
    s=STWTB.STWTB('ss123456')
    exdb=s.getexdb()[s.DBF]
    return exdb
CONf1=['mstartdate','msdd','mkmt','wstartdate','wsdd','wkmt','s13startdate','s13sdd','gp6no','s13lastdate','kmt'] 
def wgp():
    imp.reload(STWTB)
    s=STWTB.STWTB('ss123456')
    gp=s.getgp()[s.CONf]
    return gp[-10:],s.CONfw

def mgp1():
    imp.reload(STWTB)
    s=STWTB.STMTB('ss123456')
    gp=s.getgp()[s.CONf]
    return gp[-10:],s.CONfm

def detail1():
    _mgp,fm=mgp1() 
    _mgp.columns=fm
    _mgp=_mgp[-1:]
    _mgp=_mgp.set_index('sn')
    _wgp,fw=wgp1()
    _wgp=_wgp[-1:]
    _wgp.columns=fw
    _wgp=_wgp.set_index('sn')
    _dgp=dgp()[-1:]
    _dgp=_dgp.set_index('sn')
    gp= pd.concat([_mgp,_wgp,_dgp],axis=1)
    return gp[CONf1]

CONf2=['13startdate','s13sdd','s13kmt','s20startdate','s20sdd','kmt']  
CONfd= ['sn','s13startdate','s13sdd','s13minc','s13maxc','s13lastc','s13len','s13kmt','s6segs','s13lastdate']

def detail2():
   
    _wgp,fw=wgp1()
    _wgp=_wgp[-1:]
    #_wgp.columns=CONf2
    _wgp=_wgp.set_index('sn')
    _dgp=dgp()[-1:]
    #_dgp.columns=CONfd
    #_dgp.columns=CONf2
    _dgp=_dgp.set_index('sn')
    gp= pd.concat([_wgp,_dgp],axis=0)
    return gp[CONf2]
      
