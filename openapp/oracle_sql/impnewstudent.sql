select * from eas_org_classinfo a inner join eas_org_classinfo_temp b 
on A.BATCHCODE = B.BATCHCODE and a.LEARNINGCENTERCODE=b.LEARNINGCENTERCODE and a.classcode=b.classcode
where a.classname<>b.classname
----------------

MERGE INTO OUCHNSYS.EAS_ORG_CLASSINFO A USING
 EAS_ORG_CLASSINFO_temp B
ON (A.BATCHCODE = B.BATCHCODE and a.LEARNINGCENTERCODE=b.LEARNINGCENTERCODE and a.classcode=b.classcode)
WHEN NOT MATCHED THEN 
INSERT (
  CLASSID, BATCHCODE, LEARNINGCENTERCODE, CLASSCODE, CLASSNAME, 
  STUDENTCATEGORY, SPYCODE, PROFESSIONALLEVEL, EXAMSITECODE, CLASSTEACHER, 
  CREATETIME)
VALUES (
  B.CLASSID, B.BATCHCODE, B.LEARNINGCENTERCODE, B.CLASSCODE, B.CLASSNAME, 
  B.STUDENTCATEGORY, B.SPYCODE, B.PROFESSIONALLEVEL, B.EXAMSITECODE, B.CLASSTEACHER, 
  B.CREATETIME);

COMMIT;
---12144 rows merged.


merge into eas_schroll_student a 
using eas_schroll_student1 b on (A.STUDENTID =B.STUDENTID  )
when not matched then
insert (StudentID,BatchCode,StudentCode,FullName,TCPCode,LearningCenterCode,ClassCode,SpyCode,ProfessionalLevel,StudentType,StudentCategory,OriginalSubject,OriginalCategory,EnrollmentStatus,AdmissionTime,CreateTime,ExamNo)
values(b.StudentID,b.BatchCode,b.StudentCode,b.FullName,b.TCPCode,b.LearningCenterCode,b.ClassCode,b.SpyCode,b.ProfessionalLevel,b.StudentType,b.StudentCategory,b.OriginalSubject,b.OriginalCategory,b.EnrollmentStatus,b.AdmissionTime,b.CreateTime,b.ExamNo);

commit;


MERGE INTO OUCHNSYS.EAS_SCHROLL_STUDENTBASICINFO A USING
 OUCHNSYS.EAS_SCHROLL_STUDENTBASIC1 B
ON (A.STUDENTID = B.STUDENTID)
WHEN NOT MATCHED THEN 
INSERT (
  STUDENTID, STUDENTCODE, GENDER, ETHNIC, POLITICSSTATUS, 
  MARITALSTATUS, HOMETOWN, BIRTHDATE, EDUCATION, WORKINGTIME, 
  HUKOU, IDNUMBER, DISTRIBUTION, TUITION, ADMISSIONNUMBER, 
  WORKUNITS, WORKADDRESS, WORKZIPCODE, WORKPHONE, MYADDRESS, 
  MYZIPCODE, MYPHONE, EMAIL, DIPLOMANUMBER, PROFESSIONALSITUATION, 
  MOBILE, DOCUMENTTYPE, IDCARD, ORIGINALSPYLEVEL, ORIGINALSPY, 
  ORIGINALGRADUATETIME, ORIGINALGRADUATESCHOOL, CREATETIME)
VALUES (
  B.STUDENTID, B.STUDENTCODE, B.GENDER, B.ETHNIC, B.POLITICSSTATUS, 
  B.MARITALSTATUS, B.HOMETOWN, B.BIRTHDATE, B.EDUCATION, B.WORKINGTIME, 
  B.HUKOU, B.IDNUMBER, B.DISTRIBUTION, B.TUITION, B.ADMISSIONNUMBER, 
  B.WORKUNITS, B.WORKADDRESS, B.WORKZIPCODE, B.WORKPHONE, B.MYADDRESS, 
  B.MYZIPCODE, B.MYPHONE, B.EMAIL, B.DIPLOMANUMBER, B.PROFESSIONALSITUATION, 
  B.MOBILE, B.DOCUMENTTYPE, B.IDCARD, B.ORIGINALSPYLEVEL, B.ORIGINALSPY, 
  B.ORIGINALGRADUATETIME, B.ORIGINALGRADUATESCHOOL, B.CREATETIME);

COMMIT;





--select distinct YZYCCDM from CPS_STUDENTGRADUATE;
with t1 as (
select a.studentcode,a.originalcategory,b.yxkml from eas_schroll_student a inner join cps_studentgraduate b on a.studentcode=B.STUDENTCODE 
)
select * from t1 where studentcode='1433001250301'


update eas_schroll_student set ORIGINALcategory=null,originalsubject=null where exists(select * from cps_studentgraduate where studentcode=eas_schroll_student.studentcode);

merge into eas_schroll_student a 
using cps_studentgraduate b on (a.studentcode=b.studentcode)
when matched then
 update set ORIGINALcategory=substr(b.yxkml,1,2),originalsubject=b.yxkml
 where length(b.yxkml)=4
 --and a.studentcode='1433001250301'

update eas_schroll_studentbasicinfo set ORIGINALSPYLEVEL=null where exists(select * from cps_studentgraduate where studentcode=eas_schroll_studentbasicinfo.studentcode);

merge into eas_schroll_studentbasicinfo a 
using cps_studentgraduate b on (a.studentcode=b.studentcode)
when matched then
 update set ORIGINALSPYLEVEL=b.yzyccdm
 where length(b.yzyccdm)=1 and b.yzyccdm<>'7';

commit;

merge into eas_schroll_studentbasicinfo a 
using cps_studentgraduate b on (a.studentcode=b.studentcode)
when matched then
 update set ORIGINALSPY=b.ylzy,A.ORIGINALGRADUATESCHOOL =b.ybyxx;
 commit;
 /*
with t1 as (select substr(b.ybysj,1,8) as ybysj  from cps_studentgraduate b where length(b.ybysj)>=8 and substr(b.ybysj,1,2)='19')
select ybysj from t1 where is_date(ybysj)=0 


with t1 as (select substr(b.ybysj,3,4)|| '0'||substr(b.ybysj,1,1)||'0'||substr(b.ybysj,2,1) as ybysj  from cps_studentgraduate b where length(b.ybysj)=6 )
select ybysj from t1 where is_date(ybysj)=0 and rownum<10

with t1 as (select substr(b.ybysj,3,4)|| '0'||substr(b.ybysj,1,2) as ybysj  from cps_studentgraduate b where length(b.ybysj)=7 )
select ybysj from t1 where is_date(ybysj)=1 and rownum<10


where to_number(substr(ybysj,5,2),'99')>12 or to_number(substr(ybysj,7,2),'99')>31 

select distinct ybysj,'end' from   cps_studentgraduate 

*/
merge into eas_schroll_studentbasicinfo a 
using( 
with t1 as (select substr(ybysj,1,8) ybysj,studentcode  from cps_studentgraduate b where length(b.ybysj)>=8 and( substr(b.ybysj,1,2)='19' or substr(b.ybysj,1,2)='20'))
select to_date(ybysj,'yyyymmdd') ybysj,studentcode from t1 where is_date(ybysj)=1
) bb 
 on (a.studentcode=bb.studentcode)
when matched then
 update set A.ORIGINALGRADUATETIME=bb.ybysj;
 
 commit;