--
-- PRCALMODULETOTALCREDIT  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PrCalModuleTotalCredit IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       CalModuleTotalCredit
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015/4/15   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     CalModuleTotalCredit
      Sysdate:         2015/4/15
      Date and Time:   2015/4/15, 17:26:53, and 2015/4/15 17:26:53
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END CalModuleTotalCredit;
/

