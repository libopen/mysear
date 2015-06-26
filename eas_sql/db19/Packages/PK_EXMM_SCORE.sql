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
   --д���ο��ɼ�����ϸ
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
  --һ¼��ֱ�Ӷ�¼
    procedure Pro_Exam_RecordExamScore
    (
        InStrXml varchar2,--д���xml
        InEntryOrgType int,--¼�뵥λ����
        InEntryOrgCode varchar2,--¼�뵥λ����
        InScoreType int,--�ɼ�����1�͹۳ɼ�2���۳ɼ�
        InEntryStaff varchar2,--����Ա
        OutCount out int
    );
    --�ɼ���ʼ��
    PROCEDURE Pro_Exam_InitializeExamScore
    (
        InSegmentCode varchar2,
        InExamPlanCode varchar2,
        InExamCategoryCode varchar2,
        OutCountCMScore out int,
        OutErrorCount out int,
        OutAllCount out int
    );
    
    --����ʵ���γɼ�
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
        OutErrorCodes out varchar2--���������ѧ������
    );
    
    --�ɼ��ϳ�
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
        OutCount out int,--�ɹ�����
        OutUnSuccessCount out int,--���ɹ�����
        OutError out varchar2
    );
    
    --�ۺϳɼ��ϳ�--��������
    PROCEDURE UpdateComposeScore 
    (
        InStrXml varchar2,
        OutCount out int
    );
END PK_ExMM_Score;
/

