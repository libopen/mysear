--
-- PK_ELC  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_ELC AS
/******************************************************************************
   NAME:       PK_ELC
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/06/11      libin       1. Created this package.
******************************************************************************/
 /*  返回指定批次下的学生的选课情况*/
  FUNCTION FN_ELC_GETCURRENTELCINFO(i_ELC_XML IN CLOB,i_ELCBATCHCODE IN VARCHAR2) RETURN MTB_STUDENTELC;
  /*  开课*/
  PROCEDURE PR_ELC_OpenCourse(i_ELC_XML in CLOB,i_ElcBatchCode in EAS_ELC_STUDENTELCINFO.BATCHCODE%type ,i_ClassCode in EAS_ELC_STUDENTELCINFO.CLASSCODE%type ,i_ElcType in EAS_ELC_STUDENTELCINFO.ElcType%type ,i_LearnCenterCode in EAS_ELC_STUDENTELCINFO.LEARNINGCENTERCODE %type,i_IsPlan in EAS_ELC_STUDENTELCINFO.ISPLAN %type,i_Operator in EAS_ELC_STUDENTELCINFO.OPERATOR %type,i_spycode in EAS_ELC_STUDENTELCINFO.SPYCODE %type,i_IsApplyExam in EAS_ELC_STUDENTELCINFO.ISAPPLYEXAM %type,oReturn out varchar2); 
  
  PROCEDURE PR_ELC_OpenCourse2(i_ELC_XML in CLOB,oReturn out varchar2); 
 /*选课确认*/
  PROCEDURE PR_ELC_ConfirmSelectedCourses(inConfirmOparator in varchar,inBatchCode in varchar,inStudentCode in varchar,inCourseID  in  varchar,inMutexCourseID in varchar,inLearningCenterCode in varchar,outUpdatedCount out int);
  /*通过班级选课确认*/
  /*通过班级删除未确认的选课信*/
  Procedure PR_ELC_DelUnCfmCoursesByClass(InIsPlan in varchar2,inBatchCode in varchar2,inLearningCenterCode in varchar2,inClassCode in varchar2,outUpdatedCount out int);
  /*过学生删除其为确认的选课信息*/
  Procedure PR_ELC_DelUnCfmCoursesByStu(InIsPlan in varchar2,inBatchCode in varchar2,inLearningCenterCode in varchar2,inStudentCode in varchar2,inCourseCode in varchar2,outUpdatedCount out int);
  /*通过选课信息编号删除未确认的学生选课*/
  Procedure PR_ELC_DelUnCfmCoursesByREFID(inREFID in varchar,outUpdatedCount out int);

END PK_ELC;
/

