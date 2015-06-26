--
-- SELECTSTUDENTSOFNUM  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.SelectStudentsOfNum(lcCode in varchar2,mycur out SYS_REFCURSOR) IS


BEGIN
   open mycur for
    select * from EAS_SchRoll_Student where LearningCenterCode=lcCode;
   
END SelectStudentsOfNum;
/

