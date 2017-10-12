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
    
    jb = []
    batpath='g:/migration/exp_script/'
    csvpath='g:/migration/expdata/data/guidance_new/'
    #jb.append((batpath+'tcp_guidance.bat', batpath+'tcp_guidance.bat '+' center '+ csvpath+'neweas_tcp_guidance.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
    #jb.append((batpath+'tcp_module.bat', batpath+'tcp_module.bat '+' center '+ csvpath+'eas_tcp_module.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
    #jb.append((batpath+'tcp_modulecourses.bat', batpath+'tcp_modulecourses.bat '+' center '+ csvpath+'eas_tcp_modulecourses.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
    #jb.append((batpath+'tcp_implementation.bat', batpath+'tcp_implementation.bat '+' zhejiang '+ csvpath+'eas_tcp_implementation330.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
    #jb.append((batpath+'tcp_implementation.bat', batpath+'tcp_implementation.bat '+' canjiren '+ csvpath+'eas_tcp_implementation805.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
    #jb.append((batpath+'tcp_implmodulecourse.bat', batpath+'tcp_implmodulecourse.bat '+' zhejiang '+ csvpath+'eas_tcp_implmodulecourse330.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
    #jb.append((batpath+'tcp_implmodulecourse.bat', batpath+'tcp_implmodulecourse.bat '+' canjiren '+ csvpath+'eas_tcp_implmodulecourse805.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
    #jb.append((batpath+'tcp_execution.bat', batpath+'tcp_execution.bat '+' zhejiang '+ csvpath+'eas_tcp_execution330.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
    #jb.append((batpath+'tcp_execution.bat', batpath+'tcp_execution.bat '+' canjiren '+ csvpath+'eas_tcp_execution805.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
    #jb.append((batpath+'tcp_execmodulecourse.bat', batpath+'tcp_execmodulecourse.bat '+' zhejiang '+ csvpath+'eas_tcp_execmodulecourse330.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
    #jb.append((batpath+'tcp_execmodulecourse.bat', batpath+'tcp_execmodulecourse.bat '+' canjiren '+ csvpath+'eas_tcp_execmodulecourse805.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
    #jb.append((batpath+'cps_student.bat', batpath+'cps_student.bat '+' center '+ csvpath+'cps_student.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
    jb.append((batpath+'schroll_absence.bat', batpath+'schroll_absence.bat '+' zhejiang '+ csvpath+'eas_schroll_absence330.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
    jb.append((batpath+'schroll_absence.bat', batpath+'schroll_absence.bat '+' canjiren '+ csvpath+'eas_schroll_absence805.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
    excl=[]
    for item in jb:
         find = False
         for i in excl:
            if i in item[0]:
                find = True
                break
         if find == False:
            #if 'exemptapply' in item[0]:
            queue.put(item)
    queue.join()
    print('took %s minuters '%((time.time()-ts)/60,))

if __name__ == "__main__":
     main()
