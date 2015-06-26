--
-- EXAMPLAN  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."EXAMPLAN"                                                                                   AS OBJECT
(
/*
 ERROR CODE
 1.纸考计划在纸考计划表中不存在
 2.
*/
  PlanMakeOrgCode VARCHAR2(20),  --step:1
  PlanMakeOrgType VARCHAR2(3),   --step:1
  PlanUseOrgCode VARCHAR2(20),   --step:2
  PlanUseOrgType VARCHAR2(255),  --step:2
  IsInPlanPub NUMBER,  ---有否纸考计划下发表中记录
  IsApply   NUMBER,    --是否下发 step:13
  ExamSessionUnitMode NUMBER,      --step:3
  ExamType varchar2(10),          --step:1
  PlanCode      varchar2(20),     --step:1
  CateGoryCode  varchar2(20),     --step:4
  CateGoryOrgCode varchar2(20),   --step:4
  CateGoryOrgType varchar2(3),    --step:4
  IsInDetailPub   number, --有否计划考试时间表记录
  ErrorCode       number
  ,CONSTRUCTOR  function ExamPlan(i_ExamPlanSN number,i_PlanUseOrgCode varchar2 ,i_ExamCategorySN number) return self as result
   ,CONSTRUCTOR  function ExamPlan(i_ExamPlanSN number,i_PlanUseOrgCode varchar2 ) return self as result
  
)
/

