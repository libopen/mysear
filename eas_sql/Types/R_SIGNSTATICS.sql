--
-- R_SIGNSTATICS  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."R_SIGNSTATICS"                                                                                   AS OBJECT
(
  ExamPlanCode VARCHAR2(20),
  ExamCategoryCode VARCHAR2(20),
  ExamPaperCode VARCHAR2(20),
  SignCnt NUMBER,
  ConfirmCnt NUMBER
)
/

