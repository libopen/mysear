import pika
import datetime
import redis
from  sqlalchemy import create_engine,MetaData,Table,Column,ForeignKey,func,Integer,String
from  sqlalchemy.ext.automap import automap_base
from  sqlalchemy.orm import sessionmaker




#redis
redis = redis.Redis(host='10.100.134.160',port=6380,db=1)
    

# ouchndb    create courseexamplan and save in redis  by use hmset typa

 
a = datetime.datetime.now()
engine = create_engine('oracle://ouchnsys:Jw2015@10.100.134.177:1521/orcl',echo=True)
tables = ['eas_exmm_examcourseplanlist']
metadata=MetaData()
metadata.reflect(engine,only=tables)


Base=automap_base(metadata=metadata)
Base.prepare()

#class eas_exmm_examcourseplanlist(Base):
#      __tablename__='eas_exmm_examcourseplanlist'
      
#      sn= Column(Integer,primary_key=True)
#      normcode= Column(String(10),primary_key=True)
#      exampapercode=Column(String(60),primary_key=True)

#DBsession = sessionmaker(bind=engine)
#session = DBsession()
#for row in session.query(eas_exmm_examcourseplanlist).filter_by(sn=1339):
#    print(row)
for tb in Base.classes:
    print(tb)
b=datetime.datetime.now()
c =b-a
print(divmod(c.days*86400+c.seconds,60))
