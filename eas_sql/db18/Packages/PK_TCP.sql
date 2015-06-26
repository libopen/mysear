--
-- PK_TCP  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_TCP AS
/******************************************************************************
   NAME:       PK_TCP
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015-04-15      libin       1. Created this package.
******************************************************************************/

  ----------返回分部实施性专业规则课程（指导性必修+实施性所有课程）
    Function FN_TCP_GetImplModuleCourses(i_TcpCode varchar2,i_SegmentCode varchar2) return TcpModuleCourses;
 ----返回学习中心执行性专业规则课程（指导性必修+实施性必修+执行性）
     Function FN_TCP_GetExecModuleCourses(i_TcpCode varchar2,i_SegmentCode varchar2,i_LearnCode varchar2) return TcpModuleCourses;

END PK_TCP;
/

