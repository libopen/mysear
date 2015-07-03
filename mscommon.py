import pandas as pd
class gnGroup:
    def __init__(self,df):
        self.begindate=df.iloc[0,0]
        self.maType=df.iloc[0,1]
        self.zu=df.iloc[0,2]
        self.zd=df.iloc[0,3]
        self.pl=df.iloc[0,4]
        self.ph=df.iloc[0,5]
        self.macd=df.iloc[0,6]
    def  maType(self) :
        return self.maType
    def  maColor(self) :
         if self.maType>0:
            return 'R'
         else:
            return "G"
  
    def  zu(self) :
        return self.zu
        
    def  zd(self) :
        return self.zd
    def  pl(self) :
        return self.pl

    def  ph(self) :
        return self.ph

    def  macd(self) :
        return self.macd

class WMM :
    def __init__(self,df):
        self.begindate=df.iloc[0,0]
        self.op=df.iloc[0,2]
        self.hi=df.iloc[0,3]
        self.lo=df.iloc[0,4]
        self.la=df.iloc[0,5]
        self.vo=df.iloc[0,6]
        
    def  mType(self):
         if self.la>self.op:
            return 'R'
         else:
            return 'G'
    # big or small
    def  b_s(self):
         if self.la>self.op and self.la/self.op>1.3:
            return 'b1'
         elif self.la>self.op and self.la/self.op<=1.3:
            return 'b2'
         elif self.la<self.op and self.op/self.la>=1.3:
            return 's1'
         else:
            return 's2'

    def  op(self) :
        return self.op
  
    def  hi(self) :
        return self.hi
        
    def  lo(self) :
        return self.lo
    def  la(self) :
        return self.la

    def  vo(self) :
        return self.vo



