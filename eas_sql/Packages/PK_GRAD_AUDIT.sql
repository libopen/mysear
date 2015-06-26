--
-- PK_GRAD_AUDIT  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_Grad_Audit AS
/******************************************************************************
   NAME:       PK_Grad_Audit
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015/4/21      Administrator       1. Created this package.
******************************************************************************/

--更新毕业管理_学生毕业审核表中的申请时预审核状态
PROCEDURE PR_Grad_UpdateGradCondition(
    isGradPass int,
    isDegreePass int,
    inStudentCode varchar2,
    outCount out int
   );

--初审名单审核
PROCEDURE Pr_Grad_TrailListProcess(
    InSegmentCode varchar2,
    OutCount out int
    );
--单个学生初审
PROCEDURE PR_Grad_TrailListWithAStudent(
    InStudentCode varchar2,
    OutCount out int
    );
END PK_Grad_Audit;
/

