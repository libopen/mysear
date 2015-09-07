import pandas as pd
import math
import mscommon
from datetime import timedelta,date
import kdj_d
import kdj_w


class dbSource:
    

    def __init__(self,dbPath):
        self.dbPath=dbPath
        filePath=self.dbPath+'mygdw.csv'
        self.dbw=pd.read_csv(filePath,parse_dates=['cdate'])
        self.dbw.set_index('ti')

        


    
    def wholeSeard(self):
        sear_all=pd.DataFrame()
        cls_kdjd=kdj_d.dbSource(self.dbPath,'mygd.csv')
        cls_kdjd.makedb()
        for t in cls_kdjd.getAllti():
            retdf=cls_kdjd.get_kdj(t)
            if retdf.empty:
               continue
            sear_all=sear_all.append(retdf,ignore_index=True)
        return sear_all
                      

    def wholeSearw(self):
        sear_all=pd.DataFrame()
        cls_kdjw=kdj_w.dbSource(self.dbPath,'mygd.csv')
        cls_kdjw.makedb()
        cls_kdjw.imp_dbw()
        Allti = cls_kdjw.getAllti()
        for t in Allti:
            retdf=cls_kdjw.get_wkdj(t)
            if retdf.empty:
               continue
            sear_all=sear_all.append(retdf,ignore_index=True)
        return sear_all      
   
def Main():
    p=dbSource('/home/user/programe/')
    p.wholeSearw()


Main()
