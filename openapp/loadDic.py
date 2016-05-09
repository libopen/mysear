import os,sys,string

if 1==len(sys.argv) :
   print (" no path")
else:
 
   dir =sys.argv[1]
   for root ,dirs ,files in os.walk(dir):
       for name in files:
           if os.path.isfile(os.path.join(root,name)) and ('ctl' in name) :
                print('process load %s'%(os.path.join(root,name),))
                cmd = 'sqlldr ouchnsys/Jw2015@202.205.161.137:1521/orcl1 control=%s'%(os.path.join(root,name),)
                os.system(cmd)
                #print('%s is finish'%(cmd,))
