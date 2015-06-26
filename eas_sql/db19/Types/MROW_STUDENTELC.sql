--
-- MROW_STUDENTELC  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."MROW_STUDENTELC"                                                                                   FORCE AS  OBJECT
(
  STUDENTID VARCHAR2(40),
  STUDENTCODE VARCHAR2(20),
  COURSEID VARCHAR2(10),
  CurrentSelectNumber NUMBER
)
/

