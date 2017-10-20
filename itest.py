import pandas as pd
def dgp():
    imp.reload(STDTB2)
    s=STDTB2.STDTB('ss123456')
    gp=s.getgp()[s.CONfmore]
    return gp[-10:]


def wgp():
    imp.reload(STWTB)
    s=STWTB.STWTB('ss123456')
    gp=s.getgp()[s.CONf]
    return gp[-10:],s.CONfw

def mgp():
    imp.reload(STWTB)
    s=STWTB.STMTB('ss123456')
    gp=s.getgp()[s.CONf]
    return gp[-10:],s.CONfm

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
def detail1():
    _mgp,fm=mgp() 
    _mgp.columns=fm
    _mgp=_mgp[-1:]
    _mgp=_mgp.set_index('sn')
    _wgp,fw=wgp()
    _wgp=_wgp[-1:]
    _wgp.columns=fw
    _wgp=_wgp.set_index('sn')
    _dgp=dgp()[-1:]
    _dgp=_dgp.set_index('sn')
    gp= pd.concat([_mgp,_wgp,_dgp],axis=1)
    return gp[CONf1]

CONf2=['sn','startdate','sdd','minc','lastc','len','kmt','lastdate']     
def detail2():
    _mgp,fm=mgp() 
    _mgp=_mgp[-1:]
    _mgp.columns=CONf2
    _mgp=_mgp.set_index('sn')
    _wgp,fw=wgp()
    _wgp=_wgp[-1:]
    _wgp.columns=CONf2
    _wgp=_wgp.set_index('sn')
    _dgp=dgp()[-1:]
    _dgp.columns=CONf2
    _dgp=_dgp.set_index('sn')
    gp= pd.concat([_mgp,_wgp,_dgp],axis=0)
    return gp
      