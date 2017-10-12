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

def getsignupinfo(segmentcode):
    ts = time.time()
    try:       
       with open('eas_exmm_sign'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = 'select 1 as sn ,a.exambatchcode,a.examplancode,a.examcategorycode,a.assessmode,examsitecode,newpapercode(a.exampapercode),a.courseid,a.segmentcode,a.collegecode,a.learningcentercode,a.classcode,a.studentcode,a.examunit,a.applicant,a.feecertificate,a.applicatdate,a.isconfirm,a.coursename  from eas_exmm_signup a  where a.segmentcode=:segmentcode'
            result =engine.execute(sql,segmentcode=segmentcode)
            for row in result:
                wr.writerow((row[0],row[1],row[2],row[3],row[4],row[5],row[6],row[7],row[8],row[10],row[11],row[12],row[13],row[14],row[15],row[16],row[17],row[18]))
             
    finally:
        csvfile.close()
    print('signup %r: took  %s seconds  '%(segmentcode,time.time()-ts))       

def getelcinfo(segmentcode):
    ts = time.time()
    try:       
       with open('elc_elc'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = 'select 1 sn,A.BATCHCODE ,A.STUDENTCODE ,A.COURSEID ,A.LEARNINGCENTERCODE ,A.CLASSCODE ,A.ISPLAN ,A.OPERATOR ,A.ELCSTATE ,A.OPERATETIME ,A.CONFIRMOPERATOR ,A.CONFIRMSTATE ,A.CONFIRMTIME ,A.CURRENTSELECTNUMBER ,A.ISAPPLYEXAM ,A.ELCTYPE ,A.STUDENTID ,A.REFID ,A.SPYCODE  from eas_elc_studentelcinfo a  where a.learningcentercode like :learningcentercode'
            result =engine.execute(sql,learningcentercode=segmentcode+'%')
            for row in result:
                wr.writerow((row[0],row[1],row[2],row[3],row[4],row[5],row[6],row[7],row[8],row[10],row[11],row[12],row[13],row[14],row[15],row[16],row[17],row[18]))
             
    finally:
        csvfile.close()
    print('elc %r: took  %s seconds  '%(segmentcode,time.time()-ts))       


def getfiles(rootDir,wr):
                     
                      try:
                          #print(type(path))
                          #print(chardet.detect(path)['encoding'])
                          filepath = path.encode('utf-8','surrogateescape').decode('gb2312')
                          #filepath=path    
                                       
                          #print(chardet.detect(os.path.splitext(basename(filepath))[0]))
                          #正常情况下打印结果，会看到unicode编码而看不到中文
                          #print("%r %s" %(path,os.path.splitext(basename(filepath))[0].encode('utf-8','surrogateescape').decode('gb2312')))
                          #如果要看中文输出要先解码码再编码
                          #print(filepath.encode('utf-8','surrogateescape').decode('gb2312'))
                          filename = basename(filepath)
                          idnumber = os.path.splitext(basename(filepath))[0]
                          filesize = os.stat(path).st_size
                          photolist = getphotoinfo(''.join(idnumber))
                          if not photolist:
                              #同样存储中unicode要存储为中文编码也要先解码再编码
                              wr.writerow((''.join(filename),'','','','imp',idnumber))
                          else :
                              for photo in photolist:
                                  try:
                                     targetPath = os.path.join(targetPathRoot,photo['filepath'])
                                     print(targetPath)
                                     if not os.path.exists(targetPath):
                                        os.makedirs(targetPath)
                                     shutil.copy(path,os.path.join(targetPath,basename(path)))
                                     dst_file = os.path.join(targetPath,basename(path))
                                     new_dst_file = os.path.join(targetPath,photo['newphotoname'])
                                     os.rename(dst_file,new_dst_file)
                                     #print('%s:%s'%(idnumber,getphotoinfo(''.join(idnumber))))  
                                     wr.writerow((photo['newphotoname'],photo['studentid'],photo['filepath'],filesize,'imp',idnumber))
                                  except:
                                      print('except')
                                  finally:
                                      #print('finally')
                                       pass
                      except:
                             fd = os.open(path,os.O_RDWR|os.O_CREAT)
                             info = os.fstat(fd)
                             print(info.st_ino)  
                             logger.debug('file index number:%s'%(info.st_ino,))
         


def main():
    segments=['901','902','903','904','905','906','907']
    for segcode in segments:
        getsignupinfo(segcode)
        getelcinfo(segcode)


#-------------
os.environ['NLS_LANG'] = 'AMERICAN_AMERICA.ZHS16GBK'
a= datetime.datetime.now()
engine = create_engine('oracle://ouchnsys:Jw2015@202.205.161.137:1521/orcl1')
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
