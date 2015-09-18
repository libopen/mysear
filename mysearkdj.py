import pandas as pd
import math
import mscommon
from datetime import timedelta,date
from datetime import datetime
import kdj_d
import kdj_w
import make_w

class dbSource:
    

    def __init__(self,dbPath):
        self.dbPath=dbPath
        filePath=self.dbPath+'mygdw.csv'
        self.dbw=pd.read_csv(filePath,parse_dates=['cdate'])
        self.dbw.set_index('ti')
        self.Allti=pd.read_csv(self.dbPath+'Allti.csv',header=None)
        self.Allti.set_index(0)

        


    
    def wholeSeard(self):
        sear_all=pd.DataFrame()
        cls_kdjd=kdj_d.dbSource(self.dbPath,'mygd.csv')
        cls_kdjd.makedb()
        for t in cls_kdjd.getAllti():
            retdf=cls_kdjd.get_kdj(t)
            if retdf.empty:
               continue
            sear_all=sear_all.append(retdf,ignore_index=True)
        sear_all=sear_all[(sear_all[1]>(datetime.now()-timedelta(days=20))) & (sear_all['gd']=='gold') & (sear_all['K']<20) & (sear_all['J']<20)][[0,1,2,'K','D','gd']]
        filePath=self.dbPath+'k_d.csv'
        sear_all.to_csv(filePath,index=False)
        return sear_all
                      

    def wholeSearw(self):
        sear_all=pd.DataFrame()
        cls_kdjw=kdj_w.dbSource(self.dbPath,'mygd.csv')
        cls_kdjw.imp_dbw()
        cls_kdjw.makedb()
        for t in cls_kdjw.getAllti():
            retdf=cls_kdjw.get_wkdj(t)
            if retdf.empty:
               continue
            sear_all=sear_all.append(retdf,ignore_index=True)
        sear_all=sear_all[(sear_all['cdate']>(datetime.now()-timedelta(days=20))) & (sear_all['gd']=='gold') & (sear_all['K']<20) & (sear_all['J']<20)][['ti','cdate','la','K','D','gd']]
        filePath=self.dbPath+'k_w.csv'
        sear_all.to_csv(filePath,index=False)
        return sear_all
    
  
    def wholeSearMacdW(self):
        sear_all=pd.DataFrame()
        cls_macdw=make_w.dbSource(self.dbPath,'mygd.csv')
        cls_macdw.makedb()       
        cls_macdw.imp_dbw()
        sear_all=cls_macdw.exp_wmacdCross()       
        sear_all=sear_all[sear_all['cdate']>(datetime.now()-timedelta(days=20))][['ti','cdate','la']]
        filePath=self.dbPath+'k_mw.csv'
        sear_all.to_csv(filePath,index=False)
        return sear_all

    def filterKdj(self):
        sear_all=pd.DataFrame()
        cls_kdjd=kdj_d.dbSource(self.dbPath,'mygd.csv')
        cls_kdjd.makedb()
        for t in cls_kdjd.getAllti():
            retdf=cls_kdjd.get_kdjlist(t)
            if retdf.empty:
               continue
            sear_all=sear_all.append(retdf,ignore_index=True)
        return sear_all
                      
          
def Main():
    p=dbSource('/home/user/programe/')
    p.wholeSeard()
    p.wholeSearw()
    p.wholeSearMacdW()
    #df[df[1]>(datetime.now()-timedelta(days=20))]
    


Main()
