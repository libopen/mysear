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


------------------------------------------/*报考*/-----------------------------------------
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
-----------------------------------------------确认-----------------------------------------
/*确认报考-支持正常报考和报考专选课的报考记录*/
  PROCEDURE Pro_ConfirmSignUpToElc(
    InBatchCode varchar2,
    InStrWhere varchar2,
    InConfirmer varchar2,
    OutCount out int
);

-----------------------------------------------删除-----------------------------------------
/*通过编号删除报考信息，可以删除已经确认的报考*/
procedure PR_DeleteSignUpByPK(
InSNs varchar2,
InMaintainer varchar2,
OutCount out int);

/*通过条件删除报考信息，可以删除已经确认的报考*/
procedure PR_DeleteSignUp(
InStrWhere varchar2,
InMaintainer varchar2,
OutCount out int);
---------------------------------------------试卷号-----------------------------
/*更新试卷号和备注信息，如果试卷号备注信息为空，则不更新*/
PROCEDURE PR_ExmM_SignUp_UpdateExamPaper(InStrXml VARCHAR2,OutCount out int );

--------------------------------------------更新学习状态------------------------
PROCEDURE PR_ExmM_upDateStuStadyStatus(InWhereStr VARCHAR2,OutCount out int );
END PK_EXMM_SignUp;
/

