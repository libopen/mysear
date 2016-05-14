import os.path
#this job is only work in windows and mssql that has a tools the name is  bcp
def expdata(batfile,batcmd):
    print(' [x] process %s '%(batcmd,))
    try:
       if os.path.isfile(batfile):
          os.system(batcmd)
          return (' [x] %s Done'%(batfile,))
       else:
          return (' %s is not exists'%(batfile,))
    except e:
       return (e)
