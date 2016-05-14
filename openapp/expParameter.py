import redis
class expParameter:
      batPath='g:/migeration/script/'
      expPath='g:/migeration/data/'
        
      def __init__(self,batPath,expPath):
          self.batPath = batPath
          self.expPath = expPath



      def GetExpBatcmd(self,dbName,batFile,expFile,dbIP,uid,pwd):
          bat = "%s%s"%(self.batPath,batFile)
          exp = "%s%s"%(self.expPath,expFile)
          cmd     = "%s %s %s %s %s %s"%(bat,dbName,exp,dbIP,uid,pwd)
          return bat,cmd


      def GetAllJobs(self):
          jobs=[]
          re = redis.Redis(host='10.96.142.109',port=6380,db=2)
          
          for item in re.hkeys('batdo'):
              batFile = "%s.bat"%(str(item.decode('utf-8')),)
              expFileName = str(re.hget('batdo',item).decode('utf-8'))
              expFilePath = str(re.hget('expfilepath',item).decode('utf-8'))
              scope = re.hget('batscope',item)
              if (scope==b'010'):
                 #get center db userid pwd
                 dbname = str(re.hget('dbname','10').decode('utf-8'))
                 dbip = str(re.hget('dbip','10').decode('utf-8'))
                 dbuser = str(re.hget('dbuser','10').decode('utf-8'))
                 dbpwd  = str(re.hget('dbpwd','10').decode('utf-8'))
                 expfile = "%s/%s.csv"%(expFilePath,expFileName)
                 jobs.append(self.GetExpBatcmd(dbname,batFile,expfile,dbip,dbuser,dbpwd))
              else :
                 for key in re.hkeys('dbip'):
                    if (key.decode('utf-8') !='10'):# exclude 010 db
                        skey =str(key.decode('utf-8'))
                        dbname = str(re.hget('dbname',skey).decode('utf-8'))
                        dbip = str(re.hget('dbip',skey).decode('utf-8'))
                        dbuser= str(re.hget('dbuser',skey).decode('utf-8'))
                        dbpwd = str(re.hget('dbpwd',skey).decode('utf-8'))
                        expfile = "%s/%s%s.csv"%(expFilePath,expFileName,skey)
                        jobs.append(self.GetExpBatcmd(dbname,batFile,expfile,dbip,dbuser,dbpwd))
          return jobs
      
      def GetJobByName(self,batname):
          jobs=[]
          re = redis.Redis(host='10.96.142.109',port=6380,db=2)
          expFilelist     = re.hgetall('batdo')
          expFilePathlist = re.hgetall('expfilepath')
          scopelist       = re.hgetall('batscope')
          
          bbatname = str.encode(batname) #conver to bytes string
          if bbatname in expFilelist:
             sBatFile = "%s.bat"%(batname,)
             sExpFileName = bytes.decode(expFilelist[bbatname])
             sExpFilePath = bytes.decode(expFilelist[bbatname])
             scope =        bytes.decode(scopelist[bbatname])
             if (scope=='010'):
                 #get center db userid pwd
                 dbname = bytes.decode(re.hget('dbname','10'))
                 dbip =   bytes.decode(re.hget('dbip','10'))
                 dbuser = bytes.decode(re.hget('dbuser','10'))
                 dbpwd  = bytes.decode(re.hget('dbpwd','10'))
                 expfile = "%s/%s.csv"%(sExpFilePath,sExpFileName)
                 jobs.append(self.GetExpBatcmd(dbname,sBatFile,expfile,dbip,dbuser,dbpwd))
             else :
                 for key in re.hkeys('dbip'):
                    if (key !=b'10'):# exclude 010 db
                        skey   = bytes.decode(key)
                        dbname = bytes.decode(re.hget('dbname',skey))
                        dbip =   bytes.decode(re.hget('dbip',skey))
                        dbuser=  bytes.decode(re.hget('dbuser',skey))
                        dbpwd = bytes.decode(re.hget('dbpwd',skey))
                        expfile = "%s/%s%s.csv"%(sExpFilePath,sExpFileName,skey)
                        jobs.append(self.GetExpBatcmd(dbname,sBatFile,expfile,dbip,dbuser,dbpwd))
          else:
             print(' bat is not exists')
          return jobs
            
