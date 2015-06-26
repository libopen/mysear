--
-- PR_COPYSEMESTEROPENCOURSES  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_CopySemesterOpenCourses(
i_orgCode in varchar,
i_frombatchcode in varchar,
i_targetBatchcode in varchar
) IS

/******************************************************************************
   NAME:       Pr_CopySemesterOpenCourses
   PURPOSE:    
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/4/9   liufengshuan       1. Created this procedure.

   NOTES:����ѡ�����ѧ�ڷֲ��γ̵�ָ����ѧ��
   
******************************************************************************/
BEGIN

/*
--A.�ֲ��γ��ܱ�
     select * from EAS_TCP_SegmentCourses etsc ;
--B. Դ����
SELECT    T.* FROM EAS_TCP_SegmentSemesterCourses T  WHERE 1=1  AND T.OrgCode='120'  AND T.YearTerm='200903';--Դ���ѧ��
--C. ָ����ģ��γ�
select * from EAS_TCP_ModuleCourses;
--D.ʵʩ��ģ��γ�
select * from EAS_TCP_ImplModuleCourse;

--fff.��ͼ �γ����
select * from V_TCP_IMPLCOURSE;
*/



---------------�������
 INSERT INTO EAS_TCP_SegmSemeCourses 
 (  
  SN,
  YearTerm,  
  OrgCode,  
  CourseID,  
  Semester,  
  IsExistTCP,  
  CreateTime  
 )

select sys_guid() SN, i_targetBatchcode pYearTerm,porgCode,pCourseID,pSemester,
(case pisexisttcp when 0 then (select case when count(*)>0 then 1 else 0 end from V_TCP_IMPLCOURSE v
    where 1=1 AND v.OrgCode = i_orgCode  AND v.CourseID =pcourseID  
 and v.batchcode>=i_frombatchcode--'200803' 
 and v.batchcode<=i_targetBatchcode--'200909'
) else pisexisttcp end) isExistTCP1,sysdate CreateTime
from (
    --��һ����
  SELECT  T.YEARTERM PYEARTERM,T.ORGCODE PORGCODE,T.COURSEID PCOURSEID,T.SEMESTER PSEMESTER,T.ISEXISTTCP PISEXISTTCP FROM EAS_TCP_SegmSemeCourses T 
    left join  EAS_TCP_SegmentCourses etsc on t.orgcode=etsc.orgcode and t.courseID=etsc.courseID
    WHERE etsc.coursestate=1  AND T.OrgCode=i_orgCode  AND T.YearTerm=i_frombatchcode--'200903'--Դ���ѧ��
  union 
    --- �ڶ����ֻ���Դ����
  select TYEARTERM PYEARTERM,TORGCODE PORGCODE,ecmc.NewCourseCode PCOURSEID,TSEMESTER PSEMESTER,TISEXISTTCP PISEXISTTCP from (
        --1.
        SELECT T.YEARTERM TYEARTERM,T.ORGCODE TORGCODE,T.COURSEID TCOURSEID,T.SEMESTER TSEMESTER,T.ISEXISTTCP TISEXISTTCP   FROM EAS_TCP_SegmSemeCourses T 
            inner join  EAS_TCP_SegmentCourses etsc on t.orgcode=etsc.orgcode and t.courseID=etsc.courseID
            inner join EAS_TCP_ModuleCourses etmc on t.orgcode=etmc.orgcode and t.courseid=etmc.courseid and t.yearTerm=etmc.batchcode
            WHERE 1=1  AND T.OrgCode=i_orgCode  AND T.YearTerm=i_frombatchcode--'200903'--Դ���ѧ�� 
            and etsc.coursestate=0 and etmc.courseNature=1
        union
            --2
            SELECT  T.YEARTERM TYEARTERM,T.ORGCODE TORGCODE,T.COURSEID TCOURSEID,T.SEMESTER TSEMESTER,T.ISEXISTTCP TISEXISTTCP  FROM EAS_TCP_SegmSemeCourses T 
            inner join  EAS_TCP_SegmentCourses etsc on t.orgcode=etsc.orgcode and t.courseID=etsc.courseID
            inner join EAS_TCP_ImplModuleCourse etimc on t.orgcode=etimc.segmentcode and t.courseid=etimc.courseid and t.yearTerm=etimc.batchcode
            WHERE 1=1  AND T.OrgCode=i_orgCode  AND T.YearTerm=i_frombatchcode--'200903'--Դ���ѧ�� 
            and etsc.coursestate=0 and etimc.courseNature=2
    ) tp
    left join EAS_Course_MutexCourses ecmc on tp.TCourseID=ecmc.oldCourseCode
)p;
   
   
--   EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--       NULL;
--     WHEN OTHERS THEN
--       -- Consider logging the error and then re-raise
--       RAISE;
END Pr_CopySemesterOpenCourses;
/

