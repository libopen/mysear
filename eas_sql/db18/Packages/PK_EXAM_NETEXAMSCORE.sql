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
----���������ɼ� i_XMLSTR ��������XML��ʽ  i_UnifBatchCode ��������,i_Maintainer ά���� RETCODE ����ֵ�������ص��������쳣���أ�1 
  PROCEDURE PR_EXMM_IMPORTNETSCORE(i_XMLSTR VARCHAR2,i_UnifBatchCode VARCHAR2,i_Maintainer  VARCHAR2 ,RETCODE out VARCHAR2);
    
    
 ----���������ɼ� i_XMLSTR ��������XML��ʽ  i_UnifBatchCode ��������,i_Maintainer ά���� RETCODE ����ֵ�������ص��������쳣���أ�1 
 PROCEDURE PR_EXMM_IMPORTNETSCORE_30(i_XMLSTR VARCHAR2,i_UnifBatchCode VARCHAR2,i_Maintainer  VARCHAR2 ,RETCODE out VARCHAR2);
    

END PK_EXAM_NETEXAMSCORE;
/

