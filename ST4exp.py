import pandas as pd
import STS,imp,STFILE,sys
import numpy as np

def getIndexPos(datatype='day'):
    def computeposmacd(df):
        df.loc[df['posmacd']==1,'f1']=df.loc[df['posmacd']==1,'f1']+1
        df.loc[df['posmacd']==2,'f2']=df.loc[df['posmacd']==2,'f2']+1
        df.loc[df['posmacd']==3,'f3']=df.loc[df['posmacd']==3,'f3']+1
        df.loc[df['posmacd']==4,'f4']=df.loc[df['posmacd']==4,'f4']+1
        df.loc[df['posmacd']>0,'ftotal']=df.loc[df['posmacd']>0,'ftotal']+1
        return df    
    df1=(STS.getposmacd('ss123456',datatype)
         .drop('posmacd',axis=1)
         .assign(f1=0)
         .assign(f2=0)
         .assign(f3=0)
         .assign(f4=0)
         .assign(ftotal=0)
         .loc['2014-6-1':])
    a=STFILE.ANALYSIS()
    for sn in a.getallfile('SH8'):
        df2=STS.getposmacd(sn,datatype)
        if df2 is not None:
            df1=(pd.concat([df1,df2],axis=1,join='outer')
                 .fillna(0)
                 .pipe(computeposmacd)
                 .drop('posmacd',axis=1)

                 )

        #cols=['f1','f2','f3','f4']
        #df1[cols]=df1[cols].applymap(np.int64)  
    df1=(df1.assign(ratf1=lambda x: x['f1']/x['ftotal'])
         .assign(ratf2=lambda x: x['f2']/x['ftotal'])
         .assign(ratf3=lambda x: x['f3']/x['ftotal'])
         .assign(ratf4=lambda x: x['f4']/x['ftotal']) )
        
    return np.round(df1,decimals=2).to_csv("index_{}.csv".format(datatype))




def saveIndexDetail(datatype='day'):
    
    a=STFILE.ANALYSIS()
    df=pd.DataFrame()
    for sn in a.getallfile('SH8'):
        df2=STS.GetPosmacdDetail(sn,datatype)
        df=df.append(df2)
    return df.to_csv("indexDetail_".format(datatype))





def getIndex2055(datatype='day'):
    def compute2055(df):
        df.loc[df['segdown20']==1,'f20']=df.loc[df['segdown20']==1,'f20']+1
        df.loc[df['segdown55']==1,'f55']=df.loc[df['segdown55']==1,'f55']+1
        df['ftotal']=df['ftotal']+1
        return df 
    
    df1=(STS.get2055('ss123456',datatype)
         .drop('segdown20',axis=1)
         .drop('segdown55',axis=1)
         .assign(f20=0)
         .assign(f55=0)
         .assign(ftotal=0)
         .loc['2014-6-1':])
    a=STFILE.ANALYSIS()
    for sn in a.getallfile('SH8'):
        df2=STS.get2055(sn,datatype)
        if df2 is not None:
            df1=(pd.concat([df1,df2],axis=1,join='outer')
                 .fillna(0)
                 .pipe(compute2055)
                 .drop('segdown20',axis=1)
                 .drop('segdown55',axis=1)

                 )

        #cols=['f1','f2','f3','f4']
        #df1[cols]=df1[cols].applymap(np.int64)  
    df1=(df1.assign(ratf20=lambda x: x['f20']/x['ftotal'])
         .assign(ratf55=lambda x: x['f55']/x['ftotal']))
        
    return np.round(df1,decimals=2).to_csv("s2055_{}.csv".format(datatype))






def getsh8():
    getIndexPos('day')
    getIndexPos('week')
    getIndex2055('day')
    getIndex2055('week')
   
    
def savedb(sn='ss123456',datatype='day',filename='d.csv'):
    #1 get the key date ,get the posmacd=1 find sn
    #2 get every sn sma20,sam55,and index data concat
    EXPFIED=['date','sma55','sma20','posmacd']
    (STS.getdf(sn,datatype)[EXPFIED]
            .set_index('date')
            .to_csv(filename))
    
    
def getindex(datatype='day'):
    indexlist=['SZ399001','SZ399005','SZ399006','SZ399106']
    dfbase=(STS.getdf('ss123456',datatype)[['date','posmacd']]
          .drop('posmacd',axis=1)
          .set_index('date'))
    
    a=STFILE.ANALYSIS()
    EXPFIED=['date','sma20']
    baseColname=['s20']
    for sn in indexlist:
        #renameColname=["{}{}".format(x,sn[-3:]) for x in baseColname] #new name s55+sn[-3:],s20+sn[-3]
        df2=(STS.getdf(sn,datatype)[EXPFIED]
                .set_index('date')
                .rename(columns={'sma20':"s20{}".format(sn[-3:])})
                )
        if df2 is not None:
            dfbase=(pd.concat([dfbase,df2],axis=1,join='outer')
                 .fillna(0)

                 )    
    a=STFILE.ANALYSIS()
    for sn in a.getallfile('SH8809'):  
        if sn[-2:] in ['30','18','44','02']:
            df2=(STS.getdf(sn,datatype)[EXPFIED]
                        .set_index('date')
                        .rename(columns={'sma20':"s20{}".format(sn[-4:])})
                            ) 
            dfbase=(pd.concat([dfbase,df2],axis=1,join='outer')
                     .fillna(0))
            
    return dfbase.to_csv('sin9.csv')    
    
    
def help():
    print("-s :export sin9.csv")
    print("-i :export index_day.csv")
    print("-k :export kmt")
    print("-d :sn dayfilename.csv :export sn day df")
    print("-w :sn weekfilename.csv :export sn week df ")

def main():
    if (sys.argv[1]=='-h'):
        help()
    elif (sys.argv[1]=='-i'):
        getsh8()
    elif (sys.argv[1]=='-s'):
            getindex()    
    elif (sys.argv[1]=='-k'):
        print(STS.getkmt(sys.argv[2]))
    elif (sys.argv[1]=='-d'):
        savedb(sn=sys.argv[2], filename=sys.argv[3])
    else:
        help()
         
        
   
if __name__=="__main__":
    main()

    
