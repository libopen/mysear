--
-- PK_SIGN  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_SIGN AS
/******************************************************************************
   NAME:       PK_SIGN
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/11/20      libin       1. Created this package.
******************************************************************************/

 Type SignStatics_Type IS Record
(
  ExamPlanCode VARCHAR2(20),
  ExamCategoryCode VARCHAR2(20),
  ExamPaperCode VARCHAR2(20),
  SignCnt NUMBER,
  ConfirmCnt NUMBER
);

type t_SignStatics is table of SignStatics_Type ;

Function Get_SignStaticsAll(i_ExamplanCode in varchar2) return  SignStatics_tab;
END PK_SIGN;
/

