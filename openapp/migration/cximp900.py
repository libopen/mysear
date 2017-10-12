# -*- coding: utf-8 -*-
import os
import sys
import datetime
import csv
import time
import cx_Oracle

def getsignupinfo(segmentcode):
    ts = time.time()
    try:       
       with open('eas_exmm_sign'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = 'select 1 as sn ,a.exambatchcode,a.examplancode,a.examcategorycode,a.assessmode,examsitecode,newpapercode(a.exampapercode),a.courseid,a.segmentcode,a.collegecode,a.learningcentercode,a.classcode,a.studentcode,a.examunit,a.applicant,a.feecertificate,a.applicatdate,a.isconfirm,a.coursename  from eas_exmm_signup a  where a.segmentcode=:segmentcode'
            con = cx_Oracle.connect(connstr)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'segmentcode':segmentcode})
            
            
            for row in cur:
                wr.writerow((row[0],row[1],row[2],row[3],row[4],row[5],row[6],row[7],row[8],row[10],row[11],row[12],row[13],row[14],row[15],row[16],row[17],row[18]))
            cur.close()
            con.close()    
    finally:
        csvfile.close()
        #cur.close()
        #con.close()
    print('signup %r: took  %s seconds  '%(segmentcode,time.time()-ts))       

def getelcinfo(segmentcode):
    ts = time.time()
    try:       
       with open('elc_elc'+segmentcode+'.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE)
            sql = 'select 1 sn,A.BATCHCODE ,A.STUDENTCODE ,A.COURSEID ,A.LEARNINGCENTERCODE ,A.CLASSCODE ,A.ISPLAN ,A.OPERATOR ,A.ELCSTATE ,A.OPERATETIME ,A.CONFIRMOPERATOR ,A.CONFIRMSTATE ,A.CONFIRMTIME ,A.CURRENTSELECTNUMBER ,A.ISAPPLYEXAM ,A.ELCTYPE ,A.STUDENTID ,A.REFID ,A.SPYCODE  from eas_elc_studentelcinfo a  where a.learningcentercode like :learningcentercode'
            con = cx_Oracle.connect(connstr)
            cur = con.cursor()
            cur.prepare(sql)
            cur.execute(None,{'learningcentercode':segmentcode+'%'})
            for row in cur:
                wr.writerow((row[0],row[1],row[2],row[3],row[4],row[5],row[6],row[7],row[8],row[10],row[11],row[12],row[13],row[14],row[15],row[16],row[17],row[18]))
            cur.close()
            con.close()
    finally:
        csvfile.close()
    print('elc %r: took  %s seconds  '%(segmentcode,time.time()-ts))       


         


def main():
    global connstr
    connstr = 'ouchnsys/Jw2015@10.100.134.179:1521/orcl'
    segments=['901','902','903','904','905','906','907']
    for segcode in segments:
        getsignupinfo(segcode)
        getelcinfo(segcode)


#-------------
os.environ['NLS_LANG'] = 'AMERICAN_AMERICA.ZHS16GBK'
if __name__=='__main__' :
     main()
