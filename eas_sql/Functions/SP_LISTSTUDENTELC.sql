--
-- SP_LISTSTUDENTELC  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.sp_ListStudentElc RETURN 
TYPES.CURSORTYPE  
IS
l_cursor TYPES.CURSORTYPE ;
/******************************************************************************
   NAME:       sp_ListStudentElc
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/16   libin       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     sp_ListStudentElc
      Sysdate:         2014/05/16
      Date and Time:   2014/05/16, 16:11:30, and 2014/05/16 16:11:30
      Username:        libin (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   open l_cursor for select diccode,dicname from eas_dic_subject;
   RETURN l_cursor;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END sp_ListStudentElc;
/

