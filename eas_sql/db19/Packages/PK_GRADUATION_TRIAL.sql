--
-- PK_GRADUATION_TRIAL  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_Graduation_Trial AS
/******************************************************************************
   NAME:       毕业初审
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015/4/16      Administrator       1. Created this package.
******************************************************************************/
--计算毕业条件模块汇总
  PROCEDURE ProCalModuleTotalCredit(
    InGradStudentSN number,
    InStudentCode varchar2,
    InSegmentCode varchar2,
    InLearningCenterCode varchar2,
    InTcpCode varchar2,
    InAuditor varchar2,
    OutCount out int);

END PK_Graduation_Trial;
/

