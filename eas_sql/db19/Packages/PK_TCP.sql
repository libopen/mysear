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

  ----------���طֲ�ʵʩ��רҵ����γ̣�ָ���Ա���+ʵʩ�����пγ̣�
    Function FN_TCP_GetImplModuleCourses(i_TcpCode varchar2,i_SegmentCode varchar2) return TcpModuleCourses;
 ----����ѧϰ����ִ����רҵ����γ̣�ָ���Ա���+ʵʩ�Ա���+ִ���ԣ�
     Function FN_TCP_GetExecModuleCourses(i_TcpCode varchar2,i_SegmentCode varchar2,i_LearnCode varchar2) return TcpModuleCourses;

END PK_TCP;
/

