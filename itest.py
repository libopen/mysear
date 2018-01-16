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
      
def Search(sn='ss123456',methodtype='day',begindate='2017-5-23'):
    imp.reload(STS)
    imp.reload(STTB)
    if methodtype=='day':
        return STS.SearchByDay(sn, 'day',begindate)   
    elif methodtype=='week':
        return STS.SearchByWeek(sn, 'week',begindate)   
    elif methodtype=='week1':
        return STS.SearchByWeek1(sn, 'week',begindate)   


    


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
        try:
            dfcomp,prelike,ratpos,ratbigup=(STS.comTrend(sn,datatype,begindate))
            i=i+1
            if prelike>=0.5 and ratpos>0.4:    
                j=j+1
                print("{}-{}-{:.2f}-{:.2f}-{}".format( sn,prelike,ratpos,ratbigup,seed(sn=sn,datatype='week',begindate=begindate)))

           #dfcomp,ratkd,rat55,ratpos,ratinbig=(STS.KDTrend(sn,datatype,begindate))
           #if rat55>=0.5 and ratpos==1.0 and ratinbig==1.0:
           #    print("{}-{}".format(sn,ratkd))
        except:
            print(sn)
            continue
    print( "{i},{j}".format(i=i,j=j))

