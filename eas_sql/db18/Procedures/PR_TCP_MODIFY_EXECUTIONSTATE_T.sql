--
-- PR_TCP_MODIFY_EXECUTIONSTATE_T  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_TCP_Modify_ExecutionState_T(
inSN in varchar2,--执行性专业规则ID
inTCPCode in varchar2,--专业规则编码
inUserID in varchar2,--修改人ID
inLearningCenterCode in varchar2,--学习中学编码
OutException out varchar2--返回异常信息
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

    --修改执行型专业规则启用状态
    UPDATE EAS_TCP_Execution
    SET 
    ExcState=1,
    Executor=inUserID,
    ExecuteTime=to_char(sysdate, 'hh24:mi:ss')
    WHERE SN=inSN;
    
    --获取分部编码
    SELECT SegmentCode into D_SegOrgCode FROM EAS_TCP_Execution where SN=inSN;
    
    --将(专业规则管理_补修课程表)添加到(专业规则管理_学习中心课程总表)
    INSERT INTO EAS_TCP_LearCentCourse
        ( SN,
          SegOrgCode ,
          LearningCenterCode ,
          CourseID ,
          CourseState ,
          CreateTime
        )
    SELECT 
        seq_TCP_LearCentCour.nextval ,
        D_SegOrgCode , -- SegOrgCode - nvarchar(4)
        inLearningCenterCode , -- LearningCenterCode - nvarchar(15)
        etmc.CourseID,
        ecbi.State,
        to_char(sysdate, 'hh24:mi:ss') 
    FROM EAS_TCP_ConversionCourse etmc
    INNER JOIN EAS_Course_BasicInfo ecbi ON etmc.CourseID = ecbi.CourseID 
    WHERE TCPCode=inTCPCode--专业规则编号相同
    AND NOT exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);
    
    --将(专业规则管理_执行性教学计划模块课程)添加到(专业规则管理_学习中心课程总表)
    INSERT INTO EAS_TCP_LearCentCourse
        ( SN,
        SegOrgCode ,
        LearningCenterCode ,
        CourseID ,
        CourseState ,
        CreateTime
        )
    SELECT
        seq_TCP_LearCentCour.nextval ,
        D_SegOrgCode , -- SegOrgCode - nvarchar(4)
        inLearningCenterCode , -- LearningCenterCode - nvarchar(15)
        etmc.CourseID , -- CourseID - nvarchar(5)
        ecbi.State , -- CourseState - tinyint
        to_char(sysdate, 'hh24:mi:ss')  -- CreateTime - datetime
    FROM EAS_TCP_ExecModuleCourse etmc
    INNER JOIN EAS_Course_BasicInfo ecbi ON etmc.CourseID = ecbi.CourseID 
    WHERE TCPCode=inTCPCode--专业规则编号相同
    AND ETMC.LEARNINGCENTERCODE=inLearningCenterCode--学习中心编码条件
    AND not exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);  
    
    --将(专业规则管理_实施性教学计模块课程)添加到(专业规则管理_学习中心课程总表)
    INSERT INTO EAS_TCP_LearCentCourse
        ( SN,
        SegOrgCode ,
        LearningCenterCode ,
        CourseID ,
        CourseState ,
        CreateTime
        )
    SELECT  
    seq_TCP_LearCentCour.nextval ,
    D_SegOrgCode , -- SegOrgCode - nvarchar(4)
    inLearningCenterCode , -- LearningCenterCode - nvarchar(15)
    etmc.CourseID , -- CourseID - nvarchar(5)
    ecbi.State , -- CourseState - tinyint
    to_char(sysdate, 'hh24:mi:ss')  -- CreateTime - datetime
    FROM EAS_TCP_ImplModuleCourse etmc
    INNER JOIN EAS_Course_BasicInfo ecbi ON etmc.CourseID = ecbi.CourseID 
    WHERE CourseNature=2 --课程性质为必修课
    and TCPCode=inTCPCode--专业规则编号相同
    and ETMC.SEGMENTCODE=D_SegOrgCode--分部条件
    and not exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);
    
    --将(专业规则管理_教学计划模块课程)添加到(专业规则管理_学习中心课程总表)
    INSERT INTO EAS_TCP_LearCentCourse
        ( SN,
        SegOrgCode ,
        LearningCenterCode ,
        CourseID ,
        CourseState ,
        CreateTime
        )
    SELECT  
    seq_TCP_LearCentCour.nextval ,
    D_SegOrgCode , -- SegOrgCode - nvarchar(4)
    inLearningCenterCode , -- LearningCenterCode - nvarchar(15)
    etmc.CourseID , -- CourseID - nvarchar(5)
    ecbi.State , -- CourseState - tinyint
    to_char(sysdate, 'hh24:mi:ss')  -- CreateTime - datetime
    FROM EAS_TCP_ModuleCourses etmc
    INNER JOIN EAS_Course_BasicInfo ecbi ON etmc.CourseID = ecbi.CourseID 
    WHERE CourseNature=1 --课程性质为必修课
    and TCPCode=inTCPCode--专业规则编号相同
    and not exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);
    
    END;
    
    --如果存在异常，回滚数据
    exception when others then
    begin
    OutException:=sqlerrm;
        rollback;
    end;
    OutException:='执行成功';
    commit;
END PR_TCP_Modify_ExecutionState_T;
/

