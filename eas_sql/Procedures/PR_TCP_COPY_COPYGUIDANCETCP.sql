--
-- PR_TCP_COPY_COPYGUIDANCETCP  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.Pr_TCP_Copy_CopyGuidanceTCP
(
     i_BatchCode in EAS_TCP_GUIDANCE.BatchCode%type,--年度学期
     returnCode out varchar2
)
 IS

v_prevBatchCode EAS_TCP_RECRUITBATCH.BATCHCODE%type;--目标学期的上一年度学期

/******************************************************************************
   NAME:       Pr_GuidanceCopyTCP
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/4/17   Administrator       1. Created this procedure.

   NOTES:指导性专业规则管理--复制专业规则
   
******************************************************************************/
BEGIN

--1.目标学期的上一年度学期
    select BatchCode into v_prevBatchCode from EAS_TCP_RECRUITBATCH Batch
    where Batch.BATCHCODE<i_BatchCode  and rownum<2
    order by Batch.BATCHCODE desc;
    
    dbms_output.put_line(i_BatchCode||'查出结果为:年度学期=' ||i_BatchCode );

   if v_prevBatchCode is not null and length(v_prevBatchCode)>0 then
   
     returnCode:='1';
     
     ---2. 复制 EAS_TCP_Guidance
        insert into EAS_TCP_Guidance
        (
               TCPCode,BatchCode,TCPName,EducationType,StudentType,ProfessionalLevel
              ,SpyCode,MinGradCredits,MinExamCredits,ExemptionMaxCredits,SchoolSystem
              ,DegreeCollegeID,DegreeSemester,Remark,State,CopySourceCode,Creator,CreateTime
              --,EnableUser,EnableTime
        )
        select    
            fn_GetTCPCode(i_BatchCode, g.studenttype, g.professionallevel,g.spycode) tcpcodenew,
            i_BatchCode BatchCode,
            --g.BatchCode,
            (select RECRUITBATCHName from EAS_TCP_RECRUITBATCH where batchcode=i_BatchCode)||
            (select dicname  from EAS_Dic_StudentType where diccode=g.studenttype )||
            (select dicname from EAS_Dic_ProfessionalLevel where diccode=g.professionallevel)||
            (select spyname from EAS_Spy_BasicInfo where spycode=g.spycode) tcpnamenew
            --,g.TCPCode
            --,g.TCPName
            ,g.EducationType,g.StudentType,g.ProfessionalLevel,g.SpyCode
            ,g.MinGradCredits,g.MinExamCredits,g.ExemptionMaxCredits,g.SchoolSystem
            ,g.DegreeCollegeID,g.DegreeSemester,g.Remark
            ,0 State
            ,v_prevBatchCode CopySourceCode
            ,g.Creator
            ,sysdate CreateTime
            --,g.EnableUser
            --,g.EnableTime 
        from EAS_TCP_Guidance  g
                --目标学期的上一个学期
        where g.batchcode=v_prevBatchCode
        and not exists(
            select 1 from EAS_TCP_Guidance where batchcode=i_BatchCode 
            and studenttype=g.studenttype and professionallevel=g.professionallevel 
            and spycode=g.spycode
        );
        
          dbms_output.put_line('EAS_TCP_Guidance' ||  SQL%ROWCOUNT);
   
        
    --3.复制EAS_TCP_GuidanceOnRule
        insert into EAS_TCP_GuidanceOnRule
         ( SN,BatchCode,TCPCode,TotalCredits,ModuleTotalCredits,RequiredTotalCredits)
        select
            seq_TCP_GuidOnRule.nextval SN,
            --目标学期
            i_BatchCode BatchCode,
            fn_GetTCPCode(i_BatchCode, etg.studenttype, etg.professionallevel,etg.spycode) tcpcodenew, 
            --etgr.TCPCode,
            etgr.TotalCredits,
            etgr.ModuleTotalCredits,
            etgr.RequiredTotalCredits
         from EAS_TCP_GuidanceOnRule etgr
         inner join EAS_TCP_Guidance etg on etgr.tcpcode=etg.tcpcode
                --目标学期的上一个学期
        where etgr.Batchcode=v_prevBatchCode
            and not exists(
                select 1 from EAS_TCP_GuidanceOnRule where batchcode=i_BatchCode    and tcpcode=etg.tcpcode
            );
            
                dbms_output.put_line('EAS_TCP_GuidanceOnRule' ||  SQL%ROWCOUNT);
            
    ---4. 复制EAS_TCP_Module
        insert into EAS_TCP_Module
         ( SN,BatchCode,TCPCode,ModuleCode,MinGradCredits,MinExamCredits,CreateTime )
        select
            sys_guid() SN,
            --目标学期
            i_BatchCode BatchCode,
            fn_GetTCPCode(i_BatchCode, etg.studenttype, etg.professionallevel,etg.spycode) tcpcodenew, 
            --etm.tcpcode,
            etm.ModuleCode,
            etm.MinGradCredits,
            etm.MinExamCredits,
            sysdate CreateTime
            
         from EAS_TCP_Module etm
        left join EAS_TCP_Guidance etg on etm.tcpcode=etg.tcpcode
                --目标学期的上一个学期
        where etm.Batchcode=v_prevBatchCode
        and not exists(
            select 1 from EAS_TCP_Module where batchcode=i_BatchCode and tcpcode=etg.tcpcode
        );
        
            dbms_output.put_line('EAS_TCP_Module' ||  SQL%ROWCOUNT);

    --5. EAS_TCP_ModuleCourses
        insert into EAS_TCP_ModuleCourses
         ( SN,ModuleCode,BatchCode,TCPCode,CourseID,CourseName,CourseNature,Credit,OrgCode,OpenedSemester,ExamUnitType,IsExtendedCourse,IsDegreeCourse,IsSimilar,CreateTime )
        select
            sys_guid() SN,
            etmc.ModuleCode,
            --目标学期
            i_BatchCode BatchCode,
            --etmc.BatchCode,
            fn_GetTCPCode(i_BatchCode, etg.studenttype, etg.professionallevel,etg.spycode) tcpcodenew,
            etmc.CourseID,
            etmc.CourseName,
            etmc.CourseNature,
            etmc.Credit,
            etmc.OrgCode,
            etmc.OpenedSemester,
            etmc.ExamUnitType,
            etmc.IsExtendedCourse,
            etmc.IsDegreeCourse,
            etmc.IsSimilar,
            sysdate CreateTime
            
         from EAS_TCP_ModuleCourses etmc
        left join EAS_TCP_Guidance etg on etmc.tcpcode=etg.tcpcode
        --目标学期的上一个学期
        where etmc.Batchcode=v_prevBatchCode
        and not exists(
            select 1 from EAS_TCP_ModuleCourses where batchcode=i_BatchCode and tcpcode=etg.tcpcode
        );
        
            dbms_output.put_line('EAS_TCP_ModuleCourses' ||  SQL%ROWCOUNT);
        
        
      --6. 复制 EAS_TCP_GuidanceOnModuleRule
        insert into EAS_TCP_GuidanceOnModuleRule
         ( OnRuleID,BatchCode,TCPCode,ModuleCode,TotalCredits,RequiredTotalCredits,CenterCompulsoryCourseCredit,SegmentCompulsoryCourseCredit )
        select
           seq_TCP_GuidModuRule.nextval OnRuleID,
            --目标学期
            i_BatchCode BatchCode,
           fn_GetTCPCode(i_BatchCode, etg.studenttype, etg.professionallevel,etg.spycode) tcpcodenew,
            etgm.ModuleCode,
            etgm.TotalCredits,
            etgm.RequiredTotalCredits,
            etgm.CenterCompulsoryCourseCredit,
            etgm.SegmentCompulsoryCourseCredit
            
         from EAS_TCP_GuidanceOnModuleRule etgm
        left join EAS_TCP_Guidance etg on etgm.tcpcode=etg.tcpcode
                --目标学期的上一个学期
        where etgm.Batchcode=v_prevBatchCode   
        and not exists(
            select 1 from EAS_TCP_GuidanceOnModuleRule where batchcode=i_BatchCode and tcpcode=etg.tcpcode
        );
        
            dbms_output.put_line('EAS_TCP_GuidanceOnModuleRule' ||  SQL%ROWCOUNT);


    --7.相似课 EAS_TCP_SimilarCourses
        insert into EAS_TCP_SimilarCourses
         ( SN,BatchCode,TCPCode,ModuleCode,CourseID,SimilarGroup,CreateTime )
        select
            seq_TCP_SimilarCourses.nextval SN,
            --目标学期
            i_BatchCode BatchCode,
            fn_GetTCPCode(i_BatchCode, etg.studenttype, etg.professionallevel,etg.spycode) tcpcodenew,
            etsc.ModuleCode,
            etsc.CourseID,
            etsc.SimilarGroup,
            sysdate CreateTime
            
         from EAS_TCP_SimilarCourses etsc
        left join EAS_TCP_Guidance etg on etsc.tcpcode=etg.tcpcode
        --目标学期的上一个学期
        where etsc.Batchcode=v_prevBatchCode    
        and not exists(
                select 1 from EAS_TCP_SimilarCourses where batchcode=i_BatchCode and tcpcode=etg.tcpcode
            );
            
        dbms_output.put_line('EAS_TCP_SimilarCourses' ||  SQL%ROWCOUNT);   
    
     --8.补修课   
       insert into EAS_TCP_ConversionCourse
         ( SN,BatchCode,TCPCode,CourseID,SuggestOpenSemester,ExamunitType,CreateTime )
        select
            sys_guid() SN,
            --目标学期
            i_BatchCode BatchCode,
            fn_GetTCPCode(i_BatchCode, etg.studenttype, etg.professionallevel,etg.spycode) tcpcodenew,
            etcc.CourseID,
            etcc.SuggestOpenSemester,
            etcc.ExamunitType,
            sysdate CreateTime
         from EAS_TCP_ConversionCourse etcc
        left join EAS_TCP_Guidance etg on etcc.tcpcode=etg.tcpcode
        --目标学期的上一个学期
        where etcc.Batchcode=v_prevBatchCode    
        and not exists(
                select 1 from EAS_TCP_ConversionCourse where batchcode=i_BatchCode and tcpcode=etg.tcpcode
            );
    
    dbms_output.put_line('EAS_TCP_ConversionCourse' ||  SQL%ROWCOUNT);
    
    
    
    
    end if;
    
  EXCEPTION

     WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE(SQLCODE||'---'||SQLERRM);
     returnCode:='0';
        rollback;

END Pr_TCP_Copy_CopyGuidanceTCP;
/

