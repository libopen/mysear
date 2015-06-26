--
-- GETNORMALSEMESTERS  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.GetNormalSemesters(n_byte varchar) RETURN varchar IS
  V_RTN VARCHAR(20);
  V_N1  NUMBER;
  V_N2  NUMBER;
  V_Length int;
  V_I int;
  V_X int;
BEGIN
   V_Length := length(n_byte);
   V_I :=V_Length -1;
   V_X :=1;
   loop
      V_N1 := substr(n_byte,V_I,1);
      if V_N1='1' then
        if length(V_RTN)!=0 then
            V_RTN := V_RTN ||','; 
        end if;
        V_RTN := V_RTN || (V_X);
      end if;
      
      V_I := V_I -1;
      V_X := V_X +1;
      
   exit when V_I =0;
   end loop;
   
   RETURN V_RTN;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END GetNormalSemesters;
/

