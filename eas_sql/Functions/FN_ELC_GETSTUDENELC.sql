--
-- FN_ELC_GETSTUDENELC  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.fn_Elc_GetStudenElc( iindex number) RETURN mTB_StudentElc IS
var_mtb_studentelc MTB_StudentElc :=MTB_StudentElc(); 
/******************************************************************************
   NAME:       fn_Elc_GetStudenElc
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/16   libin       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     fn_Elc_GetStudenElc
      Sysdate:         2014/05/16
      Date and Time:   2014/05/16, 17:59:34, and 2014/05/16 17:59:34
      Username:        libin (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   
      for cur in (select * from eas_dic_subject) LOOP
         var_mtb_studentelc.extend;
         var_mtb_studentelc(var_mtb_studentelc.count):= mrow_studentelc(cur.dicname,cur.diccode);
       End loop;
    return var_mtb_studentelc;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END fn_Elc_GetStudenElc;
/

