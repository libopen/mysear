import pandas as pd
import math
import mscommon
from datetime import timedelta,date


class dbSource:
    

    def __init__(self,dbPath):
        self.dbPath=dbPath
        self.Allti=pd.read_csv(self.dbPath+'Allti.csv',header=None)
        filePath=self.dbPath+'gngroup_d.csv'
        self.gndb=pd.read_csv(filePath,parse_dates=['begindate'])
        self.gndb.set_index('ti')
        filePath=self.dbPath+'gngroup_w.csv'
        self.wgndb=pd.read_csv(filePath,parse_dates=['begindate'])
        self.wgndb.set_index('ti')
        filePath=self.dbPath+'mygdw.csv'
        self.dbw=pd.read_csv(filePath,parse_dates=['cdate'])
        self.dbw.set_index('ti')
        filePath=self.dbPath+'mygdm.csv'
        self.dbm=pd.read_csv(filePath,parse_dates=['cdate'])
        self.dbm.set_index('ti')

        
    #gnType                     
    def getGnlist(self,retdf):
       gnlist=[]
       for i in range(len(retdf)):
             gnlist.append(mscommon.gnGroup(retdf[i:i+1]))
       return gnlist

    def getWMMlist(self,retdf):
       gnlist=[]
       for i in range(len(retdf)):
             gnlist.append(mscommon.WMM(retdf[i:i+1]))
       return gnlist

    # gnType 1 gngroup 2 wgngroup
    def get_gngroup(self,ti,gnType=1):
        if gnType==1:      
           df=self.gndb[self.gndb['ti']==ti]
        else:
           df=self.wgndb[self.wgndb['ti']==ti]
        return df


        
    
    #  analysis every one state 
    #  1:current segment r or g and length 
    def collectInfo(self,ti):
        retdf=self.get_gngroup(ti)
        curpl=self.get_macd(ti).tail(1).iloc[0,5]
        if len(retdf)>5 :
            gnlist=self.getGnlist(retdf.tail(5)) 
            #current state
            cur=gnlist[4] 
            cur_1=gnlist[3]
            cur_2=gnlist[2]
            cur_3=gnlist[1]
            if cur.zu>0 and cur.zu>cur.zd :
                  tz='BM'
            elif cur.zu>0 and cur.zu<cur.zd:
                  tz='BL'
            else :
                  tz='S'
            ppos='{:.3f}-{:.3f}'.format((cur.ph-curpl)/cur.ph,curpl/cur.pl)
           
            p_1=cur.ph/cur_1.pl
            p_2=cur_2.ph/cur_3.pl 
            if cur.maType>0 :
               if cur.ph>cur_2.ph and cur.pl>cur_2.pl:
                  t_state='RU'
               elif cur.ph<cur_2.ph and cur.pl<cur_2.pl :
                  t_state='RD'
               else:
                  t_state='RM'
            else:
                if cur.pl<cur_2.pl and cur.ph<cur_2.ph:
                   t_state='GD'
                else:
                   t_state='GM'
                             
            return {'ti':ti,'state':t_state+tz,'per1':p_1,'per2':p_2,'ppos':ppos}
        else :
            return{}   
    
    def wholeSear(self):
        row_list=[]
        for t in self.Allti:
            ret=self.collectInfo(t)
            if len(ret)>0:
               row_list.append(ret)
        df=pd.DataFrame(row_list)
        return df
                      

    # top type and bottGom type 
    #from week month judge is bottom or top type by vo and rate and direct  
    def tbType(self ,wm1,wm2,wm3,wm4):
        # top or bottom order : wm4,wm3 wm2 wm1
        if wm4.hi>wm1.la and wm4.hi>wm3.hi: #only support wm4.high > wm1.la
           level=wm1.mType()+wm1.b_s()+wm2.mType()+wm3.mType()#'Rb1GG'
           if level=='Rb1GG' and (wm1.la<=wm2.hi) and (wm3.la>wm2.la): 
               isBot='B1'           
           elif level=='Rb1GG' and  (wm1.la<wm3.hi) and (wm3.lo>wm2.lo) and (wm3.hi>wm2.hi):
               isBot='B2'
           elif  level=='Rb1GG' and (wm3.lo>wm2.lo) and (wm3.hi>wm2.hi) and (wm1.vo>wm2.vo):
               isBot='B3'        
           else:
               isBot='N'
        else:
              isBot='N'
        return isBot

    def get_dfw(self,ti):
        return self.dbw[self.dbw['ti']==ti]
    def find_wb(self,ti):
         blist=[]
         dfw=self.dbw[self.dbw['ti']==ti]
         for i in range(len(dfw)):
             if (i+4)<=len(dfw):
                if i==0:
                   df=dfw.tail(4)
                else:
                   df=dfw[-4-i:-i]
             if len(df)==4:
                wlist=self.getWMMlist(df)
                sret=self.tbType(wlist[3],wlist[2],wlist[1],wlist[0])
                blist.append(wlist[3].begindate.strftime('%y%m%d')+'-'+sret)
         return blist 
        
           
    def find_mb(self,ti):
         blist=[]
         dfm=self.dbm[self.dbm['ti']==ti]
         for i in range(len(dfm)):
             if (i+4)<=len(dfm):
                if i==0:
                   df=dfm.tail(4)
                else:
                   df=dfm[-4-i:-i]
             if len(df)==4:
                wlist=self.getWMMlist(df)
                sret=self.tbType(wlist[3],wlist[2],wlist[1],wlist[0])
                #if self.tbType(wlist[3],wlist[2],wlist[1],wlist[0])=='B1':
                blist.append(wlist[3].begindate.strftime('%y%m%d')+'-'+sret)
         return blist 

    def estimate(self,ti,start=0):
        try:
           if start==0:
              dfw=self.dbw[self.dbw['ti']==ti].tail(4)
              dfm=self.dbm[self.dbm['ti']==ti].tail(4)
           else:
              dfw=self.dbw[self.dbw['ti']==ti][-4-start:-start]
              dfm=self.dbm[self.dbm['ti']==ti][-4-start:-start]
           gndf=self.get_gngroup(ti,1).tail(2)
           wgndf=self.get_gngroup(ti,2).tail(2)
           if len(dfw)==4 and len(dfm)==4:
              wlist=self.getWMMlist(dfw)
              iswb=self.tbType(wlist[3],wlist[2],wlist[1],wlist[0])
              mlist=self.getWMMlist(dfm)
              ismb=self.tbType(wlist[3],mlist[2],mlist[1],mlist[0])
              wgnlist=self.getGnlist(wgndf)
              wColor=wgnlist[1].maColor()
              return {'ti':ti,'w':iswb+wColor,'m':ismb}
           else:
              return ''
        except:
              return ''  
    def Sear_WM(self,start=0):
        row_list=[]
        for row in self.Allti.iterrows():
            ret=self.estimate(int(row[1]),start)
            if len(ret)>0:
               row_list.append(ret)
        df=pd.DataFrame(row_list)
        return df
   
def Main():
    p=dbSource('/home/user/programe/')
    #p.makedb()
    #p.Sear_WM()
    #pass 
    #p.find_b(600643)
    #p.estimate(960) 

Main()
