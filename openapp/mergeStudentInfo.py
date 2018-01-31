# -*- coding: utf-8 -*-
import os
import sys
from os.path import basename
import datetime
from sqlalchemy import create_engine
import json
import csv
import time
import shutil
import hashlib
import logging
import logging.handlers;

            

def getfiles(wr):
    def getphotoinfo(filename):
        # get student information from the stufile.txt (this is export by db)
        #查询带有中文编码，要先解码，再编码为中文作为查询条件:
        dict={}
        reader=csv.DictReader(open(filename,'r',encoding='gb2312'))
        for line in reader:
            
            dict[line['STUDENTCODE']]=line
        return dict
    
            
         #begin 
    dict=getphotoinfo('xh.txt')
    reader = csv.reader(open('xhexcel.csv','r',encoding='gb18030'))
    i,j=0,0
    for row in reader:
        i=i+1
        if row[3] in dict:
           j=j+1
           csvlist=row
           csvlist.append(dict[row[3]]['ENROLLMENTSTATUS'])
           csvlist.append(dict[row[3]]['SEGMENTCODE'])
        else:
           csvlist=row
           csvlist.append('')
        wr.writerow(csvlist)

    print('%s,%s'%(i,j))
         


def main():
    global targetPathRoot

    #print(targetPath)
      
    try:       
       with open('expxh.csv','w',newline='',encoding='gb18030') as csvfile:
       #with open('imp.csv','w') as csvfile:
             wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
             getfiles(wr)
    finally:
       csvfile.close()


#-------------
os.environ['NLS_LANG'] = 'AMERICAN_AMERICA.ZHS16GBK'
a= datetime.datetime.now()
engine = create_engine('oracle://ouchnsys:Jw2015@202.205.161.135:1521/orcl1')
targetPathRoot=os.path.dirname(os.path.realpath(__file__))
LOG_FILE=os.path.join(targetPathRoot,'impPhoto.log')
handler=logging.handlers.RotatingFileHandler(LOG_FILE,maxBytes=1023*1024,backupCount=5)
fmt='%(asctime)s - %(filename)s:%(lineno)s - %(name)s - %(message)s'
formatter=logging.Formatter(fmt)
handler.setFormatter(formatter)
logger=logging.getLogger('imp')
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)
if __name__=='__main__' :
     main()
