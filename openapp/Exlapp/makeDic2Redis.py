import redis
import sys
import cx_Oracle
import time
import os
import json
import bson
def imp2redis(sql,dicname):
    ts = time.time()
    con = cx_Oracle.connect(connstr)
    cur = con.cursor()
    cur.execute(sql)
    for row in cur:
        re.hmset(dicname,{row[0]:row[1]})
    cur.close()
    con.close()
    print(' finish import %s took %s seconds '%(dicname,time.time()-ts))
        

def impCourse():
    sql = "select courseid,coursename from eas_course_basicinfo"
    imp2redis(sql,'dic_course')


def impSpy():
    sql = "select spycode,spyname from eas_spy_basicinfo"
    imp2redis(sql,'dic_spy')
    


def impOrganization():
    sql = "select organizationcode,organizationname from eas_org_basicinfo"
    imp2redis(sql,'dic_Org')


def impStudent(learningcentercode):
    # get db_data to json to bson
    con = cx_Oracle.connect(connstr)
    cur = con.cursor()
    sql = cur.execute("select a.studentcode,a.fullname,b.spyname,c.dicname as studenttype," \
                      " d.dicname as professionallevel,a.tcpcode from eas_schroll_student a" \
                      " inner join eas_spy_basicinfo b on a.spycode=b.spycode " \
                      " inner join eas_dic_studenttype c on a.studenttype=c.diccode "\
                      " inner join eas_dic_professionallevel d on a.professionallevel=d.diccode "\
                      " where a.learningcentercode=:orgcode ",(learningcentercode,))
    columns = [column[0] for column in cur.description]
    for row in cur:
        #re.hmset(learningcentercode,{row[0]:dict(zip(columns,row))})
        # store by bson
        re.hmset(learningcentercode,{row[0]:bson.dumps(dict(zip(columns,row)))})
    cur.close()
    con.close()
    

def main():
    global connstr
    connstr='ouchnsys/Jw2015@202.205.161.137:1521/orcl1'
    #impCourse()
    #impSpy()    
    #impOrganization()
    impStudent('9050201')

os.environ['NLS_LANG'] = '.utf8'
re = redis.Redis(host = '10.96.142.109',port=6380,db=5)

if __name__=='__main__':
      main()
