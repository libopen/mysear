# -*- coding: utf-8 -*-
import os
import sys
from os.path import basename
import datetime
from sqlalchemy import create_engine
import json
import csv
import shutil
import logging
import logging.handlers

def bad_filename(filename):
    return repr(filename)[1:-1]

def getphotoinfo(filename):
    
    photoinfo=[]
    sql = 'select a.studentid,a.batchcode,a.professionallevel,a.studenttype from eas_schroll_student a inner join eas_schroll_studentbasicinfo b on a.studentid=b.studentid where b.idnumber=:idnumber'
    try:
       result =engine.execute(sql,idnumber=filename.encode('utf-8','surrogateescape').decode('gbk'))
       for row in result:
           filepath='%s/%s/%s'%(row[3],row[2],row[1])
           #print(filepath)
           info = dict()
           info['studentid']=row[0]
           info['filepath'] = filepath
           info['idnumber'] = filename
           photoinfo.append(info)
           
    except :
           logger.debug(bad_filename(filename));
    return photoinfo
            

def getfiles(sourceDir):
    i=0
    try:
       with open('imp.csv','w',newline='',encoding='utf-8') as csvfile:
               wr = csv.writer(csvfile,quoting=csv.QUOTE_ALL)
               targetDirRoot = '/home/libin/Files/RecruitPIC/'
               recordPath = 'Files/RecruitPIC/'
               for lists in os.listdir(sourceDir):
                   path = os.path.join(sourceDir,lists)
                   if os.path.isdir(path):
                      getfiles(path)
                      #pass
                   else:
                      print("%r %s" %(path,os.path.splitext(basename(path))[0].encode('utf-8','surrogateescape').decode('gb2312')))
                      i=i+1
                      filepath = path
                      filename=basename(filepath)
                      idnumber = os.path.splitext(basename(filepath))[0]
                      filesize = os.stat(path).st_size
                      photolist=getphotoinfo(''.join(idnumber))
                      csv_filename = filename.encode('utf-8','surrogateescape').decode('gb2312')
                      csv_idnumber = idnumber.encode('utf-8','surrogateescape').decode('gb2312')
                      if not photolist: #not get result
                         #filename,idnumber,studentid,storepath,size
                         wr.writerow((csv_filename,csv_idnumber,'','',''))
                         #print( 'dic[%s]=%s'%(k,v))
                      else :
                         # if path is not exist then mkdir 
                         for photo in photolist:
                             targetPath ='%s%s'%(targetDirRoot,photo['filepath'])
                             #print(targetPath)
                             if not os.path.exists(targetPath) :
                                    os.makedirs(targetPath)
                             
                             #shutil.move(path,'%s/%s'%(targetPath,basename(path)))
                             shutil.copy(path,'%s/%s'%(targetPath,basename(path)))
                             wr.writerow((csv_filename,csv_idnumber,photo['studentid'],recordPath+photo['filepath'],filesize))       
    finally:
            csvfile.close()
    print(i)
           


def main():
    dir = input('enter the path:')
    getfiles(dir)
    #print ('%s'%(getphotoinfo(dir)))
    #dic = json.loads('{%s}'%(getphotoinfo(dir),))
    #for (k,v) in dic.items():
        #print( 'dic[%s]=%s'%(k,v))


#-------------
LOG_FILE = '/home/libin/impPhoto.log'
handler = logging.handlers.RotatingFileHandler(LOG_FILE,maxBytes=1024*1024,backupCount=5)
fmt = '%(asctime)s - %(filename)s:%(lineno)s - %(name)s - %(message)s'
formatter = logging.Formatter(fmt)
handler.setFormatter(formatter)
logger = logging.getLogger('imp')
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)
a= datetime.datetime.now()
engine = create_engine('oracle://ouchnsys:Jw2015@202.205.161.135:1521/orcl1')


if __name__=='__main__' :
     main()
