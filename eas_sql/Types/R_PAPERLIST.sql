--
-- R_PAPERLIST  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."R_PAPERLIST"                                                                                   AS OBJECT
(
  SN NUMBER,
  ExamCategoryCode VARCHAR2(20),
  ExamPaperCode VARCHAR2(20),
  AllowMakeExamSession number,
  AllowMakePaper number
  
)
/

