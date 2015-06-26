--
-- PK_EXMM_EXAMLAYOUT  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_EXMM_ExamLayOut AS
/******************************************************************************
   NAME:       PK_EXMM_ExamLayOut
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/11/4      Administrator       1. Created this package.
******************************************************************************/

  --�����Ž��д�����
  PROCEDURE PRO_Exam_InsertArrangeResult(InExamPlanCode varchar2,InCreateOrgCode varchar2,strXml varchar2,InMaintainer varchar2,outCount out int);

  --�������α����е�������Ϣ
  PROCEDURE Pro_Exam_UpdateSeatArrange(strXml varchar2,outCount out int);
END PK_EXMM_ExamLayOut;
/

