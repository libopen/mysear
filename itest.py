import pandas as pd
import STTB,STS,imp,STFILE
import numpy as np
import datetime

def ddb(startdate,sn='ss123456',datatype='day',dbf='DBF'):
    imp.reload(STS)
    imp.reload(STTB)
   
    gp=(STS.getdf(sn,datatype,dbf)
           .set_index('date')[:startdate]
           .set_index('id')
           )
        #print(gp[-20:].to_csv(sep='\t'))
    if gp is not None:    
        return gp
    else:
        return 'None'
      
def Search(sn='ss123456',methodtype='day',datetype='day',begindate='2017-5-23'):
    imp.reload(STS)
    imp.reload(STTB)
    if methodtype=='day':
        return STS.SearchByDay(sn, datetype,begindate)   
    elif methodtype=='week':
        return STS.SearchByWeek(sn, datetype,begindate)   
    elif methodtype=='week1':
        return STS.SearchByWeek1(sn, datetype,begindate)   


    


def getS9(datatype='day',begindate='2017-6-23',pat='SH8803'):
    imp.reload(STS)
    imp.reload(STTB)    
    imp.reload(STFILE)

    a=STFILE.ANALYSIS()
    #mylist=a.getallfile('SH880')+a.getallfile('SH8804')
    mylist=a.getallfile(pat)
    i,j=0,0
    dfcomp=pd.DataFrame()
    for sn in mylist:  
        getit,seed=STS.getS9bysn(sn,begindate)
        if getit==True:
            i=i+1
            j=j+1
            print("{},{}".format( sn,seed))
        else:
            i=i+1

           #dfcomp,ratkd,rat55,ratpos,ratinbig=(STS.KDTrend(sn,datatype,begindate))
           #if rat55>=0.5 and ratpos==1.0 and ratinbig==1.0:
           #    print("{}-{}".format(sn,ratkd))
    print( "{i},{j}".format(i=i,j=j))

