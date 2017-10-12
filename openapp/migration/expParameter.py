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
      
      def GetExpBatcmd6(self,dbName,batFile,expFile,dbIP,uid,pwd,segment):
          bat = "%s%s"%(self.batPath,batFile)
          exp = "%s%s"%(self.expPath,expFile)
          cmd     = "%s %s %s %s %s %s %s "%(bat,dbName,exp,dbIP,uid,pwd,segment)
          return bat,cmd
            

      def GetAllJobs(self,expscope='all'):
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
                 if "11exmm_composescoreseg" in batFile:
                       for key in re.smembers('segment'):
                         seg = str(key.decode('utf-8'))
                         expfile = "%s/%s%s.csv"%(expFilePath,expFileName,seg)
                       
                         jobs.append(self.GetExpBatcmd6(dbname,batFile,expfile,dbip,dbuser,dbpwd,seg))
                 elif  "11elc_elc" in batFile:
                       for key in re.smembers('segment'):
                         seg = str(key.decode('utf-8'))
                         expfile = "%s/%s%s.csv"%(expFilePath,expFileName,seg)
                         jobs.append(self.GetExpBatcmd6(dbname,batFile,expfile,dbip,dbuser,dbpwd,seg))

                 else :
                       if expscope=='all':
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

def main():
      exp = expParameter('g:/migration/exp_script/','e:/migration/expdata/data/')
      jb = exp.GetAllJobs('all')
      excl=['netexamscore','societyscore','composescore','elc_elc','studystatus']
      
      for item in jb:
           find = False
           for i in excl:
            if i in item[0]:
                find = True
                break
           if find == False:
              print ("do exec {}".format(item))
                  


if __name__=="__main__":
      main()
