from queue import Queue
from threading import Thread
from expBybat import do_bat
import time
import redis
import expParameter

class doExpbatWorker(Thread):
      def __init__(self,queue):
          Thread.__init__(self)
          self.queue = queue
     
      def run(self):
          while True:
             # get the work from the queue and expand the tuple
             batfile,cmdbat = self.queue.get()
             do_bat(batfile,cmdbat)
             #print(batfile,cmdbat)
             self.queue.task_done()



def main():
    ts = time.time()
    # create a queue to communicate with the worker threads
    queue=Queue()
    # Create 2 wroker threads
    for x in range(6):
        worker = doExpbatWorker(queue)
        # setting daemon to True will let then main thread exit even though the workers are blocking
        worker.demon = True
        worker.start()
    #for i in range(9):
    #    queue.put(('~/'+str(i)+'.bat','dfdf'))
    exp = expParameter.expParameter('g:/mig/script/','g:/mig/data/')
    jb = exp.GetAllJobs()
    for item in jb:
        queue.put(item)
    queue.join()
    print('took %s seconds '%(time.time()-ts,))

if __name__ == "__main__":
     main()
