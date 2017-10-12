# coding=utf-8
from time import time
import sys,threading
import os.path
#from imp import reload
#reload(sys)
#sys.setdefaultencoding('utf-8')

# do bat in windos os by parameters
#batfile is the batch file's name batcmd is the cmd 
def do_bat(batfile,batcmd):
    print("thread %s:  [x] process %s" % (threading.current_thread().name,batfile))
    try:
       if os.path.isfile(batfile):
          os.system(batcmd)
          print (" [x] %s Done"%(batfile,))
       else:
          print(" %s is not exits "%(batfile,))
    except e:
       print(e)  




