--
-- PR_TCP_ADD_SEGMSEMECOURSBYTERM  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_TCP_Add_SegmSemeCoursByTerm(
v_orgCode in varchar,--机构 
v_yearTerm in varchar--学期
) IS

vv_orgCode varchar(15) :=v_orgCode;
vv_yearTerm varchar(20) :=v_yearTerm;
/******************************************************************************
   NAME:       Pr_AddSegmSemeCourseByYearTerm
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/4/1   liufengshuan       1. Created this procedure.

   NOTES:分部学期开设课程管理----按学期开设
******************************************************************************/
BEGIN

insert into EAS_TCP_SegmSemeCourses(SN,YearTerm,OrgCode,CourseID,Semester,IsExistTCP,CreateTime )
select sys_guid() SN,TPBatchCode YearTerm,TPOrgCode,TPCourseID,1 Semester,tisExistTcp ,sysdate CreateTime from (

    select vti.BatchCode TPBatchCode,vti.OrgCode TPOrgCode,vti.CourseID TPCourseID,vti.IsExistTCP tisExistTcp ,vti.OpenedSemester TPOpenedSemester
     from V_TCP_IMPLCOURSE vti
     right join EAS_TCP_SegmentCourses ets on vti.OrgCode=ets.orgCode AND vti.CourseID=ets.CourseID and ets.courseState=1
     where vti.OrgCode = vv_orgCode
    union
    --取停用课程的互斥课
    select TPBatchCode,TPOrgCode,ecmc.NewCourseCode TPCourseID,tisExistTcp ,TPOpenedSemester from (
        select vti.BatchCode TPBatchCode,vti.OrgCode TPOrgCode,vti.CourseID TPCourseID,vti.IsExistTCP tisExistTcp,vti.OpenedSemester TPOpenedSemester
         from V_TCP_IMPLCOURSE vti
         right join EAS_TCP_SegmentCourses ets on vti.OrgCode=ets.orgCode AND vti.CourseID=ets.CourseID and ets.courseState=0--课程状态停用
         left join EAS_TCP_ModuleCourses etmc on vti.orgcode=etmc.orgcode and vti.courseId=etmc.courseID and vti.batchcode=etmc.batchcode and vti.tcpcode=etmc.tcpcode
         where (etmc.COURSENATURE=1 or etmc.coursenature=2) and vti.OrgCode = vv_orgCode
    )tp
    left join EAS_Course_MutexCourses ecmc on tp.TpCourseID=ecmc.oldCourseCode
    
 )tp
join  (
    select  BATCHCODE, rownum num   from EAS_TCP_RECRUITBATCH a
    where BATCHCODE<=vv_yearTerm  
    and rownum<=4
    order by BATCHCODE desc
)TB on tp.TPBatchCode=TB.batchcode and tp.TPOpenedSemester=TB.num
where 1=1
and not exists(
SELECT 1 
 FROM EAS_TCP_SegmSemeCourses
 where CourseID=TPCourseID AND OrgCode=TPorgCode AND YearTerm=TPBatchCode
);

END Pr_TCP_Add_SegmSemeCoursByTerm;
/

