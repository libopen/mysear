--
-- EXAMPLAN  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."EXAMPLAN"                                                                                   AS OBJECT
(
/*
 ERROR CODE
 1.ֽ���ƻ���ֽ���ƻ����в�����
 2.
*/
  PlanMakeOrgCode VARCHAR2(20),  --step:1
  PlanMakeOrgType VARCHAR2(3),   --step:1
  PlanUseOrgCode VARCHAR2(20),   --step:2
  PlanUseOrgType VARCHAR2(255),  --step:2
  IsInPlanPub NUMBER,  ---�з�ֽ���ƻ��·����м�¼
  IsApply   NUMBER,    --�Ƿ��·� step:13
  ExamSessionUnitMode NUMBER,      --step:3
  ExamType varchar2(10),          --step:1
  PlanCode      varchar2(20),     --step:1
  CateGoryCode  varchar2(20),     --step:4
  CateGoryOrgCode varchar2(20),   --step:4
  CateGoryOrgType varchar2(3),    --step:4
  IsInDetailPub   number, --�з�ƻ�����ʱ����¼
  ErrorCode       number
  ,CONSTRUCTOR  function ExamPlan(i_ExamPlanSN number,i_PlanUseOrgCode varchar2 ,i_ExamCategorySN number) return self as result
   ,CONSTRUCTOR  function ExamPlan(i_ExamPlanSN number,i_PlanUseOrgCode varchar2 ) return self as result
  
)
/

