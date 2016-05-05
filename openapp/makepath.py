import redis
import os
import sys
rootpath='g:/mig/data/'
redis = redis.Redis(host='10.96.142.109',port=6380,db=2)
#get all batfile
filelist = redis.hkeys('batdo')
for item in filelist:
    filename = str(item.decode('utf-8'))
    if redis.hget('batfilepath',filename) is not None:
       batpath = rootpath+str(redis.hget('batfilepath',filename).decode('utf-8'))
       if os.path.exists(batpath)==False:
          os.makedirs(batpath)
    scope = redis.hget('batscope',filename)
    if scope is not None:
       if str(scope.decode('utf-8'))=='seg':
          batcmdA='copy '
          batcmdB='copy '
          expfile = str(redis.hget('batdo',filename).decode('utf-8'))
          batcmdFile = batpath+'/'+expfile+'.bat'
          for segitem in redis.smembers('segment'):
              segcode=str(segitem.decode('utf-8'))
              iSegcode = int(segcode[0])
              if iSegcode>3:
                 batcmdB=batcmdB+expfile+segcode+'.csv+'
              else:
                 batcmdA=batcmdA+expfile+segcode+'.csv+'
                  
              newfile=batpath+'/'+expfile+segcode+'.csv'
              if os.path.exists(newfile)==False:
                  f=open(newfile,'w')
                  f.close()
           
          print(batcmd[0:len(batcmdA)-1]+' '+expfile+'_A.csv')
          batcmd = open(batcmdAFile,'w')
          batcmd.write (batcmdA[0:len(batcmdA)-1]+' '+expfile+'_A.csv \n '+
                        batcmdB[0:len(batcmdB)-1]+' '+expfile+'_B.csv')
          
          batcmd.close()
                     
