import pandas as pd
import sys,os
import numpy as np
from time import ctime,sleep
import time
import datetime
import csv
from datetime import timedelta

#goodkey hope to slove 
#1 the minl always lower startc
#2 the maxh is not the starth
#3 the minlc is the lastc
#4 the minl is provious show at maxh
ROOTPATH='/home/lib/mypython/export/'


   
class ANALYSIS:
      def __init__(self,rootpath):
            self.rootpath=rootpath

      def __init__(self):
            self.rootpath=ROOTPATH
      
      def getallfile(self,pat):
            
            resultlist=[]
            for lists in os.listdir(self.rootpath):
                  path=os.path.join(self.rootpath,lists)
                  if os.path.isdir(path):
                        pass
                  else:
                        # only get lines >60 
                        if os.path.basename(path)[0:len(pat)]==pat and os.stat(path).st_size>4000 :#and os.path.basename(path)[0:8]=='SH600576':
                        #if os.path.basename(path)[0:5]=='SH600' and os.stat(path).st_size!=0: 
                              resultlist.append(path[-12:-4])
            ret=resultlist.sort()
            return resultlist
            
      
      
       
 
      

