--
-- PK_EXPT  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_EXPT AS
/******************************************************************************
   NAME:       PK_EXPT
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015-06-17      libin       1. Created this package.
******************************************************************************/
---- i_XMLSTR ��������XML��ʽ  i_impFile �����ļ���,i_Maintainer ά���� RETCODE ����ֵ�������أ��ɹ�������ʧ�������� ���쳣���أ�1
   ---***XML***---
   --��ʽ <t>
  --<r><A>ѧ��</A><B>����</B><C>ѧϰ���Ĵ���</C><D>��Ŀ����</D><E>������Ϣ</E></r>
  --</t>
  PROCEDURE PR_EXPT_IMPORTREPORT(i_XMLSTR VARCHAR2,i_impFile VARCHAR2,i_Maintainer  VARCHAR2 ,RETCODE out VARCHAR2);

END PK_EXPT;
/

