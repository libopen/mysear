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

  --将编排结果写入表中
  PROCEDURE PRO_Exam_InsertArrangeResult(InExamPlanCode varchar2,InCreateOrgCode varchar2,strXml varchar2,InMaintainer varchar2,outCount out int);

  --更新座次编排中的座次信息
  PROCEDURE Pro_Exam_UpdateSeatArrange(strXml varchar2,outCount out int);
END PK_EXMM_ExamLayOut;
/

