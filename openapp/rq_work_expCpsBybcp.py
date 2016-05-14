from rq_job_expCpsBybcp import expdata
from redis import Redis
from rq import Queue
from expParameter import expParameter

#get jobs from  expParameter
exp = expParameter('g:/migeration/script/','g:/mig/data/')

# rq redis server local port 6379 db 0
rqredis_conn = Redis()
q=Queue(connection=rqredis_conn)
var =1
while var==1:
      msg = input("Enter a batname:")
      #get exp bat parameter 
      jobs = exp.GetJobByName(msg)
      for item in jobs:
          batfile = '%s%s.bat'%(exp.batPath,msg)
          print('%s %s'%(batfile,item))
          job=q.enqueue(expdata,batfile,item)
          print (job.result)
