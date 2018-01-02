import pandas as pd
import STTB,STS,imp,STFILE
import numpy as np

def ddb(sn='ss123456',datatype='day'):
    imp.reload(STS)
    imp.reload(STTB)
    gp=(STS.getdf(sn,datatype)
           .set_index('date'))
        #print(gp[-20:].to_csv(sep='\t'))
    if gp is not None:    
        return gp
    else:
        return 'None'
      
def testkmt(sn='ss123456'):
    imp.reload(STS)
    imp.reload(STTB)
    return STS.getkmt(sn)
    

def ct(sn='ss123456',datatype='day',begindate='2017-5-23',enddate='2017-6-23'):
    imp.reload(STS)
    imp.reload(STTB)    
    imp.reload(STFILE)
    return STS.comTrend(sn,datatype,begindate,enddate)
    


def getS9(datatype='day',begindate='2017-5-23',enddate='2017-6-23'):
    imp.reload(STS)
    imp.reload(STTB)    
    imp.reload(STFILE)

    a=STFILE.ANALYSIS()
    list3=a.getallfile('SH8803')
    list4=a.getallfile('SH8804')
    mylist=list3+list4
    i,j=0,0
    dfcomp=pd.DataFrame()
    for sn in mylist:  
        dfcomp,prelike=(STS.comTrend(sn,datatype,begindate,enddate))
        i=i+1
        if prelike==True:    
            j=j+1
            print("{}{}".format( sn,prelike))
    print( "{i},{j}".format(i=i,j=j))

