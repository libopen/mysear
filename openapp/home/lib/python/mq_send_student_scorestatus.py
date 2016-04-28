import redis
import pika
#get message from redis then send to rabbitmq

mqconn = pika.BlockingConnection(pika.ConnectionParameters(host='localhost'))
channel = mqconn.channel()
channel.queue_declare(queue='StudyStatus')

redis = redis.Redis(host='10.100.134.160',port=6380,db=1)
redisKey = "student.6510000"
while (redis.scard(redisKey)>0):
      messagebody = redis.spop(redisKey)
      channel.basic_publish(exchange='',routing_key='StudyStatus',\
                                        body=messagebody)

mqconn.close()
      
