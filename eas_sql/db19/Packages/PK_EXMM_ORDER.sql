--
-- PK_EXMM_ORDER  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_EXMM_Order AS
/******************************************************************************
   NAME:       PK_EXMM_Order
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/10/24      Administrator       1. Created this package.
******************************************************************************/

PROCEDURE Pro_Exam_CreateOrders(
    inExamPlanCode varchar2,
    inCreateOrgCode varchar2,
    inExamCategoryCode varchar2,
    inOrgCode varchar2,
    inOrgType int,
    inCollegeCode varchar2,
    inTopOrgCode varchar2,
    inExamSiteCodes varchar2,
    inExamUnitType varchar2,
    inMaintainer varchar2,
    outCount out int
);

END PK_EXMM_Order;
/

