--
-- PK_EXMM_SESSIONUNIT  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_ExmM_SessionUnit AS
/******************************************************************************
   NAME:       PK_ExmM_SessionUnit
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/9/23      Administrator       1. Created this package.
******************************************************************************/

  PROCEDURE UpdateSessionUnitInSubjectPlan(InXml IN varchar2,OutCount out int);

END PK_ExmM_SessionUnit;
/

