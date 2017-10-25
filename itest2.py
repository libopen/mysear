import pandas as pd
def dgp(sn='ss123456'):
    imp.reload(STDTB2)
    s=STDTB2.STDTB(sn)
    gp=s.getgp13()[s.CONf13]
    return gp[-10:]

def wgp(sn='ss123456'):
    imp.reload(STWTB)
    s=STWTB.STWTB(sn)
    gp=s.getgp()[s.CONfw]
    return gp[-1:]


def dexdb(sn='ss123456'):
    imp.reload(STDTB2)
    s=STDTB2.STDTB(sn)
    exdb=s.getexdb()[s.DBF]
    return exdb
def wexdb(sn='ss123456'):
    imp.reload(STWTB)
    s=STWTB.STWTB(sn)
    exdb=s.getexdb()[s.DBF]
    return exdb
CONf1=['mstartdate','msdd','mkmt','wstartdate','wsdd','wkmt','s13startdate','s13sdd','gp6no','s13lastdate','kmt'] 
def wgp(sn='ss123456'):
    imp.reload(STWTB)
    s=STWTB.STWTB(sn)
    gp=s.getgp()[s.CONf]
    return gp[-10:],s.CONfw

def mgp1(sn='ss123456'):
    imp.reload(STWTB)
    s=STWTB.STMTB(sn)
    gp=s.getgp()[s.CONf]
    return gp[-10:],s.CONfm

def detail1(sn='ss123456'):
    _mgp,fm=mgp1(sn) 
    _mgp.columns=fm
    _mgp=_mgp[-1:]
    _mgp=_mgp.set_index('sn')
    _wgp,fw=wgp1(sn)
    _wgp=_wgp[-1:]
    _wgp.columns=fw
    _wgp=_wgp.set_index('sn')
    _dgp=dgp()[-1:]
    _dgp=_dgp.set_index('sn')
    gp= pd.concat([_mgp,_wgp,_dgp],axis=1)
    return gp[CONf1]

CONf2=['s20startdate','s20sdd','s13kmt','s20startdate','s20sdd','kmt']  
CONfd= ['sn','s13startdate','s13sdd','s13minc','s13maxc','s13lastc','s13len','s13kmt','s6segs','s13lastdate']

def detailwd(sn='ss123456'):
   
    _wgp,fw=wgp(sn)
    _wgp=_wgp[-1:]
    _wgp.columns=fw
    _wgp=_wgp['sn','wstartdate','wsdd']
    _wgp=_wgp.set_index('sn')
    #_dgp=dgp(sn)[-1:]
    #_dgp=_dgp['sn','s13startdate','s13sdd']
    #_dgp=_dgp.set_index('sn')
    
    #gp= pd.concat([_wgp,_dgp],axis=1)
    #return gp
    return _wgp
      
