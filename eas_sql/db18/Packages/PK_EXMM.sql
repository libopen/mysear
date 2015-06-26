--
-- PK_EXMM  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_ExmM AS
/******************************************************************************
   NAME:       PK_ExmM
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/9/2      test       1. Created this package.
******************************************************************************/
    

          
procedure pr_exmm_Getdblink(retcode out varchar2);


procedure pr_exmm_batchaddnetscore(arr_Students in dbms_utility.lname_array ,arr_Courses in DBMS_UTILITY.LNAME_ARRAY ,arr_Score in DBMS_UTILITY.LNAME_ARRAY ,numTime out number);
procedure pr_exmm_batchaddnetscore2(arr_Students in LIST50_VARCHAR ,arr_Courses in LIST50_VARCHAR ,arr_Score in LIST50_VARCHAR ,numTime out number);
                 
END PK_ExmM;
/

