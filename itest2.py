import pandas as pd
import sfindkey2,imp
def ddb(sn='ss123456'):
    imp.reload(sfindkey2)
    s=sfindkey2.STDTB(sn)
    gp=s.getexdb()[s.DBF]
    return gp[-20:]



def wdb(sn='ss123456'):
    imp.reload(sfindkey2)
    s=sfindkey2.STWTB(sn)
    gp=s.getexdb()[s.DBF]
    return gp[-20:]


    