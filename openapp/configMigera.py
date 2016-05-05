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
       expFilepath = str(redis.hget('batfilepath',batname).decode('utf-8'))
         
       if (scopetype==1):
          #get center db userid pwd
           dbname = str(redis.hget('dbname','10').decode('utf-8'))
           dbip = str(redis.hget('dbip','10').decode('utf-8'))
           dbuser = str(redis.hget('dbuser','10').decode('utf-8'))
           dbpwd  = str(redis.hget('dbpwd','10').decode('utf-8'))
           messagebody=getMessagebody(batname,dbname,expFilepath+'\\'+expFileName,dbip,dbuser,dbpwd)
           channel.basic_publish(exchange='',routing_key='cps1',body=messagebody)
           print (' [x] process %s' %(messagebody,))
       else :
           for key in redis.hkeys('dbip'):
               if (key.decode('utf-8') !='10'):# exclude 010 db
                  skey =str(key.decode('utf-8'))                  
                  dbname = str(redis.hget('dbname',skey).decode('utf-8'))
                  dbip = str(redis.hget('dbip',skey).decode('utf-8'))
                  dbuser= str(redis.hget('dbuser',skey).decode('utf-8'))
                  dbpwd = str(redis.hget('dbpwd',skey).decode('utf-8'))
                  messagebody=getMessagebody(batname,dbname,expFilepath+'\\'+expFileName+str(key.decode('utf-8')),dbip,dbuser,dbpwd)
                  print('[x] process %s'%(getMessagebody(batname,dbname,expFileName+str(key.decode('utf-8')),dbip,dbuser,dbpwd),))
                  channel.basic_publish(exchange='',routing_key='cps1',body=messagebody)
    else :
          print(' %s is not exists'%(batname,))
               
# --------------------begin --------------------------
       
redis = redis.Redis(host='10.96.142.109',port=6380,db=2)
#first flush db
redis.flushdb()

xls = pd.ExcelFile('/home/user/python/datamigrate.xlsx')
sheet1 = xls.parse('db')
for index ,row in sheet1.iterrows():
    if (row['code']==10)==False:
       redis.sadd('segment',row['code'])
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
    redis.hmset('expfilepath',{row['batfilename']:row['filepath']})


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
var =1
while var==1:
  batmsg=input("Enter a batname:")
  print (" process : %s"% (batmsg,))
  if redis.hget('batdo',batmsg) is not None:
     batfile = redis.hget('batdo',batmsg).decode('utf-8')
     print(batfile)
     scope = redis.hget('batscope',batmsg).decode('utf-8')
     if str(scope)=='seg':
         AddbatMessage(batmsg,2)
     else: 
         AddbatMessage(batmsg,1)
  else:
     print('%s is not exist'%(batfile,))
     

#AddbatMessage('exmm_order',2)

mqconn.close()
