--
-- SELECTSTUDENTSOFNUM  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.SelectStudentsOfNum(lcCode in varchar2,outcount out number) IS

BEGIN
   select  count(LearningCenterCode)as mycount into outcount from EAS_SchRoll_Student where LearningCenterCode=lcCode;
   
 
END SelectStudentsOfNum;
/

