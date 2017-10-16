def dgp():
    imp.reload(STDTB2)
    s=STDTB2.STDTB('ss123456')
    gp=s.getgp()[s.CONf]
    return gp[-10:]



def wgp():
    imp.reload(STDTB2)
    s=STWTB.STWTB('ss123456')
    gp=s.getgp()[s.CONf]
    return gp[-10:]

def mgp():
    imp.reload(STDTB2)
    s=STWTB.STMTB('ss123456')
    gp=s.getgp()[s.CONf]
    return gp[-10:]