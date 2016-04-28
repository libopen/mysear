import cx_Oracle
import csv

with open('/tmp/elc.csv','w') as csvfile:
      fieldnames = ['batchcode','courseid','segmentcode','learningcentercode','confirmstate']
      writer = csv.DictWriter(csvfile,fieldnames=fieldnames)
      writer.writeheader()
      #con = cx_Oracle.connect('ouchnsys/Jw2015@10.100.134.179/orcl')
      con = cx_Oracle.connect('ouchnsys/abc123@202.205.161.19/orcl')
      cur=con.cursor()
      cur.prepare('select a.batchcode,a.courseid, substr(a.learningcentercode,1,3) as segmentcode,a.learningcentercode,a.confirmstate,b.spycode,b.professionallevel,b.studenttype from eas_elc_studentelcinfo a inner join eas_schroll_student@ouchnbase b on A.STUDENTID =b.studentid where a.batchcode= :batchcode')
      cur.execute(None,{'batchcode':'201509'})
      for result in cur:
            writer.writer
            writer.writerow({'batchcode':result[0],'courseid':result[1],'segmentcode':result[2],'learningcentercode':result[3],'confirmstate':result[4]})
      cur.close()
      con.close()
      #con = cx_Oracle.connect('ouchnsys/Jw2015@10.100.134.178/orcl')
      con = cx_Oracle.connect('ouchnsys/abc123@202.205.161.20/orcl')
      cur=con.cursor()
      cur.prepare('select a.batchcode,a.courseid ,substr(a.learningcentercode,1,3) as segmentcode,a.learningcentercode,a.confirmstate,b.spycode,b.professionallevel,b.studenttype from eas_elc_studentelcinfo a inner join eas_schroll_student@ouchnbase b on A.STUDENTID =b.studentid where a.batchcode= :batchcode')
      cur.execute(None,{'batchcode':'201509'})
      for result in cur:
            writer.writer
            writer.writerow({'batchcode':result[0],'courseid':result[1],'segmentcode':result[2],'learningcentercode':result[3],'confirmstate':result[4]})
      cur.close()
      con.close()


