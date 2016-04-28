import datetime
import time
from  sqlalchemy import create_engine,MetaData,Table,Column,ForeignKey,func,Integer,String,Sequence,func
from  sqlalchemy.ext.automap import automap_base
from  sqlalchemy.orm import sessionmaker


def getMaxClass(classcode):
                  sql = 'select nvl(max(substr(classcode,length(classcode)-2,3)),0) from eas_org_classinfo  where classcode like :classcode '          
                  result = engine.execute(sql,classcode=classcode+'%')
                  resultnum=0 
                  for row in result:
                         resultnum=int(row[0])+1
                  print(resultnum,classcode)
                  return (3-len(str(resultnum)))*'0'+str(resultnum)
   

def AddNewClass(batchcode,spycode,segmentcode,learningcentercode):
        i=1
        for tcprow in session.query(tcp).filter_by(batchcode=batchcode).\
                                     filter_by(spycode = spycode):
                  scode = batch[2:4]+str(learningcentercode)+tcprow.studenttype+tcprow.professionallevel
                  retclass= session.query(classinfo).filter_by(spycode=tcprow.spycode).\
                                                           filter_by(studentcategory=str(tcprow.studenttype)+str(tcprow.professionallevel)).\
                                                           filter_by(learningcentercode=learningcentercode).\
                                                           filter_by(batchcode=batchcode).first()
                  classname='分部'+str(segmentcode)+':'+batch[2:6]
                  if retclass is None:
                       newclasscode = scode+getMaxClass(scode)
                       print('add new class %s'%(newclasscode,))

                       retspy = session.query(spyinfo).filter_by(spycode=spycode).first()
                       if retspy is not None:
                          classname=classname+retspy.spyname
                          seq=Sequence('org_class_seq')
                          nextid = engine.execute(seq)
                          dt = func.to_date(datetime.datetime.now,'yyyy-mm-dd H:M:S')
                          #print(nextid)
                          newclass = classinfo(classid=nextid,batchcode=batchcode,learningcentercode=learningcentercode,classcode=newclasscode,classname=classname,studentcategory=str(tcprow.studenttype)+str(tcprow.professionallevel),spycode=spycode,professionallevel=tcprow.professionallevel,examsitecode=learningcentercode,classteacher='')
                          session.add(newclass)
                          #session.flush()
                          session.commit()
                          
                  else :
                       classname=retclass.classname
                                            
                  print('classname : %s  '  % (classname,))
  

#add class and modify exists data of student to new 
a = datetime.datetime.now()
engine = create_engine('oracle://ouchnsys:abc123@202.205.161.18:1521/orcl')
tables = ['eas_tcp_guidance','eas_schroll_student','eas_org_classinfo','eas_spy_basicinfo']
metadata=MetaData()
metadata.reflect(engine,only=tables) 
Base=automap_base(metadata=metadata)
Base.prepare()

tcp = Base.classes.eas_tcp_guidance
student= Base.classes.eas_schroll_student
classinfo= Base.classes.eas_org_classinfo
spyinfo=Base.classes.eas_spy_basicinfo

batchlist = ['201503','201509','201603']
spylist =['11030118','03010113','51010101','51010111']

DBsession = sessionmaker(bind=engine)
session = DBsession()

for batch in batchlist:
    for spy in spylist:
                  AddNewClass(batch,spy,'912','91001')
                                 
#session.commit()
session.close()
b=datetime.datetime.now()
c =b-a
print(divmod(c.days*86400+c.seconds,60))









