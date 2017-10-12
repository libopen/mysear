from queue import Queue
from threading import Thread
from expBybat import do_bat
import time
import redis
import expParameter
import os,sys

BATPATH='g:/migration/exp_script/'
SAVEPATH='d:/support/'
DBCENTER={'uid':'sa','pwd':'!!!WKSdatatest!!!','dbid':'course20170719','host':'202.205.160.183'}
DBZHJ={'uid':'sa','pwd':'!!!WKSdatatest!!!','dbid':'zhejiang0717','host':'202.205.160.177'}
#DBJIANGSU={'uid':'sa','pwd':'!!!WKSdatatest!!!','dbid':'canjiren','host':'202.205.160.183'}
DBCANJ={'uid':'sa','pwd':'!!!WKSdatatest!!!','dbid':'canjiren','host':'202.205.160.183'}
DBCHENGDU={'uid':'sa','pwd':'!!!WKSdatatest!!!','dbid':'chengdu0926','host':'202.205.160.183'}
DBNANJING={'uid':'sa','pwd':'!!!WKSdatatest!!!','dbid':'nanjing0721','host':'202.205.160.178'}
DBJIANGSU={'uid':'sa','pwd':'!!!WKSdatatest!!!','dbid':'jiangsu0925','host':'202.205.160.183'}
DBHENAN={'uid':'sa','pwd':'!!!WKSdatatest!!!','dbid':'henan20170523','host':'202.205.160.177'}
DBMID={'uid':'jwc','pwd':' wangbin','dbid':'AcademicAdministration','host':'202.205.160.199'}
DB234={'uid':'zx','pwd':' oOodVDunSuvkkyxF','dbid':'[20170921-zssj1]','host':'202.205.160.234'}
class doExpbatWorker(Thread):
      def __init__(self,queue):
          Thread.__init__(self)
          self.queue = queue
     
      def run(self):
          while True:
             # get the work from the queue and expand the tuple
             #if self.queue.qsize():
                 batfile,cmdbat = self.queue.get()
                 do_bat(batfile,cmdbat)
                #print(batfile,cmdbat)
                 self.queue.task_done()
             #else:
             #    break



def main(exp,expdb,targetcsvpath):

    
    bcppara={}
    bcppara['center']=DBCENTER
    bcppara['canjiren']=DBCANJ
    bcppara['zhejiang']=DBZHJ
    bcppara['mid'] = DBMID 
    bcppara['chengdu']=DBCHENGDU
    bcppara['henan']=DBHENAN
    bcppara['nanjing']=DBNANJING
    bcppara['jiangsu']=DBJIANGSU
    bcppara['zssj1']=DB234
	
	
    ts = time.time()
    # create a queue to communicate with the worker threads
    #queue=Queue()
    # Create 2 wroker threads
##    for x in range(6):
##        worker = doExpbatWorker(queue)
##        # setting daemon to True will let then main thread exit even though the workers are blocking
##        worker.demon = True
##        worker.start()
    #for i in range(9):
    #    queue.put(('~/'+str(i)+'.bat','dfdf'))
    expqueue=[]
	
    batlist = exp.split('-')
    batpath='g:/migration/exp_script/'
    csvpath="{csvRoot}{csvpath}/".format(csvRoot=SAVEPATH,csvpath=targetcsvpath)
    for batitem in batlist:
	    expbatFile="{batpath}{batname}.bat".format(batpath=BATPATH,batname=batitem)
	    csvFile="{csvpath}{csvname}.csv".format(csvpath=csvpath,csvname=batitem)
	    expPara="{expbatfile} {db} {csvfile} {host} {uid} {pwd}".format(expbatfile=expbatFile,db=bcppara[expdb]['dbid'],csvfile=csvFile,host=bcppara[expdb]['host'],uid=bcppara[expdb]['uid'],pwd=bcppara[expdb]['pwd'])
	    #expqueue.append((expbatFile, expPara))
	    do_bat(expbatFile,expPara)
    excl=[]
    #for item in expqueue:
    #     find = False
    #     for i in excl:
    #        if i in item[0]:
    #            find = True
    #            break
    #     if find == False:
            #if 'exemptapply' in item[0]:
    #        queue.put(item)
    #queue.join()
    print('took %s minuters '%((time.time()-ts)/60,))

if __name__ == "__main__":
     main(sys.argv[1],sys.argv[2],sys.argv[3])
