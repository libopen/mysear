import pika
import datetime
from  sqlalchemy import create_engine,MetaData,Table,Column,ForeignKey,func
from  sqlalchemy.ext.automap import automap_base
from  sqlalchemy.orm import sessionmaker

def callback(ch,method,properties,body):
    print(" [x] Received %s" % (body,))
    # body is byte so change to string
    updateScoreStatus(body.decode('utf-8'))
    print(" [x] Done")
    ch.basic_ack(delivery_tag=method.delivery_tag)


def updateScoreStatus(studentcode):
    # print(studentcode)
     a = datetime.datetime.now()
     DBsession = sessionmaker(bind=engine)
     session = DBsession()
     # loop score 
     for row in session.query(score).filter_by(studentcode=studentcode):
         retstatus = session.query(studystatus).filter_by(studentcode=row.studentcode).\
                                                filter_by(courseid=row.courseid).first()
     if retstatus is not  None:
        if ( retstatus.score is None) or (row.composescore>retstatus.score):
                      retstatus.score=row.composescore
                      retstatus.scorecode=row.composescorecode
                      retstatus.scoretype=row.examunit
                      if row.composescore>59 :
                          retstatus.studystatus='4'
     session.commit()     
     session.close()
     b = datetime.datetime.now()
     c =b-a
     print(" duration %s %s " % (divmod(c.days*86400+c.seconds,60),studentcode ))
    

# ouchndb    
engine = create_engine('oracle://ouchnsys:Jw2015@10.100.134.179:1521/orcl')
tables = ['eas_exmm_composescore','eas_elc_studentstudystatus']
metadata=MetaData()
metadata.reflect(engine,only=tables)
Base=automap_base(metadata=metadata)
Base.prepare()
score = Base.classes.eas_exmm_composescore
studystatus= Base.classes.eas_elc_studentstudystatus

#rabbitmq
mqconn = pika.BlockingConnection(pika.ConnectionParameters(host='localhost'))
channel = mqconn.channel()
channel.queue_declare(queue='StudyStatus')
channel.basic_qos(prefetch_count=1)
channel.basic_consume(callback,queue='StudyStatus')

try:
    channel.start_consuming()
except keyboardInterrupt:
    channel.stop_consuming()
mqconn.close()


