import pandas as pd
import STTB,STS,imp,STFILE
import numpy as np

def ddb(sn='ss123456',datatype='day'):
    imp.reload(STS)
    imp.reload(STTB)
    gp=STS.getdf(sn,datatype)
        #print(gp[-20:].to_csv(sep='\t'))
    if gp is not None:    
        return gp[-20:]
    else:
        return 'None'
      
def testkmt(sn='ss123456'):
    imp.reload(STS)
    imp.reload(STTB)
    return STS.getkmt(sn)
    

