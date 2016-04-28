import datetime
from  sqlalchemy import create_engine,MetaData,Table,Column,ForeignKey,func,Integer,String
from  sqlalchemy.ext.automap import automap_base
from  sqlalchemy.orm import sessionmaker

a = datetime.datetime.now()
engine = create_engine('oracle://ouchnsys:abc123@202.205.161.18:1521/orcl')
tables = ['eas_tcp_guidance','eas_schroll_student']
metadata=MetaData()
metadata.reflect(engine,only=tables) 
Base=automap_base(metadata=metadata)
Base.prepare()
tcp = Base.classes.eas_tcp_guidance
student = Base.classes.eas_schroll_student
batchlist = ['201503','201509','201603']
spylist =['11030118','03010113','51010101','51010111']

DBsession = sessionmaker(bind=engine)
session = DBsession()
i=0
for batch in batchlist:
    for spy in spylist:
        for tcprow in session.query(tcp).filter_by(batchcode=batch).\
                                     filter_by(spycode = spy):
             for j in range(910,911):
                  scode = batch[2:4]+str(j)+tcprow.studenttype+tcprow.professionallevel
                  print('tcp : %s %r %s '  % (tcprow.tcpcode,i,scode))
                  sql = 'select nvl(max(substr(studentcode,length(studentcode)-5,5)),0) from eas_schroll_student where studentcode like :studentcode'          
                  result = engine.execute(sql,studentcode=scode+'%')
                  resultcode=0
                  for row in result:
                      resultcode=str(row[0])
                  print((5-len(resultcode))*'0'+resultcode)
                  i=i+1
session.close()
b=datetime.datetime.now()
c =b-a
print(divmod(c.days*86400+c.seconds,60))



def AddNew(batchcode,spycode,segmentcode,learningcentercode):
        for tcprow in session.query(tcp).filter_by(batchcode=batchcode).\
                                     filter_by(spycode = spycode):
                  scode = batch[2:4]+str(segmentcode)+tcprow.studenttype+tcprow.professionallevel
                  print('tcp : %s %r %s '  % (tcprow.tcpcode,i,scode))
                  sql = 'select nvl(max(substr(studentcode,length(studentcode)-5,5)),0) from eas_schroll_student where studentcode like :studentcode'          
                  result = engine.execute(sql,studentcode=scode+'%')
                  resultcode=0
                  for row in result:
                      resultcode=str(row[0])
  






