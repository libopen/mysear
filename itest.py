import pandas as pd
import STTB,STS,imp,STFILE
import numpy as np

def ddb(sn='ss123456',datatype='day'):
    imp.reload(STS)
    imp.reload(STTB)
    gp=STS.getdf(sn,datatype)
        #print(gp[-20:].to_csv(sep='\t'))
    if gp is not None:    
        return gp
    else:
        return 'None'
      
def testkmt(sn='ss123456'):
    imp.reload(STS)
    imp.reload(STTB)
    return STS.getkmt(sn)
    




def getS9(datatype='day'):
    imp.reload(STS)
    imp.reload(STTB)    
    imp.reload(STFILE)
    dfbase=(STS.getdf('SZ399001',datatype)[['date','posmacd']]
          .set_index('date')
          .loc['2016-1-1':])
    a=STFILE.ANALYSIS()
    EXPFIED=['date','posmacd']
    for sn in a.getallfile('SH8809'):  
        df2=(STS.getdf(sn,datatype)[EXPFIED]
                .rename(columns={'posmacd':"{}".format(sn[-2:])})
                .set_index('date')
                .loc['2016-1-1':]
                )
        dfbase=(pd.concat([dfbase,df2],axis=1,join='outer')
                  .fillna(0)
                  .applymap(np.int8))
    
    for col in dfbase.columns:
        a=dfbase[['posmacd',col]].values
        if col!='posmacd':
            dfbase.loc[:,col]=np.where(a[:,0]==a[:,1],1,0)
            
    return dfbase