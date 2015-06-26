--
-- PK_GRAD_AUDIT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_Grad_Audit AS
--更新毕业管理_学生毕业审核表中的申请时预审核状态
    PROCEDURE PR_Grad_UpdateGradCondition(
    isGradPass int,
    isDegreePass int,
    inStudentCode varchar2,
    outCount out int
   )
   is
   x_IsDegree int;--是否申请学位
   x_Result int;
BEGIN
    x_Result := 1;
    select isDegree into x_IsDegree from EAS_Grad_Audit where studentCode = inStudentCode;
    if x_IsDegree >0 then
        if isGradPass =0 then
            x_Result := 0;
        elsif isDegreePass = 0 then
            x_Result := 0;
        end if;
    else
      if isGradPass = 0 then
        x_Result :=0;
      end if;
    end if;
    
    update EAS_Grad_Audit set IsConditionPass = x_Result where studentCode = inStudentCode;
    outCount:=1;
    
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
       outCount :=0;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
    
END PR_Grad_UpdateGradCondition;


--初审名单生成
PROCEDURE PR_Grad_TrailListProcess(
    InSegmentCode varchar2,
    OutCount out int
    )
IS
   mySegmentCode varchar2(100);
   x_FACount int;
BEGIN
    mySegmentCode := InSegmentCode ||'%';
    OutCount := 0;
   --获取学生
   declare
           
    cursor c_job
    is
    select student.studentCode,gradStudent.GradType,gradStudent.AuditGardType,gradStudent.AuditDegrType,orgC.OrganizationCode  as collegeCode,student.learningCenterCode from EAS_SchRoll_Student student inner join EAS_Grad_Student gradStudent on student.studentCode = gradStudent.studentCode
     inner join EAS_Org_BasicInfo orgC on ORGC.PARENTCODE = InSegmentCode and OrganizationType ='3'
     where student.learningCenterCode like mySegmentCode;
    c_row c_job%rowtype;
    begin
      for c_row in c_job loop
      --在初审名单中是否存在
           x_FACount := 0;
           select count(1) into x_FACount from EAS_Grad_FirstAudit where StudentCode = c_row.studentCode;
         if c_row.AuditGardType =1 then
           if x_FACount = 0 then
             insert into 
             EAS_Grad_FirstAudit (studentCode,segmentCode,CollageCode,LearningCenterCode,MaintainDate)
             values
             (c_row.studentCode,InSegmentCode,c_row.collegecode,c_row.learningCenterCode,sysdate);
           end if;
         else
           if x_FACount != 0 then
             delete from EAS_Grad_FirstAudit where studentCode = c_row.studentCode;
           end if;
         end if;
         outCount := outCount +1;
      end loop;
    end;
   
END PR_Grad_TrailListProcess;

--单个学生初审名单生成
PROCEDURE PR_Grad_TrailListWithAStudent(
    InStudentCode varchar2,
    OutCount out int
    )
    IS
    x_FACount int;
    Begin
        OutCount := 0;
   --获取学生
   declare
    cursor c_job
    is
    select student.studentCode,gradStudent.GradType,gradStudent.AuditGardType,gradStudent.AuditDegrType,orgC.parentCode as segmentCode,orgL.parentCode  as collegeCode,student.learningCenterCode from EAS_SchRoll_Student student inner join EAS_Grad_Student gradStudent on student.studentCode = gradStudent.studentCode 
     inner join EAS_Org_BasicInfo orgL on ORGL.OrganizationCode = student.LearningCenterCode
     inner join EAS_Org_BasicInfo orgC on ORGC.OrganizationCode = orgL.parentCode
     where student.studentCode = InStudentCode;
    c_row c_job%rowtype;
    begin
      for c_row in c_job loop
      --在初审名单中是否存在
           x_FACount := 0;
           select count(1) into x_FACount from EAS_Grad_FirstAudit where StudentCode = c_row.studentCode;
         if c_row.AuditGardType =1 then
           if x_FACount = 0 then
             insert into 
             EAS_Grad_FirstAudit (studentCode,segmentCode,CollageCode,LearningCenterCode,MaintainDate)
             values
             (c_row.studentCode,c_row.segmentCode,c_row.collegecode,c_row.learningCenterCode,sysdate);
           end if;
         else
           if x_FACount != 0 then
             delete from EAS_Grad_FirstAudit where studentCode = c_row.studentCode;
           end if;
         end if;
         outCount := outCount +1;
      end loop;
    end;
    
    End PR_Grad_TrailListWithAStudent;

END PK_Grad_Audit;
/

