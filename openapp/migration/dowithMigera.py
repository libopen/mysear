import pika
import os
import os.path
import json
import logging
import redis
credentials = pika.PlainCredentials('libin','abc123')
parameters = pika.ConnectionParameters('10.96.142.108',5672,'datamigerate',credentials)
mqconn = pika.BlockingConnection(parameters)
channel = mqconn.channel()
channel.queue_declare(queue='cps1')
batFilePath="g:/migeration/script/"
expFilePath="g:/mig/data/"
logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
                    datefmt='%a ,%d %b %Y %H:%M:%S',
                    filename='datamigera.log',
                    filemode='w')
redis = redis.Redis(host='10.96.142.109',port=6380,db=2)
                  
def callback(ch,method,properties,body):
    print ("[x] Received %s" %(body.decode('utf-8'),))
    strPara = str(body.decode('utf-8'))
    d = json.loads(strPara)
    print(" process %s " % (d['batFileName'],))
    batFile =batFilePath+ str(d['batFileName'])+'.bat'
    dbname=str(d['dbName'])
    dbip =str(d['dbip'])
    uid  =str(d['dbUser'])
    pwd  =str(d['dbPwd'])
    exp  = expFilePath+str(d['expFileName'])+'.csv'
    try:
        if os.path.isfile(batFile):
           cmd = batFile+' '+dbname+' '+exp+' '+dbip+' '+uid+' '+pwd
           os.system(cmd)
           #return os shell cmd result
           #stream = os.popen(cmd)
           print(" [x] %s  Done" % (batFile,))
           channel.basic_ack(delivery_tag=method.delivery_tag)
        else:
           print(" %s is not exist "%(batFile,))
           #logging.info('bat: %s not get %s '%((batFile+dbname),exp))
           redis.sadd('NoExport',batFile+'-'+dbname)
           channel.basic_ack(delivery_tag=method.delivery_tag)
    except e:
        print(e)
        

channel.basic_qos(prefetch_count=1)
channel.basic_consume(callback,queue='cps1')
try:
   channel.start_consuming()
except keyboardInterrupt:
   channel.stop_consuming()
mqconn.colse()
