--
-- PKG_SELECT_COURSE  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PKG_SELECT_COURSE AS
/******************************************************************************
   NAME:       PKG_SELECT_COURSE
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/16      libin       1. Created this package.
******************************************************************************/

TYPE T_CURSOR is ref cursor;
PROCEDURE GETALLCOURSE
(cur_name out T_CURSOR);


END PKG_SELECT_COURSE;
/

