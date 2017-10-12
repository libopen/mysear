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
    csvpath='g:/migration/mig_xw/'
    jb.append((batpath+'cps_xw_studentcourse.bat', batpath+'cps_xw_studentcourse.bat '+' AcademicAdministration '+ csvpath+'cps_xw_studentcourse.csv 202.205.160.199 jwc wangbin'))
    jb.append((batpath+'cps_xw_avgscore.bat', batpath+'cps_xw_avgscore.bat '+' AcademicAdministration '+ csvpath+'cps_xw_avgscore.csv 202.205.160.199 jwc wangbin'))
    #jb.append((batpath+'exmm_composescore330.bat', batpath+'exmm_composescore330.bat '+' zhejiang '+ csvpath+'exmm_composescore330.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
    #jb.append((batpath+'cps_xw_avgscore.bat', batpath+'cps_xw_avgscore.bat '+' AcademicAdministration '+ csvpath+'cps_xw_avgscore.csv 202.205.160.199 jwc wangbin'))
    #jb.append((batpath+'exmm_xkStandardplan330.bat', batpath+'exmm_xkStandardplan330.bat '+' zhejiang '+ csvpath+'exmm_xkstandsartplan330.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
    #jb.append((batpath+'exmm_xkStandard330.bat', batpath+'exmm_xkStandard330.bat '+' zhejiang '+ csvpath+'exmm_xkstandsart330.csv 202.205.160.183 sa !!!WKSdatatest!!!'))
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
