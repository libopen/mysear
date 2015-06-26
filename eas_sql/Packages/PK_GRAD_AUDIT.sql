--
-- PK_GRAD_AUDIT  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_Grad_Audit AS
/******************************************************************************
   NAME:       PK_Grad_Audit
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015/4/21      Administrator       1. Created this package.
******************************************************************************/

--���±�ҵ����_ѧ����ҵ��˱��е�����ʱԤ���״̬
PROCEDURE PR_Grad_UpdateGradCondition(
    isGradPass int,
    isDegreePass int,
    inStudentCode varchar2,
    outCount out int
   );

--�����������
PROCEDURE Pr_Grad_TrailListProcess(
    InSegmentCode varchar2,
    OutCount out int
    );
--����ѧ������
PROCEDURE PR_Grad_TrailListWithAStudent(
    InStudentCode varchar2,
    OutCount out int
    );
END PK_Grad_Audit;
/

