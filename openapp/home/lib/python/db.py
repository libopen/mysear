import pika
import datetime
from  sqlalchemy import create_engine,MetaData,Table,Column,ForeignKey,func
from  sqlalchemy.ext.automap import automap_base
from  sqlalchemy.orm import sessionmaker



    

# ouchndb    
a = datetime.datetime.now()
engine = create_engine('oracle://ouchnsys:Jw2015@10.100.134.179:1521/orcl',echo=True)
tables = ['eas_exmm_composescore','eas_elc_studentstudystatus']
metadata=MetaData()
metadata.reflect(engine,only=tables)
Base=automap_base(metadata=metadata)
Base.prepare()
score = Base.classes.eas_exmm_composescore
studystatus= Base.classes.eas_elc_studentstudystatus
DBsession = sessionmaker(bind=engine)
session = DBsession()
for row in session.query(score).filter_by(studentcode='1490206450236'):
    retstatus = session.query(studystatus).filter_by(studentcode=row.studentcode).\
                                           filter_by(courseid=row.courseid).\
                                           first()
     #judge the value or object  is null use  is None 
    if retstatus is not  None:
       if ( retstatus.score is None) or (row.composescore>retstatus.score):
          retstatus.score=row.composescore
          retstatus.scorecode=row.composescorecode
          retstatus.scoretype=row.examunit
          if row.composescore>59 :
             retstatus.studystatus='4'



session.commit()
session.close()
b=datetime.datetime.now()
c =b-a
print(divmod(c.days*86400+c.seconds,60))
