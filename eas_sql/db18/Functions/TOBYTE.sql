--
-- TOBYTE  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.ToByte(V_Num int) RETURN varchar IS
  V_RTN VARCHAR(8);
  V_N1  NUMBER;
  V_N2  NUMBER;
BEGIN
  V_N1 := ABS(V_NUM);
  --如果为正数
  IF SIGN(V_NUM) > 0 THEN
    LOOP
      V_N2  := MOD(V_N1, 2);
      V_N1  := ABS(TRUNC(V_N1 / 2));
      V_RTN := TO_CHAR(V_N2) || V_RTN;
      EXIT WHEN V_N1 = 0;
    END LOOP;
  else
  RETURN '';
  end if;
   RETURN V_RTN;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END ToByte;
/

