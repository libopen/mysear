# recover examcourseplancourse of one tcp in a segment and in a examplan into redis hmset 
import pika
import datetime
import redis
from  sqlalchemy import create_engine,MetaData,Table,Column,ForeignKey,func
from  sqlalchemy.ext.automap import automap_base
from  sqlalchemy.orm import sessionmaker




#redis
redis = redis.Redis(host='10.100.134.160',port=6380,db=1)
    

# ouchndb    create courseexamplan and save in redis  by use hmset typa

 
a = datetime.datetime.now()
engine = create_engine('oracle://ouchnsys:Jw2015@10.100.134.177:1521/orcl',echo=True)
tables = ['eas_exmm_examcourseplan','eas_exmm_examcourseplanlist','eas_exmm_subjectplan']
metadata=MetaData()
metadata.reflect(engine,only=tables)
Base=automap_base(metadata=metadata)
Base.prepare()
courseplan = Base.classes.eas_exmm_examcourseplan
courseplanlist= Base.classes.eas_exmm_examcourseplanlist
subjectplanlist= Base.classes.eas_exmm_subjectplan

DBsession = sessionmaker(bind=engine)
session = DBsession()
#get all courses list of only one examplancode and one examcategorycode and one segmentcode 
# two hmset one is  use exampapercode as key and courseid as value and other is exampapercode as key and examsessionunit as value and two hmset 'name is same
tcpcode='080305402010409'
examplancode='20150901'
examcatetorycode='04'
segmentcode='010'
hmset1=examplancode+'.'+examcatetorycode+'.'+segmentcode+'.'+tcpcode+'.courses'
hmset2=examplancode+'.'+examcatetorycode+'.'+segmentcode+'.'+tcpcode+'.sessionunit'
for row in session.query(courseplan).filter_by(tcpcode=tcpcode).\
                                     filter_by(examplancode=examplancode).\
                                     filter_by(examcategorycode=examcatetorycode).\
                                     filter_by(segmentcode=segmentcode):
    for row2 in  session.query(courseplanlist).filter_by(sn=row.sn):
        redis.hmset(hmset1,{ row2.exampapercode:row.courseid})
        row3 =session.query(subjectplanlist).filter_by(exampapercode=row2.exampapercode).\
                                     filter_by(examplancode=examplancode).\
                                     filter_by(examcategorycode=examcatetorycode).\
                                     filter_by(segmentcode=segmentcode).first()
        if row2 is not None:
             redis.hmset(hmset2,{ row3.exampapercode:row3.examsessionunit})


session.close()
b=datetime.datetime.now()
c =b-a
print(divmod(c.days*86400+c.seconds,60))
