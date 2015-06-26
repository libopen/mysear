--
-- PR_TCP_MODIFY_EXECUTIONSTATE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_TCP_Modify_ExecutionState(
inSN in varchar2,--ִ����רҵ����ID
inTCPCode in varchar2,--רҵ�������
inUserID in varchar2,--�޸���ID
inLearningCenterCode in varchar2--ѧϰ��ѧ����
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
    UPDATE EAS_TCP_Execution
    SET 
    ExcState=1,
    Executor=inUserID,
    ExecuteTime=to_char(sysdate, 'hh24:mi:ss')
    WHERE SN=inSN;
    
    SELECT SegmentCode into D_SegOrgCode FROM EAS_TCP_Execution where SN=inSN;
    
    PR_TCP_ADD_ConversionCourse(INTCPCODE,D_SegOrgCode,INLEARNINGCENTERCODE);--ִ�д洢���̣�ִ����רҵ�������õ��ã���(רҵ�������_ִ���Խ�ѧ�ƻ�ģ��γ�)��ӵ�(רҵ�������_ѧϰ���Ŀγ��ܱ�)
    PR_TCP_ADD_ExecModuleCourse(INTCPCODE,D_SegOrgCode,INLEARNINGCENTERCODE);--ִ�д洢���̣�ִ����רҵ�������õ��ã���(רҵ�������_ִ���Խ�ѧ�ƻ�ģ��γ�)��ӵ�(רҵ�������_ѧϰ���Ŀγ��ܱ�)
    PR_TCP_ADD_ImplModuleCourse(INTCPCODE,D_SegOrgCode,INLEARNINGCENTERCODE);--ִ�д洢���̣�ִ����רҵ�������õ��ã���(רҵ�������_ʵʩ�Խ�ѧ��ģ��γ�)��ӵ�(רҵ�������_ѧϰ���Ŀγ��ܱ�)
    PR_TCP_ADD_ModuleCourses(INTCPCODE,D_SegOrgCode,INLEARNINGCENTERCODE);--ִ�д洢���̣�ִ����רҵ�������õ��ã���(רҵ�������_��ѧ�ƻ�ģ��γ�)��ӵ�(רҵ�������_ѧϰ���Ŀγ��ܱ�)
    end;
    
    --��������쳣���ع�����
    exception when others then
    begin
        rollback;
    end;
    
    commit;
END PR_TCP_Modify_ExecutionState;
/

