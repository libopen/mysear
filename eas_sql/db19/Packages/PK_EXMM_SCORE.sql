--
-- PK_EXMM_SCORE  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_ExMM_Score AS
/******************************************************************************
   NAME:       PK_ExMM_Score
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/11/6      Administrator       1. Created this package.
******************************************************************************/
   --写入形考成绩和详细
  procedure InsertXKScoreAndDetail
    (
        InSN in int,
        InXKP_SN int,
        InScore in varchar2,
        InScoreCode in varchar2,
        InEntryStaff in varchar2,
        InItemXml IN varchar2,
        OutCount out int
    );
  --一录和直接二录
    procedure Pro_Exam_RecordExamScore
    (
        InStrXml varchar2,--写入的xml
        InEntryOrgType int,--录入单位类型
        InEntryOrgCode varchar2,--录入单位编码
        InScoreType int,--成绩类型1客观成绩2主观成绩
        InEntryStaff varchar2,--操作员
        OutCount out int
    );
    --成绩初始化
    PROCEDURE Pro_Exam_InitializeExamScore
    (
        InSegmentCode varchar2,
        InExamPlanCode varchar2,
        InExamCategoryCode varchar2,
        OutCountCMScore out int,
        OutErrorCount out int,
        OutAllCount out int
    );
    
    --导入实践课成绩
    Procedure Pro_Exam_ImportPCScore
    (
        InSegmentCode varchar2,
        InCollegeCode varchar2,
        InLearningCenterCode varchar2,
        InEntryOrgType int,
        InEntryOrgCode varchar2,
        InCourseID varchar2,
        InEntryStaff varchar2,
        InRewrite int,
        InStrXml varchar2,
        OutCount out int,
        OutErrorCodes out varchar2--发生错误的学生编码
    );
    
    --成绩合成
    PROCEDURE Pro_ExmM_GenerateExamScore
    (
        InExamPlanCode varchar2,
        InExamCategoryCode varchar2,
        InSegmentCode varchar2,
        InCollegeCode varchar2,
        InLearningCenterCode varchar2,
        InExamPaperCode varchar2,
        InExamPaperCodeA varchar2,
        InExamPaperCodeB varchar2,
        InStudentCodeA varchar2,
        InStudentCodeB varchar2,
        InExamSecretCode varchar2,
        InComposeOnlyFirst int,
        OutCount out int,--成功数量
        OutUnSuccessCount out int,--不成功数量
        OutError out varchar2
    );
    
    --综合成绩合成--保存数据
    PROCEDURE UpdateComposeScore 
    (
        InStrXml varchar2,
        OutCount out int
    );
END PK_ExMM_Score;
/

