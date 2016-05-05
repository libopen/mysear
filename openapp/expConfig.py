import pandas as pd
import redis
import sys
import os.path
import json

# for this app is use bcp for export data from mssql so  only use in windows 
# scope 1 is center 2  is segment 


"""
  *****************************
  this function is use to deal with every job of export 
  *****************************
"""
# --------------------begin --------------------------
def main():      
    re = redis.Redis(host='10.96.142.109',port=6380,db=2)
    #first flush db
    re.flushdb()
    if os.path.isfile('/home/user/python/datamigrate.xlsx'):
       xls = pd.ExcelFile('/home/user/python/datamigrate.xlsx')
       sheet1 = xls.parse('db')
       for index ,row in sheet1.iterrows():
           if (row['code']==10)==False:
               re.sadd('segment',row['code'])
           if (pd.isnull(row['dbip'])==False):
               re.hmset('dbip',{row['code']:row['dbip']})       
               re.hmset('dbuser',{row['code']:row['dbuser']})
               re.hmset('dbpwd',{row['code']:row['dbpwd']})
               re.hmset('dbip',{row['code']:row['dbip']})       
               re.hmset('dbname',{row['code']:row['dbname']})
               re.sadd('alldb',row['code'])
    

       sheet2 = xls.parse('expFile')
       for index ,row in sheet2.iterrows():
           re.hmset('batdo',{row['batfilename']:row['expfilename']})
           re.hmset('batscope',{row['batfilename']:row['scope']})
           re.hmset('expfilepath',{row['batfilename']:row['filepath']})
       print(" config is finished")
    else:
       pirnt("datamigrate.xlsx config file is not exist")

if __name__=="__main__":
     main()
