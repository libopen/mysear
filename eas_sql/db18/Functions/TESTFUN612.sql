--
-- TESTFUN612  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.testfun612(classcode varchar2,LEARNINGCENTERCODE VARCHAR2
               
        )RETURN NUMBER
        is
               result number;
        BEGIN
           
                    SELECT count(*) as total into result FROM EAS_SCHROLL_STUDENT WHERE 1>0 AND CLASSCODE = '081200202014009' AND LEARNINGCENTERCODE = '1200202' AND ENROLLMENTSTATUS = '1';
                    return result;
        END;

/

