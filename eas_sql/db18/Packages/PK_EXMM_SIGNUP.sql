--
-- PK_EXMM_SIGNUP  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_EXMM_SignUp AS
/******************************************************************************
   NAME:       PK_EXMM_SignUp
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015/3/25      Administrator       1. Created this package.
******************************************************************************/


------------------------------------------/*����*/-----------------------------------------
PROCEDURE PR_EXMM_SIGNUP(
    InSignUpXml VARCHAR2,
    InExamBatchCode VARCHAR2,
    InExamPlanCode VARCHAR2 ,
    --InExamCategoryCode VARCHAR2,
    InSegmentCode  VARCHAR2 ,
    InLearningCenterCode   VARCHAR2 ,
    InApplicant     NVARCHAR2 ,
    InSignUpType    NUMBER ,
    OutTotalCount out int);
-----------------------------------------------ȷ��-----------------------------------------
/*ȷ�ϱ���-֧�����������ͱ���רѡ�εı�����¼*/
  PROCEDURE Pro_ConfirmSignUpToElc(
    InBatchCode varchar2,
    InStrWhere varchar2,
    InConfirmer varchar2,
    OutCount out int
);

-----------------------------------------------ɾ��-----------------------------------------
/*ͨ�����ɾ��������Ϣ������ɾ���Ѿ�ȷ�ϵı���*/
procedure PR_DeleteSignUpByPK(
InSNs varchar2,
InMaintainer varchar2,
OutCount out int);

/*ͨ������ɾ��������Ϣ������ɾ���Ѿ�ȷ�ϵı���*/
procedure PR_DeleteSignUp(
InStrWhere varchar2,
InMaintainer varchar2,
OutCount out int);
---------------------------------------------�Ծ��-----------------------------
/*�����Ծ�źͱ�ע��Ϣ������Ծ�ű�ע��ϢΪ�գ��򲻸���*/
PROCEDURE PR_ExmM_SignUp_UpdateExamPaper(InStrXml VARCHAR2,OutCount out int );

--------------------------------------------����ѧϰ״̬------------------------
PROCEDURE PR_ExmM_upDateStuStadyStatus(InWhereStr VARCHAR2,OutCount out int );
END PK_EXMM_SignUp;
/

