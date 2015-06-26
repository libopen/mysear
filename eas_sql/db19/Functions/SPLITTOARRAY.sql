--
-- SPLITTOARRAY  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.splitToArray  
   (src VARCHAR2, delimiter varchar2)  
  RETURN myVarchar2 IS  
  psrc VARCHAR2(500);  
  a myVarchar2 := myVarchar2();  
  i NUMBER := 1;  --  
  j NUMBER := 1;  
BEGIN
  psrc := RTrim(LTrim(REPLACE(src,'''',''), delimiter), delimiter);  
  LOOP  
    i := InStr(psrc, delimiter, j);  
    --Dbms_Output.put_line(i);  
    IF i>0 THEN  
      a.extend;  
      a(a.Count) := Trim(SubStr(psrc, j, i-j));  
      j := i+1;  
      --Dbms_Output.put_line(a(a.Count-1));  
    END IF;  
    EXIT WHEN i=0;  
  END LOOP;  
  IF j < Length(psrc) THEN  
    a.extend;  
    a(a.Count) := Trim(SubStr(psrc, j, Length(psrc)+1-j));  
  END IF;  
  RETURN a;  
END;
/

