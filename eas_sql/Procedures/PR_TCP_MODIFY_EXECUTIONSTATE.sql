--
-- PR_TCP_MODIFY_EXECUTIONSTATE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_TCP_Modify_ExecutionState(
inSN in varchar2,--执行性专业规则ID
inTCPCode in varchar2,--专业规则编码
inUserID in varchar2,--修改人ID
inLearningCenterCode in varchar2--学习中学编码
)
AS
D_SegOrgCode  varchar2(50);--分部编码
/******************************************************************************
   NAME:
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/3/27   changshiqiang       1. Created this procedure.

   NOTES:执行性专业规则启用调用，执行性专业规则启用

   Automatically available Auto Replace Keywords:
      Object Name:     AddEAS_TCP_ModuleCourses
      Sysdate:         2014/3/26
      Date and Time:   2014/3/26, 9:58:33, and 2014/3/27 9:58:33
      Username:        changshiqiang (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN    
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;   
begin
    UPDATE EAS_TCP_Execution
    SET 
    ExcState=1,
    Executor=inUserID,
    ExecuteTime=to_char(sysdate, 'hh24:mi:ss')
    WHERE SN=inSN;
    
    SELECT SegmentCode into D_SegOrgCode FROM EAS_TCP_Execution where SN=inSN;
    
    PR_TCP_ADD_ConversionCourse(INTCPCODE,D_SegOrgCode,INLEARNINGCENTERCODE);--执行存储过程：执行性专业规则启用调用，将(专业规则管理_执行性教学计划模块课程)添加到(专业规则管理_学习中心课程总表)
    PR_TCP_ADD_ExecModuleCourse(INTCPCODE,D_SegOrgCode,INLEARNINGCENTERCODE);--执行存储过程：执行性专业规则启用调用，将(专业规则管理_执行性教学计划模块课程)添加到(专业规则管理_学习中心课程总表)
    PR_TCP_ADD_ImplModuleCourse(INTCPCODE,D_SegOrgCode,INLEARNINGCENTERCODE);--执行存储过程：执行性专业规则启用调用，将(专业规则管理_实施性教学计模块课程)添加到(专业规则管理_学习中心课程总表)
    PR_TCP_ADD_ModuleCourses(INTCPCODE,D_SegOrgCode,INLEARNINGCENTERCODE);--执行存储过程：执行性专业规则启用调用，将(专业规则管理_教学计划模块课程)添加到(专业规则管理_学习中心课程总表)
    end;
    
    --如果存在异常，回滚数据
    exception when others then
    begin
        rollback;
    end;
    
    commit;
END PR_TCP_Modify_ExecutionState;
/

