from queue import Queue
from threading import Thread
import time
import redis
import sys
import os.path
class doImpbatchWorker(Thread):
      def __init__(self,queue):
          Thread.__init__(self)
          self.queue = queue
     
      def run(self):
          while True:
             # get the work from the queue and expand the tuple
             csvfile = self.queue.get()
             print(' [x] process convert %s '% (csvfile,))
             impcmd = "dos2unix %s"%(ctlfile,)
             
             os.system(impcmd)
             self.queue.task_done()



def main():
    if 1==len(sys.argv):
       print ('enter the target db .. db1 or db2 or db3 ')
       return
    else:
       rootpath='/home/libin/data/'
       db = sys.argv[1]
       ts = time.time()
       myredis = redis.Redis(host='10.96.142.109',port=6380,db=3)
       curdb = myredis.hgetall(sys.argv[1])
       if 0<len(curdb.keys()) :
          # create a queue to communicate with the worker threads
          uid = str(curdb[b'uid'].decode('utf-8'))
          pwd = str(curdb[b'pwd'].decode('utf-8'))
          
          
          queue=Queue()
          # Create 2 wroker threads
          for x in range(6):
              worker = doImpbatchWorker(queue)
              # setting daemon to True will let then main thread exit even though the workers are blocking
              worker.demon = True
              worker.start()
          ctllist = myredis.hgetall('ctldb')
          pathlist = myredis.hgetall('ctlpath')
          for (key,val)  in ctllist.items():
              if db==str(val.decode('utf-8')):
                  csvpath = '%s%s/%s.csv'%(rootpath,str(pathlist[key].decode('utf-8'))\
                                                   ,str(key.decode('utf-8')))
                  
                  
                     if  os.path.isfile(csvpath):
                         if 'composescore' in str(key.decode('utf-8')):
                            queue.put((csvfile))
                         else:
                            print(' not i want')
                     else:
                         print('%s\'s csv is not exist'%(csvpath,))
                   
                         
          queue.join()    
       else:
          print(' %s is not in config'%(db,))  
       print('took %s minutes '%((time.time()-ts)/60,))

if __name__ == "__main__":
     main()
