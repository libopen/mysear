import pandas as pd
import STTB,imp
import numpy as np

def getposmacd(sn='ss123456',datatype='day'):
    imp.reload(STTB)
    if datatype=='day':
        s=STTB.STDTB(sn)
    else:  # by week
        s=s=STTB.STWTB(sn)
    try:
        exdb=(s.getexdb()[['date','posmacd']]
               .set_index(['date'])
               .loc['2014-6-1':]
               )
        return exdb
    except:
        return None

def get2055(sn='ss123456',datatype='day'):
    imp.reload(STTB)
    if datatype=='day':
        s=STTB.STDTB(sn)
    else:  # by week
        s=s=STTB.STWTB(sn)
    try:
        exdb=(s.getexdb()[['date','segdown20','segdown55']]
               .set_index(['date'])
               .loc['2014-6-1':]
               )
        return exdb
    except:
        return None

def GetPosmacdDetail(sn='ss123456',datatype='day'):
    imp.reload(STTB)
    if datatype=='day':
        s=STTB.STDTB(sn)
    else:  # by week
        s=STTB.STWTB(sn)
    try:
        exdb=(s.getexdb()[['date','posmacd']]
               .set_index(['date'])
               .loc['2014-6-1':]
               .assign(sn=lambda x:sn)
               )
        return exdb
    except:
        return None



def getkmt(sn='ss123456'):
  
    _std=STTB.STDTB(sn)
    _stw=STTB.STWTB(sn)
    if _stw.seed() is not None:
        return "{},{}".format(_stw.seed(),_std.seed())
        #_gp=_stw.seed()[['sn','seedmod','areamod','keymod']]
        #_dgp=_std.seed()[['seedmod','areamod','keymod']]
        #_dgp.columns=['dseedmod','dareamod','dkeymod']
        #gp=pd.concat([_gp,_dgp],axis=1)[['sn','seedmod','areamod','keymod','dseedmod','dareamod','dkeymod']]
        #gp['keymod_key']=gp['keymod'].str.split(':').str[0].astype(str)
        #gp['dkeymod_key']=gp['dkeymod'].str.split(':').str[0].astype(str)
        #cols=['sn','areamod','dareamod','seedmod','dseedmod','keymod_key','dkeymod_key','keymod','dkeymod']
       
        #return gp[cols]
        
def getdf(sn='ss123456',datatype='day',dbf='DBF'):
    def getdbf(s,dbf):
        
        if dbf=='DBF':
            return s.DBF
        else:
            return s.TRENDDBF
    
    if datatype=='day':
        s=STTB.STDTB(sn)
        return s.getexdb()[getdbf(s, dbf)]
    elif datatype=='week':
        s=STTB.STWTB(sn)
        if s.getexdb() is not None:
            return s.getexdb()[getdbf(s, dbf)]
           
# search by week :3 rule ang55 is up and isbigup and the segment is posmacd==3
def SearchByWeek1(sn='ss123456',datatype='week',begindate='2017-6-23'):
    # sma55>0 up and sma22 is up sma55 in the week
    def shiftang(df):
        df.loc[:,'ang20_1']=df.loc[:,'ang20'].shift(1)
        df.loc[:,'ang55_1']=df.loc[:,'ang55'].shift(1)
        df=df.fillna(0)
        return df

    EXPFIELD=['date','posmacd','ang20flag','ang55flag','isbigup','segdown20','segdown55','ang20','ang55','sma20','sma55','kdup']
    
    #week number
    n=-6
    if datatype=='day': #day number
        n=-10
    #
    df1=(getdf(sn,datatype)[EXPFIELD]
                .pipe(shiftang)
                .set_index('date')
                .loc[:begindate][n:]
                )
    df=df1['kdup']>0 #kdup have >0
    _ratkdup=df[df==True].count()/df1['kdup'].count()
    df=df1[df1.ang55>0]['ang55']>df1[df1.ang55>0]['ang55_1'] #ang55<0 and ang55>ang55_1
    _rat55=df[df==True].count()/df1['ang55'].count()
    df=df1['isbigup']==1
    _ratbigup=df[df==True].count()/df1['isbigup'].count()
    df=df1['posmacd']==3
    _ratpos=df[df==True].count()/df1['posmacd'].count()
    
    #compare ang20 ang20_1 ang55 and ang55_1
    
    return  (_rat55>0.5 and _ratpos>0.9 and _ratbigup>0.9),df1,_ratkdup,_rat55,_ratpos,_ratbigup
#search by day and week 
def SearchByDay(sn='ss123456',datatype='day',begindate='2017-6-23'):
    
    def shiftang(df):
        df.loc[:,'ang20_1']=df.loc[:,'ang20'].shift(1)
        df.loc[:,'ang55_1']=df.loc[:,'ang55'].shift(1)
        df=df.fillna(0)
        return df
    def comp(df,datatype):
        a=df[['posmacd','ang20flag','ang55flag','isbigup','segdown20','segdown55']].values 
        if (datatype=='day'):  
            #                               posmacd                   ang20flag        ang55         isbigup     segdown20       segdown55
            df.loc[:,'comvalue']=np.where((((a[:,0]==2)|(a[:,0]==3)) & (a[:,1]==1)& ( a[:,2]==0) & (a[:,3]==0) &(a[:,4]==1) ),1,0)
        else:
            df.loc[:,'comvalue']=np.where(((a[:,0]==3) & ( a[:,2]==1) & (a[:,3]==1)  ),1,0)        
        return df 

    EXPFIELD=['date','posmacd','ang20flag','ang55flag','isbigup','segdown20','segdown55','ang20','ang55','sma20','sma55']
    
    #week number
    n=-6
    if datatype=='day': #day number
        n=-10
    #
    df1=(getdf(sn,datatype)[EXPFIELD]
                .pipe(shiftang)
                .set_index('date')
                .loc[:begindate][n:]
                .assign(comvalue=0)
                .pipe(comp,datatype)
                )
    df=df1[df1.ang20>0.0]['ang20']>df1[df1.ang20>0]['ang20_1'] #ang20>0 and ang20>ang20_1
    _rat20=df[df==True].count()/df1['ang20'].count()
    df=df1[df1.ang55<0.0]['ang55']>df1[df1.ang55<0]['ang55_1'] #ang55<0 and ang55>ang55_1
    _rat55=df[df==True].count()/df1['ang55'].count()
    df=df1['isbigup']==0
    _ratbigup=df[df==True].count()/df1['isbigup'].count()
    df=df1['posmacd']==2
    _ratpos=df[df==True].count()/df1['posmacd'].count()
    
    #compare ang20 ang20_1 ang55 and ang55_1
    
    return df1,min(_rat20,_rat55),_ratpos,_ratbigup
    #ldate=len(df1.index)
    #_t1=df1['comvalue'].sum()/df1['comvalue'].count() 
    #df2=(df1[0:ldate-1].drop('comvalue',axis=1)
                       #.assign(comvalue=0)
                       #.pipe(comp,datatype)
            #)
    #_t2=df2['comvalue'].sum()/df2['comvalue'].count()
    #_up55=df1['segdown55'].sum()/df2['comvalue'].count() #total  up55
    #_up55ang=df1['ang55flag'].sum()
    #return df1 ,_t2>=.6 or _t1>=0.6,round(_t1,3),_up55,_up55ang


def SearchByWeek(sn='ss123456',datatype='day',begindate='2017-6-23'):
    def shiftang(df):
            df.loc[:,'ang20_1']=df.loc[:,'ang20'].shift(1)
            df.loc[:,'ang55_1']=df.loc[:,'ang55'].shift(1)
            df=df.fillna(0)
            return df    
    def getpositions(db,segupname,segdownname):
        
        _idlast,_idmid,_idfirst=0,0,0
        _idmid  =min(db.max(axis=0)[segupname],db.max(axis=0)[segdownname])
        _idfirst=max(db.max(axis=0)[segupname],db.max(axis=0)[segdownname])
        if (db.loc[_idmid][segupname]==0): # segup==0 show that _idmin is down
            _idlast=db.loc[(db.index<_idmid)].max(axis=0)[segupname]
        else:
            _idlast=db.loc[(db.index<_idmid)].max(axis=0)[segdownname]
        return int(_idlast),int(_idmid),int(_idfirst)
            
        
   
    #get  segment trend
    def getMacdMode(db,clstype):
        #get posmacdtail-posmacdhead-anghead
        _IDLast,_IDMid,_IDFirst=getpositions(db,segupname='segup',segdownname='segdown')
        #print("{}-{}-{}".format(_IDLast,_IDMid,_IDFirst))
        # compare bigup get ratinBig
        _ratInBig=0.0
        if db.loc[_IDFirst]['segdown']==0: #current is up compare preseg with bigup
            df=db.loc[_IDLast+1:_IDMid]['segdown']==db.loc[_IDLast+1:_IDMid]['bigup']
            _ratInBig=df[df==True].count()/df.count()
        else:
            df=db.loc[_IDMid+1:_IDFirst]['segdown']==db.loc[_IDMid+1:_IDFirst]['bigup']
            _ratInBig=df[df==True].count()/df.count()
        _mod="{}{}{}:{}".format(int(db.loc[_IDLast]['posmacd']),int(db.loc[_IDMid]['posmacd']),int(db.loc[_IDFirst]['posmacd']),int(_IDFirst-_IDMid))    
        #ang55 direction
        df=db.loc[_IDMid:_IDFirst][db.ang55>0.0]['ang55']>db.loc[_IDMid:_IDFirst][db.ang55>0]['ang55_1'] #ang55<0 and ang55>ang55_1
        _rat55=df[df==True].count()/db.loc[_IDMid:_IDFirst]['ang55'].count()        
        #_b55up=db.loc[_IDMid]['ang55']<db.loc[_IDFirst]['ang55']
        #return _mod,_b55up,df[df==True].count()/df.count(),_ratInBig
        return (_rat55>0.9 and _ratInBig>0.9),"M{}-{}-{:2f}-{:.2f}".format(clstype[0].upper(),_mod,_rat55,_ratInBig)
    ##get kdj segemnt trend
    def getKDseg(db,clstype):
        _IDLast,_IDMid,_IDFirst=getpositions(db,segupname='kdup',segdownname='kddown')
        
        return (db.loc[_IDFirst]['kdup']>0),"[{0}-{1}]".format(int(_IDFirst-_IDMid),int(_IDMid-_IDLast))        
    SEEDDBF=['date','posmacd','bigdown','bigup','segdown','segup','kddown','kdup','angflag','ang20flag','ang20','ang55','id']
    
    db=(getdf(sn,datatype)[SEEDDBF]
                    .pipe(shiftang)
                    .set_index('date')
                    .loc[:begindate]
                    .set_index('id')
                    )
    #return getpositions(db,segupname='bigup', segdownname='bigdown')
    return (getMacdMode(db,datatype)[0]==True and getKDseg(db, datatype)[0]==True), "{0},{1}".format(getMacdMode(db,datatype),getKDseg(db, datatype))
    #return  "{0},{1}".format(getMacdMode(db,datatype),getKDseg(db, datatype))
    #if db is not None and len(db)>60:
        #return "{},{}".format(getMacdMode(db,datatype),getKDseg(db,datatype))

    #else:
        #return None
