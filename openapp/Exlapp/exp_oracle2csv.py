# -*- coding: utf-8 -*-
import os
import sys
import datetime
import csv
import time
import cx_Oracle
import ipdb
from table2Excel import write_cursor_to_excel
import redis
from xlwt import Workbook,XFStyle,Borders,Font
def get100wv1():
    ts = time.time()
    try:       
       with open('data100.csv','w',newline='',encoding='utf-8' ) as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE, quotechar='',escapechar='\\')
            sql = "select * from eas_exmm_netexamscore"
            con = cx_Oracle.connect(connstr)
            #ipdb.set_trace()
            cur = con.cursor()
            
            cur.execute(sql)
            #cur.prepare(sql)
            #cur.execute(None,{'learningcentercode':segmentcode+'%'})
            for row in cur:
                #print(row[0])
                wr.writerow(row)
            cur.close()
            con.close()
    except UnicodeDecodeError as err:
           print(err)
    finally:
        csvfile.close()
    print('  took  %s seconds  '%(time.time()-ts,))       


         
def exp2csvnormal():
    ts = time.time()
    try:
       with open('expcsv.csv','w',newline='',encoding='utf-8') as csvfile:
            wr = csv.writer(csvfile,quoting=csv.QUOTE_NONE,quotechar='',escapechar='\\')
            sql="with t1 as (select 905 as segmentcode,learningcentercode,tcpcode,studentcode \
                  from eas_schroll_student where learningcentercode like :segmentcode)\
                 ,t2 as (select t1.learningcentercode,a.tcpcode,a.courseid,a.coursenature,a.examunittype\
                 ,A.OPENEDSEMESTER SEMESTER from eas_tcp_modulecourses a \
                 inner join t1 on A.TCPCODE =t1.tcpcode where a.coursenature='1')\
                 ,t3 as (select t1.learningcentercode, a.tcpcode,a.courseid,a.coursenature,a.examunittype\
                 ,b.OPENEDSEMESTER SEMESTER from eas_tcp_implmodulecourse a inner join t1 \
                 on A.TCPCODE =t1.tcpcode and a.segmentcode=t1.segmentcode \
                 inner join eas_tcp_modulecourses b on a.tcpcode=b.tcpcode and a.courseid=b.courseid \
                 where a.coursenature='2') \
                 ,t4 as (select t1.learningcentercode, a.tcpcode,a.courseid,a.coursenature,a.examunittype \
                  ,A.SuggestOpenSemester SEMESTER from eas_tcp_execmodulecourse a inner join t1 on \
                  A.TCPCODE =t1.tcpcode and a.learningcentercode=t1.learningcentercode ) \
                  ,t5 as (select * from t2 union select * from t3 union select * from t4) \
                 select a.batchcode,b.organizationname,c.classname,a.studentcode \
                 ,d.fullname,D.BATCHCODE,e.spyname,a.courseid ,f.coursename ,case when t5.coursenature ='1'                 or t5.coursenature='2' then '必修' else '选修' end \
                 ,case when t5.examunittype='1' then '总部' else '分部' end ,t5.SEMESTER,A.CONFIRMTIME \
                   ,A.CONFIRMOPERATOR ,A.CONFIRMSTATE \
                 from eas_elc_studentelcinfo905 a \
                 left join eas_org_basicinfo b on a.learningcentercode=b.organizationcode \
                 left join eas_org_classinfo c on a.classcode=c.classcode \
                 left join eas_schroll_student d on a.studentcode=d.studentcode \
                 left join eas_spy_basicinfo e on D.SPYCODE =e.spycode \
                 left join eas_course_basicinfo f on a.courseid=f.courseid \
                  left join t5 on t5.learningcentercode=d.learningcentercode and t5.tcpcode=d.tcpcode  \
                  and f.courseid=t5.courseid"      
            con=cx_Oracle.connect(connstr)
            cur=con.cursor()
            #ipdb.set_trace()
            cur.execute(sql,segmentcode='905%')
            #for row in cur:
               # wr.writerow(row)
            wr.writerows(cur.fetchall())
            cur.close()
            con.close()
    finally:
           csvfile.close()
    print(' took %s seconds'%(time.time()-ts,))

def exp2xls_xlwt():
    ts = time.time()
    try:
            sql="with t1 as (select 905 as segmentcode,learningcentercode,tcpcode,studentcode \
                  from eas_schroll_student where learningcentercode like :segmentcode)\
                 ,t2 as (select t1.learningcentercode,a.tcpcode,a.courseid,a.coursenature,a.examunittype\
                 ,A.OPENEDSEMESTER SEMESTER from eas_tcp_modulecourses a \
                 inner join t1 on A.TCPCODE =t1.tcpcode where a.coursenature='1')\
                 ,t3 as (select t1.learningcentercode, a.tcpcode,a.courseid,a.coursenature,a.examunittype\
                 ,b.OPENEDSEMESTER SEMESTER from eas_tcp_implmodulecourse a inner join t1 \
                 on A.TCPCODE =t1.tcpcode and a.segmentcode=t1.segmentcode \
                 inner join eas_tcp_modulecourses b on a.tcpcode=b.tcpcode and a.courseid=b.courseid \
                 where a.coursenature='2') \
                 ,t4 as (select t1.learningcentercode, a.tcpcode,a.courseid,a.coursenature,a.examunittype \
                  ,A.SuggestOpenSemester SEMESTER from eas_tcp_execmodulecourse a inner join t1 on \
                  A.TCPCODE =t1.tcpcode and a.learningcentercode=t1.learningcentercode ) \
                  ,t5 as (select * from t2 union select * from t3 union select * from t4) \
                 select a.batchcode,b.organizationname,c.classname,a.studentcode \
                 ,d.fullname,D.BATCHCODE,e.spyname,a.courseid ,f.coursename ,case when t5.coursenature ='1'                 or t5.coursenature='2' then '必修' else '选修' end \
                 ,case when t5.examunittype='1' then '总部' else '分部' end ,t5.SEMESTER,A.CONFIRMTIME \
                   ,A.CONFIRMOPERATOR ,A.CONFIRMSTATE \
                 from eas_elc_studentelcinfo905 a \
                 left join eas_org_basicinfo b on a.learningcentercode=b.organizationcode \
                 left join eas_org_classinfo c on a.classcode=c.classcode \
                 left join eas_schroll_student d on a.studentcode=d.studentcode \
                 left join eas_spy_basicinfo e on D.SPYCODE =e.spycode \
                 left join eas_course_basicinfo f on a.courseid=f.courseid \
                  left join t5 on t5.learningcentercode=d.learningcentercode and t5.tcpcode=d.tcpcode  \
                  and f.courseid=t5.courseid"      
            con=cx_Oracle.connect(connstr)
            cur=con.cursor()
            #ipdb.set_trace()
            cur.execute(sql,segmentcode='905%')
            write_cursor_to_excel(cur,'expxls1.xls','score')
            cur.close()
            con.close()
    finally:
          print(' took %s seconds'%(time.time()-ts,))


def getdicvalue(fieldname,key):
   
   #the fieldname from cx_Oracle is UPPER case key is string to bytes
    bkey = bytes(key,encoding='utf8')
    sw ={
        'LEARNINGCENTERCODE':lambda :str(orglist[bkey],encoding='utf-8'),
        'SPYCODE'           :lambda :str(spylist[bkey],encoding='utf-8'),
        'COURSENAME'        :lambda :str(courselist[bkey],encoding='utf-8'),
    }
    return sw.get(fieldname,lambda:'nothing')()


def exp2xls_redis(filename,sheetTitle):
    colnames={'BATCHCODE':'批次代码',
              'LEARNINGCENTERCODE':'学习中心',
              'CLASSCODE':'班级',
              'SPYCODE':'专业',
              'STUDENTCODE':'学号',
              'COURSEID':'课程ID',
              'COURSENAME':'课程名称',
             }
    ts = time.time()
    # get result from db
    sql = "select batchcode,learningcentercode,classcode,spycode,studentcode,courseid,courseid as coursename from eas_elc_studentelcinfo902"
    con = cx_Oracle.connect(connstr)
    cur = con.cursor()
    cur.execute(sql)
    # write xls
    # create style for header row -- bold font,thin border below
    fnt = Font()
    fnt.bold = True
    borders = Borders()
    borders.bottom = Borders.THIN
    hdrstyle = XFStyle()
    hdrstyle.font = fnt
    #create a date format style for any date columns 
    datestyle = XFStyle()
    datestyle.num_format_stt='YYYY-MM-DD'
    #create the workbook 
    wb = Workbook(style_compression=2)
    # the workbook will have just one sheet
    sh = wb.add_sheet(sheetTitle)
    #write the header line, based on the cursor descipton
    c = 0 
    colWidth = []
    for col in cur.description:
        #col[0] is the column name
        #col[1] is the column data type
        sh.write(0,c,colnames[col[0]],hdrstyle)
        colWidth.append(1) # arbitrary min cell width
        if col[1] == cx_Oracle.DATETIME:
           colWidth[-1] = len(datestyle.num_format_str)
        if colWidth[-1] < len(col[0]):
           colWidth[-1] = len(col[0])
        c +=1
    #write data one to each row
    r = 1
    
    for row in cur:
        xlsrow = sh.row(r)
        for i in range(len(row)):
            #ipdb.set_trace()
            if row[i]:
               # join other tables by redis
               curvalue = row[i]
               # redis keys is bytes so the data form db will do convert to bytes
               curcell = getdicvalue(cur.description[i][0],row[i])
               if curcell!='nothing':
                  curvalue = curcell
                
                  
               
               if cur.description[i][1] == cx_Oracle.DATETIME:
                  xlsrow.write(i,curvalue,datestyle)
               else :
                  if colWidth[i] < len(str(curvalue)):
                     colWidth[i] = len(str(curvalue))
                  xlsrow.write(i,curvalue)
        r +=1

    for j in range(len(colWidth)):
        sh.col(j).width = colWidth[j] * 350
    #freeze the header row
    sh.panes_frozen = True
    sh.vert_split_pos = 0
    sh.horz_split_pos = 1
    wb.save(filename)
    #close con
    cur.close()
    con.close()
    print(' took %s seconds'%(time.time()-ts,))
    

def main():
    global connstr,connstr1
    connstr = 'ouchnsys/Jw2015@202.205.161.137:1521/orcl1'
    connstr1 = 'ouchnsys/Jw2015@10.100.134.177:1521/orcl'
    segments=['901','902','903','904','905','906','907']
    #get100wv1()
    #exp2csvnormal()
    #exp2xls_xlwt()
    exp2xls_redis('expxls2.xls','studentelc')
#-------------
#os.environ['NLS_LANG'] = 'AMERICAN_AMERICA.ZHS16GBK'
os.environ['NLS_LANG'] = '.utf8'
#get dic 
re = redis.Redis(host='10.96.142.109',port=6380,db=5)
courselist = re.hgetall('dic_course')
spylist    = re.hgetall('dic_spy')
orglist    = re.hgetall('dic_Org')
if __name__=='__main__' :
     main()
