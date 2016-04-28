import pandas as pd
import redis
import pika
import sys
import objectMigera
import json

# for this app is use bcp for export data from mssql so  only use in windows 
# scope 1 is center 2  is segment 
"""
   this function is use to create message body of json type
"""

def getMessagebody(batfile,dbname,expFileName,dbip,dbUser,dbPwd):
    objcon = objectMigera.ConfigMigera(batfile,dbname,expFileName,dbip,dbUser,dbPwd)
    return json.dumps(objcon,default=lambda obj: obj.__dict__)

"""
  *****************************
  this function is use to deal with every job of export 
  *****************************
"""
def AddbatMessage(batname,scopetype=1):
    #get batname and expfilename  from redis 
   
    if redis.hget('batdo',batname) is not  None: 
       expFileName = str(redis.hget('batdo',batname).decode('utf-8'))
         
       if (scopetype==1):
          #get center db userid pwd
           dbname = str(redis.hget('dbname','10').decode('utf-8'))
           dbip = str(redis.hget('dbip','10').decode('utf-8'))
           dbuser = str(redis.hget('dbuser','10').decode('utf-8'))
           dbpwd  = str(redis.hget('dbpwd','10').decode('utf-8'))
           messagebody=getMessagebody(batname,dbname,expFileName,dbip,dbuser,dbpwd)
           channel.basic_publish(exchange='',routing_key='cps1',body=messagebody)
       else :
           for key in redis.hkeys('dbip'):
               if (key.decode('utf-8') !='10'):# exclude 010 db
                  skey =str(key.decode('utf-8'))                  
                  dbname = str(redis.hget('dbname',skey).decode('utf-8'))
                  dbip = str(redis.hget('dbip',skey).decode('utf-8'))
                  dbuser= str(redis.hget('dbuser',skey).decode('utf-8'))
                  dbpwd = str(redis.hget('dbpwd',skey).decode('utf-8'))
                  messagebody=getMessagebody(batname,dbname,expFileName+str(key.decode('utf-8')),dbip,dbuser,dbpwd)
                  #print(getMessagebody(batname,dbname,expFileName+str(key.decode('utf-8')),dbip,dbuser,dbpwd))
                  channel.basic_publish(exchange='',routing_key='cps1',body=messagebody)
               
# --------------------begin --------------------------
       
redis = redis.Redis(host='10.96.142.109',port=6380,db=2)
#first flush db
redis.flushdb

xls = pd.ExcelFile('/home/user/python/datamigrate.xlsx')
sheet1 = xls.parse('db')
for index ,row in sheet1.iterrows():
    if (pd.isnull(row['dbip'])==False):
         redis.hmset('dbip',{row['code']:row['dbip']})       
         redis.hmset('dbuser',{row['code']:row['dbuser']})
         redis.hmset('dbpwd',{row['code']:row['dbpwd']})
         redis.hmset('dbip',{row['code']:row['dbip']})       
         redis.hmset('dbname',{row['code']:row['dbname']})
         redis.sadd('alldb',row['code'])

sheet2 = xls.parse('expFile')
for index ,row in sheet2.iterrows():
    redis.hmset('batdo',{row['batfilename']:row['expfilename']})
    redis.hmset('batscope',{row['batfilename']:row['scope']})


# by config add message to MQ
# rabbitmq server 10.96.142.108 take care link remote host 
#datamigerate is the vhost 

credentials = pika.PlainCredentials('libin','abc123')
parameters = pika.ConnectionParameters('10.96.142.108',5672,'datamigerate',credentials)
mqconn = pika.BlockingConnection(parameters)
channel = mqconn.channel()
#declare queue 
channel.queue_declare(queue='cps1')
# add message
#look for message : rabbitmqctl list_queues -p datamigerate

#1. course_basicinfo/010
AddbatMessage('course_basicinfo',1)

#2. org_baseinfo/ all segment
AddbatMessage('org_baseinfo',2)

#3. org_baseinfo010/010 
AddbatMessage('org_baseinfo010',1)

#4. org_baseinfo900/010 
AddbatMessage('org_baseinfo900',1)

#5 org_class/010
AddbatMessage('org_class',2)

#6. schroll_student/010
AddbatMessage('schroll_student',1)

#7. schroll_studentBaseinfo/010
AddbatMessage('schroll_studentBaseinfo',1)

#8 spy_basicinfo/010
AddbatMessage('spy_basicinfo',1)

#9 spy_openspycen/010
AddbatMessage('spy_openspycen',1)

#10 spy_openspyseg/seg
AddbatMessage('spy_openspyseg',2)

#11 spy_openspylea/seg
AddbatMessage('spy_openspylea',2)

#12 tcp_cooperation/010
AddbatMessage('tcp_cooperation',1)

#12 tcp_guidance/010
AddbatMessage('tcp_guidance',1)

#12 tcp_module/010
AddbatMessage('tcp_module',1)

#12 tcp_modulecourses/010
AddbatMessage('tcp_modulecourses',1)

#12 tcp_conversioncourse/010
AddbatMessage('tcp_conversioncourse',1)

#12 tcp_segmsemecourses/seg
AddbatMessage('tcp_segmsemecourses',2)

#12 tcp_learcentsemecour/seg
AddbatMessage('tcp_learcentsemecour',2)

#12 tcp_implementation/seg
AddbatMessage('tcp_implementation',2)

#12 tcp_implmodulecourse/seg
AddbatMessage('tcp_implmodulecourse',2)

mqconn.close()
