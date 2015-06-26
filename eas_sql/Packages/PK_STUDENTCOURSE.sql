--
-- PK_STUDENTCOURSE  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_STUDENTCOURSE AS
/******************************************************************************
   NAME:       PK_STUDENTCOURSE
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/19      libin       1. Created this package.
******************************************************************************/

  FUNCTION FN_GETSTUDENTCOURSEINDBBASE(in_XML_ELC IN CLOB) RETURN MTB_StudentElc;
  

END PK_STUDENTCOURSE;
/

