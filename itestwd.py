import pandas as pd
def dgp(sn='ss123456'):
    imp.reload(STDTB2)
    s=STDTB2.STDTB(sn)
    gp=s.getgp13()[s.CONf13]
    return gp[-1:]

def wgp(sn='ss123456'):
    imp.reload(STWTB)
    s=STWTB.STWTB(sn)
    gp=s.getgp()[s.CONf]
    return gp[-1:],s.CONfw



CONf2=['s20startdate','s20sdd','s13kmt','s20startdate','s20sdd','kmt']  
CONfd= ['sn','s13startdate','s13sdd','s13minc','s13maxc','s13lastc','s13len','s13kmt','s6segs','s13lastdate']

def wd1(sn='ss123456'):
     #行对齐
    _wgp,fw=wgp(sn)
    _wgp=_wgp[-1:]
    _wgp.columns=fw
    _wgp=_wgp[['sn','wstartdate','wsdd']]
    _wgp=_wgp.set_index(['sn'])
    _dgp=dgp(sn)
    _dgp=_dgp[['sn','s13startdate','s13sdd']]
    _dgp=_dgp.set_index(['sn'])
    
    gp= pd.concat([_wgp,_dgp],axis=1)
    return gp
    
      
