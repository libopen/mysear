import pandas as pd
import math
from datetime import timedelta,date


class dbSource:
    
    def __init__(self,dbPath,dbName):
        self.dbPath=dbPath
        self.dbName=dbName

    # construction database
    def makedb(self):
        filePath = self.dbPath+self.dbName
        self.db=pd.read_csv(filePath,header=None,parse_dates=[1])
        self.Allti=self.db.loc[:,0].drop_duplicates()
        self.db.set_index(0)

    def getAllti(self):
        return self.Allti

    def get_kdj(self,ti):
        db=self.db
        df=db[db[0]==ti].copy()
        df.set_index(1)
        
        #comput kdj
        low_list=pd.rolling_min(df[4],9)
        low_list.fillna(value=pd.expanding_min(df[4]),inplace=True)
        high_list=pd.rolling_max(df[3],9)
        high_list.fillna(value=pd.expanding_max(df[3]),inplace=True)
        rsv=(df[5]-low_list)/(high_list-low_list)*100
        df['K']=pd.ewma(rsv,com=2)
        df['D']=pd.ewma(df['K'],com=2)
        df['J']=3*df['K']-2*df['D']
        df['gd']=''
        kdj_position=df['K']>df['D']
        df.loc[kdj_position[(kdj_position == True) & (kdj_position.shift() == False)].index,'gd']='gold'
        df.loc[kdj_position[(kdj_position == False) & (kdj_position.shift() == True)].index,'gd']='die'
        dfret=df.tail(2)
        return dfret[dfret['gd']=='gold']     
        
