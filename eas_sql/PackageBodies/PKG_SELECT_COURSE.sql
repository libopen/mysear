--
-- PKG_SELECT_COURSE  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PKG_SELECT_COURSE AS
/******************************************************************************
   NAME:       PKG_SELECT_COURSE
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/16      libin       1. Created this package.
******************************************************************************/
PROCEDURE GETALLCOURSE
(cur_name out T_CURSOR)
IS
BEGIN
  open cur_name FOR
   select * from eas_dic_subject;
   END GETALLCOURSE;

END PKG_SELECT_COURSE;
/

