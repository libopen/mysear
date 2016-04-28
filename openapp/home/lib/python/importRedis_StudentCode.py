import redis
from sqlalchemy import create_engine,MetaData,Table,Column,ForeignKey
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import sessionmaker


# get student/studentcode in learning on base db , then send into redis use set type
engine = create_engine('oracle://ouchnsys:Jw2015@10.100.134.177:1521/orcl')
tables = ['eas_schroll_student']
metadata=MetaData()
metadata.reflect(engine,only=tables)
Base = automap_base(metadata=metadata)
Base.prepare()
student = Base.classes.eas_schroll_student
#print(student.__table__)
# get data then import redis only save in redis db1
redis = redis.Redis(host='10.100.134.160',port=6380,db=1)
DBsession = sessionmaker(bind=engine)
session = DBsession()
redisKey = "student.6510000"
for studentcode in session.query(student.studentcode).filter_by(learningcentercode='6510000').\
                                                      filter_by(enrollmentstatus='1'):
    #print(studentcode[0])
    redis.sadd(redisKey,studentcode[0])
session.close()
print (redis.scard(redisKey))






