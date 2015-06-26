--
-- PR_TCP_MODIFY_EXECUTIONSTATE_T  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_TCP_Modify_ExecutionState_T(
inSN in varchar2,--ִ����רҵ����ID
inTCPCode in varchar2,--רҵ�������
inUserID in varchar2,--�޸���ID
inLearningCenterCode in varchar2,--ѧϰ��ѧ����
OutException out varchar2--�����쳣��Ϣ
)
AS
D_SegOrgCode  varchar2(50);--�ֲ�����
/******************************************************************************
   NAME:
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/3/27   changshiqiang       1. Created this procedure.

   NOTES:ִ����רҵ�������õ��ã�ִ����רҵ��������

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

    --�޸�ִ����רҵ��������״̬
    UPDATE EAS_TCP_Execution
    SET 
    ExcState=1,
    Executor=inUserID,
    ExecuteTime=to_char(sysdate, 'hh24:mi:ss')
    WHERE SN=inSN;
    
    --��ȡ�ֲ�����
    SELECT SegmentCode into D_SegOrgCode FROM EAS_TCP_Execution where SN=inSN;
    
    --��(רҵ�������_���޿γ̱�)��ӵ�(רҵ�������_ѧϰ���Ŀγ��ܱ�)
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
    WHERE TCPCode=inTCPCode--רҵ��������ͬ
    AND NOT exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);
    
    --��(רҵ�������_ִ���Խ�ѧ�ƻ�ģ��γ�)��ӵ�(רҵ�������_ѧϰ���Ŀγ��ܱ�)
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
    WHERE TCPCode=inTCPCode--רҵ��������ͬ
    AND ETMC.LEARNINGCENTERCODE=inLearningCenterCode--ѧϰ���ı�������
    AND not exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);  
    
    --��(רҵ�������_ʵʩ�Խ�ѧ��ģ��γ�)��ӵ�(רҵ�������_ѧϰ���Ŀγ��ܱ�)
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
    WHERE CourseNature=2 --�γ�����Ϊ���޿�
    and TCPCode=inTCPCode--רҵ��������ͬ
    and ETMC.SEGMENTCODE=D_SegOrgCode--�ֲ�����
    and not exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);
    
    --��(רҵ�������_��ѧ�ƻ�ģ��γ�)��ӵ�(רҵ�������_ѧϰ���Ŀγ��ܱ�)
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
    WHERE CourseNature=1 --�γ�����Ϊ���޿�
    and TCPCode=inTCPCode--רҵ��������ͬ
    and not exists (select CourseID from EAS_TCP_LearCentCourse where LearningCenterCode=inLearningCenterCode);
    
    END;
    
    --��������쳣���ع�����
    exception when others then
    begin
    OutException:=sqlerrm;
        rollback;
    end;
    OutException:='ִ�гɹ�';
    commit;
END PR_TCP_Modify_ExecutionState_T;
/

