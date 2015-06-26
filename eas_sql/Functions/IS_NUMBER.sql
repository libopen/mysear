--
-- IS_NUMBER  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.is_number (
                str_in IN VARCHAR2
                ) RETURN NUMBER DETERMINISTIC PARALLEL_ENABLE IS
   n NUMBER;
BEGIN
   n := TO_NUMBER(str_in);
   RETURN 1;
EXCEPTION
   WHEN VALUE_ERROR THEN
      RETURN 0;
END;
/

