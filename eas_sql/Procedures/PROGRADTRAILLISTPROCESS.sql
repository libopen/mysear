--
-- PROGRADTRAILLISTPROCESS  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.ProGradTrailListProcess(
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
      end loop;
    end;
   outCount := 1;
END ProGradTrailListProcess;
/

