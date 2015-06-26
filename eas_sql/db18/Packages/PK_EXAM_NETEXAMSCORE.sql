--
-- PK_EXAM_NETEXAMSCORE  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_EXAM_NETEXAMSCORE AS
/******************************************************************************
   NAME:       PK_EXAM_NETEXAMSCORE
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015-05-21      libin       1. Created this package.
******************************************************************************/
----导入网考成绩 i_XMLSTR 导入数据XML格式  i_UnifBatchCode 导入批次,i_Maintainer 维护人 RETCODE 返回值正常返回导入数，异常返回－1 
  PROCEDURE PR_EXMM_IMPORTNETSCORE(i_XMLSTR VARCHAR2,i_UnifBatchCode VARCHAR2,i_Maintainer  VARCHAR2 ,RETCODE out VARCHAR2);
    
    
 ----导入网考成绩 i_XMLSTR 导入数据XML格式  i_UnifBatchCode 导入批次,i_Maintainer 维护人 RETCODE 返回值正常返回导入数，异常返回－1 
 PROCEDURE PR_EXMM_IMPORTNETSCORE_30(i_XMLSTR VARCHAR2,i_UnifBatchCode VARCHAR2,i_Maintainer  VARCHAR2 ,RETCODE out VARCHAR2);
    

END PK_EXAM_NETEXAMSCORE;
/

