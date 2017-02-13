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
   reader=csv.reader(open('OUCHNSYS.EAS_DIC_GENDER.txt','r',encoding='utf-16'))
   gender={rows[1]:rows[0] for rows in reader}
   reader=csv.reader(open('OUCHNSYS.EAS_DIC_ETHNICNAME.txt','r',encoding='utf-16'))
   ethnic={rows[1]:rows[0] for rows in reader}
   reader=csv.reader(open('OUCHNSYS.EAS_DIC_POLITICALSTATUS.txt','r',encoding='utf-16'))
   polica={rows[1]:rows[0] for rows in reader}
   with open(csvname,'w',newline='') as csvfile:
         wr =  csv.writer(csvfile,quoting=csv.QUOTE_NONE,quotechar='',escapechar='\\')
         table = DBF(dbfname)
         table.encoding='gb18030'
         fidnames = table.field_names
         for row in table:
              dic = {key:'' for key in fidnames}
              
              #print('begin')
              for x in fidnames:
                  dic[x]=row[x]
                  if x=='XB':
                    dic[x]=gender[row[x]]
                  elif x=='MZ':
                    dic[x]=ethnic[row[x]]
                  elif x=='ZZMM':
                    dic[x]=polica[row[x]]
              csvlist=[dic[x] for x in ['KSH','XH','XM','CSRQ','SFZH','MZ','ZZMM','XB']]
              wr.writerow(csvlist)

def compbypandas():
    pass
    
    

def infobydb():
   # csv encoding is utf-16
   # this methon is aborted by some chinese char 
   reader=csv.reader(open('OUCHNSYS.EAS_DIC_GENDER.txt','r',encoding='utf-16'))
   gender={rows[0]:rows[1] for rows in reader}
   reader=csv.reader(open('OUCHNSYS.EAS_DIC_ETHNICNAME.txt','r',encoding='utf-16'))
   ethnic={rows[0]:rows[1] for rows in reader}
   reader=csv.reader(open('OUCHNSYS.EAS_DIC_POLITICALSTATUS.txt','r',encoding='utf-16'))
   polica={rows[0]:rows[1] for rows in reader}
   sql=" select A.EXAMNO ,A.STUDENTCODE ,A.FULLNAME ,B.GENDER ,to_char(B.BIRTHDATE,'yyyymmdd')\
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

