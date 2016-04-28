from sqlalchemy import create_engine,MetaData,Table,Column,ForeignKey
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import sessionmaker

engine = create_engine('oracle://ouchnsys:Jw2015@10.100.134.179:1521/orcl')
metadata = MetaData()
# table name  is lower 
tables = ['eas_elc_studentstudystatus','eas_exmm_composescore']
metadata.reflect(engine,only=tables)
Base = automap_base(metadata=metadata)
Base.prepare()
for i in metadata.sorted_tables:
      print(i.name)

cls = Base.classes.eas_elc_studentstudystatus
DBSession = sessionmaker(bind=engine)
session = DBSession()
studystatus = session.query(cls).filter(cls.sn==7911779).one() 
session.close()
