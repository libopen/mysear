--
-- PROCALMODULETOTALCREDIT  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.ProCalModuleTotalCredit
(
    InGradStudentSN number,
    InStudentCode varchar2,
    InSegmentCode varchar2,
    InLearningCenterCode varchar2,
    InTcpCode varchar2,
    InAuditor varchar2
)
IS
cursor c_job
    is 
    select allModule.*,
      case when exists
      (
        select 1 from EAS_TCP_Module@ouchnbase where batchCode = allModule.batchCode and moduleCode=allModule.moduleCode and allModule.allCredit >= MinGradCredits)
      then 1 else 0 end as isPass
    from (
        select moduleCode,batchCode, Sum(credit) as allCredit,sum(case when courseNature = '1' then  Credit end )as orgCredit
        from table(PK_TCP.FN_TCP_GetExecModuleCourses(InTcpCode,InSegmentCode,InLearningCenterCode)) allCourse 
    where exists(select 1 from EAS_Elc_StudentStudyStatus where studentCode = InStudentCode and CourseID = allCourse.CourseID and StudyStatus = '4') group by moduleCode,batchCode
    ) allModule;
    
    c_row c_job%rowtype;
    
    isModuleCreditExist int;
BEGIN
   --保存学生的模块课程
   for c_row in c_job loop
      --判断模块汇总表中是否已经存在
      isModuleCreditExist :=0;
      select count(1) into isModuleCreditExist from EAS_Grad_ModuleCondition@ouchnbase where studentCode = InStudentCode and moduleCode = c_row.moduleCode;
      if isModuleCreditExist > 0 then
        update EAS_Grad_ModuleCondition@ouchnbase set ModuleTotalCredits = c_row.allCredit, RequiredTotalCredits  = c_row.orgCredit where studentCode = InStudentCode and moduleCode = c_row.moduleCode;
      else
        insert into EAS_Grad_ModuleCondition@ouchnbase(SN,StudentCode,ModuleCode,ModuleTotalCredits,RequiredTotalCredits,IsPass,Auditor,AuditDate)
        values
        (InGradStudentSN,InStudentCode,c_row.ModuleCode,c_row.allCredit,c_row.orgCredit,c_row.isPass,InAuditor,sysdate);
      end if; 
   end loop;
   close c_job;
   
END ProCalModuleTotalCredit;
/

