--
-- MROW_STUDENTELC2  (Type) 
--
CREATE OR REPLACE TYPE OUCHNSYS."MROW_STUDENTELC2"                                                                                   AS OBJECT
(
                       batchcode varchar2(6),
                       studentcode varchar2(20),
                       fullname    varchar2(20),
                       professionallevel varchar(20),
                       spyname           varchar2(30),
                       learnname         varchar2(50),
                       CourseID    VARCHAR2(10)
  
)
/

