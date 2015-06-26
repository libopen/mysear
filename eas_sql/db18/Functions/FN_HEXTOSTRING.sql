--
-- FN_HEXTOSTRING  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.FN_HEXTOSTRING(hex_value in INT) 
RETURN VARCHAR2 IS 
v_Value VARCHAR2(50) ;
tmp_value char(30);
tmp_num int;
tmp_count int;
BEGIN
    v_Value := '' ;
    tmp_num := 1;    
    tmp_value :=to_char(hex_value) ;
    
    tmp_count := length(tmp_value) ;
    while tmp_num <= tmp_count 
    loop
 
     if(substr(to_char(hex_value)  , -tmp_num , 1) = '1' ) then
    
        v_Value := concat(CONCAT(v_Value,TO_CHAR(tmp_num)) , ',' );
     
     end if ;
     tmp_num :=tmp_num+1;
    end loop;
    if length(v_Value) > 0 then
         return substr(v_Value, 0 , length(v_Value)-1) ;
    else 
         return  '' ;     
    end if;
END;
/

