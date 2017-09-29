import numpy as np
from dbfread import DBF
import sys

kshcsv=sys.argv[1]
xhlist=[]
f1=open(kshcsv,'r')
i=0
for line in f1:
   if len(line)>0:
     xhlist.append(line[0:-1])
     i=i+1
   #print(line[0:-1])
print("total:{}".format(i))


f=open("exec_{}.sql".format(kshcsv),'w+')
table0 = DBF('ZXSMD_0000_50z.dbf')
table0.encoding='gb18030'
for row in table0:
    #print("{},{}".format(str(row['XH']),(str(row['XH']) in xhlist)))
    if str(row['XH']) in xhlist:
       print("{},{}".format(row['XH'],row['KSH']))
       print("update eas_schroll_student set examno='{}' where studentcode='{}';".format(row['KSH'],row['XH']),file=f)
       i=i-1


table = DBF('ZXSMD_0000_50b.dbf')
table.encoding='gb18030'
for row in table:
    if str(row['XH']) in xhlist:
       print("{},{}".format(row['XH'],row['KSH']))
       print("update eas_schroll_student set examno='{}' where studentcode='{}';".format(row['KSH'],row['XH']),file=f)
       i=i-1
print('commit;',file=f)
f.close()
print ("{} is lost".format(i))

