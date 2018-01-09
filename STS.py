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
           


def comTrend(sn='ss123456',datatype='day',begindate='2017-6-23'):
    def comp(df,datatype):
        a=df[['posmacd','ang20flag','ang55flag','isbigup','segdown20','segdown55']].values 
        if (datatype=='day'):  
            #                               posmacd      ang20flag        ang55         isbigup     segdown20       segdown55
            df.loc[:,'comvalue']=np.where((((a[:,0]==2)|(a[:,0]==3)) & (a[:,1]==1)& ( a[:,2]==0) & (a[:,3]==0) &(a[:,4]==1) ),1,0)
        else:
            df.loc[:,'comvalue']=np.where(((a[:,0]==3) & ( a[:,2]==1) & (a[:,3]==1)  ),1,0)        
        return df 

    EXPFIELD=['date','posmacd','ang20flag','ang55flag','isbigup','segdown20','segdown55']
    
    #week number
    n=-6
    if datatype=='day': #day number
        n=-10
    
    df1=(getdf(sn,datatype)[EXPFIELD]
                .set_index('date')
                .loc[:begindate][n:]
                .assign(comvalue=0)
                .pipe(comp,datatype)
                )
    ldate=len(df1.index)
    _t1=df1['comvalue'].sum()/df1['comvalue'].count() 
    df2=(df1[0:ldate-1].drop('comvalue',axis=1)
                       .assign(comvalue=0)
                       .pipe(comp,datatype)
            )
    _t2=df2['comvalue'].sum()/df2['comvalue'].count()
    _up55=df1['segdown55'].sum()/df2['comvalue'].count() #total  up55
    _up55ang=df1['ang55flag'].sum()
    return df1 ,_t2>=.6 or _t1>=0.6,round(_t1,3),_up55,_up55ang

def seed(sn='ss123456',datatype='day',begindate='2017-6-23'):
    #get big segment trend
    def getBigSegMode(db,clstype):
        #get posmacdtail-posmacdhead-anghead
        _IdLastdown=db.max(axis=0)['bigdown']
        _IdLastup=db.max(axis=0)['bigup'] 
        if _IdLastdown>_IdLastup: 
            return "B{0}:do{1}-{2}".format(clstype[0].upper(),db.loc[_IdLastdown]['ang20flag'],(_IdLastdown-_IdLastup))
        else:
            return "B{0}:up{1}-{2}".format(clstype[0].upper(),db.loc[_IdLastup]['ang20flag'],(_IdLastup-_IdLastdown))

    #get  segment trend
    def getMacdMode(db,clstype):
        #get posmacdtail-posmacdhead-anghead
        _IdLastdown=db.max(axis=0)['segdown']
        _IdLastup=db.max(axis=0)['segup'] 
        _posmacdLastdown=db.loc[_IdLastdown]['posmacd']
        _posmacdLastup=db.loc[_IdLastup]['posmacd']
        if _IdLastdown>_IdLastup: 
            _bInbigup=db.loc[_IdLastup:_IdLastdown]['bigup'].sum()==0
            return "M{}{}{}-{}{}{}".format(clstype[0].upper(),_posmacdLastup,_posmacdLastdown,db.loc[_IdLastdown]['ang55flag'],db.loc[_IdLastdown]['ang55flag'],_bInbigup)
        else:
            _bInbigup=db.loc[_IdLastup:_IdLastdown]['bigup'].sum()==0
            return "M{}{}{}-{}{}{}".format(clstype[0].upper(),_posmacdLastdown,_posmacdLastup,db.loc[_IdLastup]['ang55flag'],db.loc[_IdLastup]['ang55flag'],_bInbigup)
    #get kdj segemnt trend
    def getKDseg(db,clstype):
        def IsInSeg1(startid,endid,db):
            if (endid-startid+1)==db.loc[startid:endid]['posmacd'].sum():
                return 'in'
            else:
                return 'out'#{}{}".format((endid-startid+1),db.loc[startid:endid]['posmacd']sum())

        def IsInBigUp(startid,endid,db):
            if 0==db.loc[startid:endid]['bigdown'].sum():
                return 'in'
            else:
                return 'out'#{}{}".format((endid-startid+1),db.loc[startid:endid]['posmacd']sum())

        _IdLastdown=db.max(axis=0)['kddown']
        _IdLastup=db.max(axis=0)['kdup'] 
        # id3--segPre ---id2 --segCur--id1
        curkdjmod='up'
        _id1,_id2,_id3=0,0,0
        if _IdLastdown>_IdLastup : #current is down so preseg is up then preseg is down
            _id1=_IdLastdown
            _id2=_IdLastup
            # kdj is down
            _id3=db.loc[(db.index<_id2)].max(axis=0)['kddown']
            if _id3==0:
                _id3=db[(db.index<_id2)&(db.kdup!=0)].min(axis=0)['kdup']             
                _id3=_id3-1
            curkdjmod='do'
        else: # lastupid>lastdownid
            _id1=_IdLastup
            _id2=_IdLastdown
            _id3=db[(db.index<_IdLastdown)].max(axis=0)['kdup']
            if _id3==0:
                _id3=db[(db.index<_IdLastdown)&(db.kddown!=0)].min(axis=0)['kddown'] 
                _id3=_id3-1      
        return "KD{0}[{1}-{2}]_{3}{0}[{3}pos1 {4}-{5}][{3}big {6}-{7}]".format(curkdjmod,int(_id2-_id3),int(_id1-_id2),clstype[0].upper(),IsInSeg1(_id3+1,_id2,db),IsInSeg1(_id2+1,_id1,db),IsInBigUp(_id3+1,_id2,db),IsInBigUp(_id2+1,_id1,db))        
    SEEDDBF=['date','posmacd','bigdown','bigup','segdown','segup','kddown','kdup','angflag','ang20flag','ang55flag','id']
    
    db=(getdf(sn,datatype)[SEEDDBF]
                    .set_index('date')
                    .loc[:begindate]
                    .set_index('id')
                    )

    if db is not None and len(db)>60:
        return "{},{}".format(getMacdMode(db,datatype),getKDseg(db,datatype))

    else:
        return None