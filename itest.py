import pandas as pd
import STTB,STS,imp,STFILE
import numpy as np
import datetime

def ddb(startdate,sn='ss123456',datatype='day',dbf='DBF'):
    imp.reload(STS)
    imp.reload(STTB)
   
    gp=(STS.getdf(sn,datatype,dbf)
           .set_index('date')
           )[:startdate]
        #print(gp[-20:].to_csv(sep='\t'))
    if gp is not None:    
        return gp
    else:
        return 'None'
      
def testkmt(sn='ss123456'):
    imp.reload(STS)
    imp.reload(STTB)
    return STS.getkmt(sn)
    

def ct(sn='ss123456',datatype='day',begindate='2017-5-23'):
    imp.reload(STS)
    imp.reload(STTB)    
    imp.reload(STFILE)
    return STS.comTrend(sn,datatype,begindate)
    


def getS9(datatype='day',begindate='2017-6-23',pat='SH8803'):
    imp.reload(STS)
    imp.reload(STTB)    
    imp.reload(STFILE)

    a=STFILE.ANALYSIS()
    #list3=a.getallfile('SH880')
    #list4=a.getallfile('SH8804')
    #mylist=list3+list4
    mylist=a.getallfile(pat)
    i,j=0,0
    dfcomp=pd.DataFrame()
    for sn in mylist:  
        dfcomp,prelike,t1,u55,u55ang=(STS.comTrend(sn,datatype,begindate))
        i=i+1
        if prelike==True and u55>0.5:    
            j=j+1
            print("{}-{}-{}-{}".format( sn,t1,u55,u55ang))
    print( "{i},{j}".format(i=i,j=j))

