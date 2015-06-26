--
-- PK_TCP  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_TCP AS
/******************************************************************************
   NAME:       PK_TCP
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/06/03      libin       1. Created this package.
******************************************************************************/

 -- ָ����רҵ�������������ж�
  PROCEDURE PR_TCP_GUIDANCEENABLE(TCPCODE IN varchar2,RETCODE OUT varchar2);
  -- ָ����רҵ�����������������ж�
  FUNCTION  FN_TCP_GUIDANCEENABLE(TCPCODELIST in varchar2) RETURN str_split PIPELINED;
  --ʵʩ��רҵ�������������ж�
  PROCEDURE PR_TCP_IMPLENABLE(ORGCODE IN varchar2,TCPCODE IN varchar2,RETCODE OUT varchar2);
  -- ʵʩ��רҵ�����������������ж�
  FUNCTION  FN_TCP_IMPLENABLE(ORGCODE IN varchar2,TCPCODELIST in varchar2) RETURN str_split PIPELINED;
  -- ִ����רҵ�������������ж�
   PROCEDURE PR_TCP_EXECENABLE(ORGCODE IN varchar2, LEARNINGCENTERCODE IN varchar2,TCPCODE IN varchar2,RETCODE OUT varchar2);
   -- ִ����רҵ�����������������ж�
   FUNCTION  FN_TCP_EXECENABLE(ORGCODE IN varchar2,LEARNINGCENTERCODE IN varchar2,TCPCODELIST in varchar2) RETURN str_split PIPELINED;
   -- ����һ��������ָ����רҵ����
    PROCEDURE PR_TCP_ENABLEDGUIDANCE(TCPCODE in EAS_TCP_GUIDANCE.TCPCODE%type,ENABLEUSER in  EAS_TCP_GUIDANCE.EnableUser%type,RETCODE OUT varchar2);
    -- ��������ָ����רҵ����
    PROCEDURE PR_TCP_BATCHENABLEDGUIDANCE(TCPCODELIST in varchar2,ENABLEUSER in  EAS_TCP_GUIDANCE.EnableUser%type,RETCODE OUT varchar2);
    -- ����ɾ��ָ����רҵ����
    PROCEDURE PR_TCP_DELETEGUIDANCETCP(I_TCPCODE IN EAS_TCP_GUIDANCE.TCPCODE%TYPE,RETCODE OUT varchar2);
    --����ɾ��ָ����רҵ����
    PROCEDURE PR_TCP_BATCHDELETEGUIDANCETCP(TCPCODELIST in varchar2,RETCODE OUT varchar2);
   -- ����һ��������ʵʩ��רҵ����
    PROCEDURE PR_TCP_ENABLEDIMPL(ORGCODE IN varchar2,TCPCODE in EAS_TCP_GUIDANCE.TCPCODE%type,IMPLEMENTERUSER in  EAS_TCP_IMPLEMENTATION.Implementer%type,RETCODE OUT varchar2);
     -- ��������ʵʩ��רҵ����
    PROCEDURE PR_TCP_BATCHENABLEDIMPL(ORGCODE IN varchar2,TCPCODELIST in varchar2,IMPLEMENTERUSER in  EAS_TCP_IMPLEMENTATION.Implementer%type,RETCODE OUT varchar2);
    ---����ʵʩ��רҵ����
    PROCEDURE PR_TCP_PUTOFFIMPL(ORGCODE IN VARCHAR2,TCPCODE IN EAS_TCP_GUIDANCE.TCPCODE%TYPE ,RETCODE OUT varchar2);
     -- ����-����ʵʩ��רҵ��
    PROCEDURE PR_TCP_BATCHPUTOFFIMPL(ORGCODE IN varchar2,TCPCODELIST in varchar2,RETCODE OUT varchar2);
     -- �·�ʵʩ��רҵ��
    PROCEDURE PR_TCP_PUBLISHIMPL(iORGCODE IN varchar2,iBATCHCODE in varchar2,RETCODE OUT varchar2);
    -- ����ֲ�ִ����רҵ�����ʼ��
    FUNCTION FN_TCP_GETEXECRULEONINIT(iORGCODE in EAS_TCP_IMPLEMENTATION.ORGCODE %type,iTCPCODE in EAS_TCP_IMPLEMENTATION.TCPCODE %type) RETURN TYP_IMPLRULE ;
    
     -- ����ֲ�ִ����רҵ����ģ������ʼ��
    FUNCTION FN_TCP_GETEXECMODULERULEONINIT(iORGCODE in EAS_TCP_IMPLEMENTATION.ORGCODE %type,iTCPCODE in EAS_TCP_IMPLEMENTATION.TCPCODE %type) RETURN COL_MODULERULE ;
   
    --ִ����רҵ����--���� add liufengshuan (רҵ�������,������,ѧϰ��ѧ����,out ����״̬)
    PROCEDURE PR_TCP_ExecutionEnable( i_TCPCode in varchar2,i_OperatorName in varchar2,i_LearningCenterCode in varchar2,returnCode out varchar2);
    
    --ִ����רҵ����--�������� add liufengshuan (רҵ�������,������,ѧϰ��ѧ����,out ����û�����óɹ���tcpcode)
    PROCEDURE PR_TCP_BatchExecutionEnable( i_TCPCodeList in varchar2,i_OperatorName in varchar2,i_LearningCenterCode in varchar2,returnCode out varchar2);
    
    --�������ѧ��,ѧ������,רҵ���,רҵ�����ȡרҵ�������
    Function FN_TCP_GetNewTCPCode(i_batchcode varchar2,i_studentype varchar2,i_professionallevel varchar2,i_spycode varchar2) RETURN varchar2;
    
    --ָ����רҵ�������--����רҵ����
    PROCEDURE Pr_TCP_CopyGuidanceTCP(i_BatchCode in EAS_TCP_GUIDANCE.BatchCode%type,i_MAINTAINER IN varchar2,RETCODE out varchar2); 
   
    ---ִ����רҵ����--���ÿγ�
    PROCEDURE PR_TCP_ExecDeferCourse(i_TCPCode IN EAS_TCP_Execution.TCPCODE%TYPE ,i_LearningCenterCode in EAS_TCP_Execution.LearningCenterCode%TYPE,RETCODE OUT varchar2);
    
        ---ִ����רҵ����--�������ÿγ�
    PROCEDURE PR_TCP_BatchExecDeferCourse(i_TCPCodeList IN varchar2 ,i_LearningCenterCode in EAS_TCP_Execution.LearningCenterCode%TYPE,RETCODE OUT varchar2);


    --ѧϰ����-ѧ�ڿ���γ̹���-- ����ѧ�ڿ���γ̹��� add by liufengshuan
    PROCEDURE PR_TCP_CopyLCenterSemeCourse(i_LearingCenterCode in EAS_TCP_LearCentSemeCour.LearningCenterCode%Type,i_frombatchcode in EAS_TCP_LearCentSemeCour.BatchCode%Type,i_targetBatchcode in EAS_TCP_LearCentSemeCour.BatchCode%Type,returnCode out varchar2);
   
   --ѧϰ����-ѧ�ڿ���γ̹���-- ��ѧ�ڿ���γ̹��� add by liufengshuan
    PROCEDURE PR_TCP_LCenterAddSemeCourse(i_LearingCenterCode in EAS_TCP_LearCentSemeCour.LearningCenterCode%Type,i_frombatchcode in EAS_TCP_LearCentSemeCour.BatchCode%Type,returnCode out varchar2);
    
    --�ֲ�--:�ֲ�ѧ�ڿ���γ̹���-- ����ѧ�ڿ���γ� ����ѡ�����ѧ�ڷֲ��γ̵�ָ����ѧ��
    PROCEDURE Pr_TCP_CopySegmSemeOpenCourse(i_orgCode in varchar,i_frombatchcode in varchar,i_targetBatchcode in varchar,returnCode out varchar2);
    
    --�ֲ�---�ֲ�ѧ�ڿ���γ̹���----��ѧ�ڿ���
    PROCEDURE Pr_TCP_AddSegmSemeCoursByTerm(i_orgCode in varchar,i_yearTerm in varchar,returnCode out varchar2);
    ---����ָ��ѧϰ����רҵ�����ڿγ�
    FUNCTION FN_TCP_GETEXECMODULECOURSE(iORGCODE in EAS_TCP_IMPLEMENTATION.ORGCODE %type,iLEARNINGCENTERCODE in EAS_TCP_EXECUTION.LEARNINGCENTERCODE%type , iTCPCODE in EAS_TCP_IMPLEMENTATION.TCPCODE %type) RETURN COL_EXECMODULECOURSE ;
  ----------���طֲ�ʵʩ��רҵ����γ̣�ָ���Ա���+ʵʩ�����пγ̣�
    Function FN_TCP_GetImplModuleCourses(i_TcpCode varchar2,i_SegmentCode varchar2) return TcpModuleCourses;
    ----����ѧϰ����ִ����רҵ����γ̣�ָ���Ա���+ʵʩ�Ա���+ִ���ԣ�
     Function FN_TCP_GetExecModuleCourses(i_TcpCode varchar2,i_SegmentCode varchar2,i_LearnCode varchar2) return TcpModuleCourses;
     -----����ִ����רҵ����ģ��γ�
     Function FN_TCP_GetMExecModuleCourses(i_TcpCode varchar2,i_SegmentCode varchar2) return TcpModuleCourses;
       -- ִ����רҵ����ģ�����������ж�
   PROCEDURE PR_TCP_MEXECENABLE(ORGCODE IN varchar2, TCPCODE IN varchar2,RETCODE OUT varchar2 );
         
  -- ִ����רҵ����ģ���������������ж�
   FUNCTION  FN_TCP_MEXECENABLE(ORGCODE IN varchar2,TCPCODELIST in varchar2) RETURN str_split PIPELINED;
   ----����ִ����ģ��
   PROCEDURE PR_TCP_ADDMEXECE(ORGCODE IN varchar2, TCPCODE IN varchar2,RETCODE OUT varchar2 );
  
   ----�·�ִ����ģ��
   PROCEDURE PR_TCP_PUBMEXECE(i_Maintainer IN varchar2,i_ORGCODE IN varchar2, i_TCPCODE IN varchar2,RETCODE OUT varchar2 );
   
   --�̳�ִ����ģ�嵥��ִ��
  PROCEDURE PR_TCP_INHERITMEXECE_1(i_SourceSN IN NUMBER,i_ORGCODE IN varchar2, i_TCPCODE IN varchar2,RETCODE OUT varchar2);
  
   --�̳�ִ����ģ��              Դ����                          Ŀ������                       �ֲ�����               ���                     רҵ                 ����ֵ ���ɹ�����OK 
   --������Ϣ�����ࣺ1 �쳣��EXCEPTION 2 a:û�л����һ��Դִ��רҵ����ģ��  3 b û�л����һ��Ŀ��רҵ����                  
  PROCEDURE PR_TCP_INHERITMEXECE(i_SourceBatchCode IN varchar2,i_TargetBatchCode IN varchar2,i_ORGCODE IN varchar2, i_Profession IN varchar2, i_SpyCode IN varchar2,RETCODE OUT varchar2);
  
 
END PK_TCP;
/

