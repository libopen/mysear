import csv
import os
import sys
from dbfread import DBF
from numpy import loadtxt
import csv
#from sqlalchemy import create_engine
import pandas as pd
import cx_Oracle

def dbf2csv(dbfname,csvname):
    with open(csvname,'w',newline='') as csvfile:
         wr =  csv.writer(csvfile,quoting=csv.QUOTE_NONE,quotechar='',escapechar='\\')
         table = DBF(dbfname)
         table.encoding='gb18030'
         fidnames = table.field_names
         for row in table:
              csvlist=['' for x in range(27)]
              #print('begin')
              for i in range(27):
                 if i==4: #gender
                   #print("{}:{}".format(fidnames[i],row[fidnames[i]]))
                   csvlist[i]=row[fidnames[i]]
                 else:
                   csvlist[i]=row[fidnames[i]]
              wr.writerow(csvlist)

def infobydb():
   # csv encoding is utf-16
   reader=csv.reader(open('OUCHNSYS.EAS_DIC_GENDER.txt','r',encoding='utf-16'))
   gender={rows[0]:rows[1] for rows in reader}
   reader=csv.reader(open('OUCHNSYS.EAS_DIC_ETHNICNAME.txt','r',encoding='utf-16'))
   ethnic={rows[0]:rows[1] for rows in reader}
   reader=csv.reader(open('OUCHNSYS.EAS_DIC_POLITICALSTATUS.txt','r',encoding='utf-16'))
   polica={rows[0]:rows[1] for rows in reader}
   sql=" select A.EXAMNO ,A.STUDENTCODE ,'' FULLNAME ,B.GENDER ,to_char(B.BIRTHDATE,'yyyymmdd')\
        ,B.IDNUMBER ,B.POLITICSSTATUS ,B.ETHNIC ,A.SPYCODE ,A.TCPCODE ,A.PROFESSIONALLEVEL  \
         from eas_schroll_student a inner join eas_schroll_studentbasicinfo b on a.studentid=b.studentid \
        where a.batchcode='201603' or a.batchcode='201609'"
   #orcl=create_engine('oracle://ouchnsys:Jw2015@202.205.161.137:1521/orcl1')
   #df=pd.read_sql_query(sql,orcl)
   #df.to_csv('info_db.csv',header=False,index=False,encoding='gb2312')
   with open('info_db.csv','w',newline='',encoding='utf-8') as csvfile:
       wr =  csv.writer(csvfile,quoting=csv.QUOTE_NONE,quotechar='',escapechar='\\')
       con = cx_Oracle.connect('ouchnsys/Jw2015@202.205.161.137:1521/orcl1')
       cursor = con.cursor()
       #method 1 can't solve the unicode
       #cursor.execute(sql)
       #try:
       #  for row in cursor:
       #     wr.writerow(row)
       #except UnicodeDecodeError:
       #     print(row)
       #method2 use while
       cursor.execute(sql)
       cursor.arraysize=200
       li = cursor.fetchall()
       for row in li:
          wr.writerow(row)
            
       cursor.close()
       con.close()
   

   


def main():
    dbffile=sys.argv[1]
    base= os.path.basename(dbffile)
    basename=os.path.splitext(base)[0]
    dbf2csv(dbffile,"{}.csv".format(basename))
    #infobydb()


#os.environ['NLS_LANG'] = 'AMERICAN_AMERICA.ZHS16GBK'
os.environ['NLS_LANG'] = '.zhs16gbk'
if __name__=='__main__':
     main()

