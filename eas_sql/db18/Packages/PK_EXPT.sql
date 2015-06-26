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
---- i_XMLSTR 导入数据XML格式  i_impFile 导入文件名,i_Maintainer 维护人 RETCODE 返回值正常返回（成功条数，失败条数） ，异常返回－1
   ---***XML***---
   --格式 <t>
  --<r><A>学号</A><B>姓名</B><C>学习中心代码</C><D>科目代码</D><E>错误信息</E></r>
  --</t>
  PROCEDURE PR_EXPT_IMPORTREPORT(i_XMLSTR VARCHAR2,i_impFile VARCHAR2,i_Maintainer  VARCHAR2 ,RETCODE out VARCHAR2);

END PK_EXPT;
/

