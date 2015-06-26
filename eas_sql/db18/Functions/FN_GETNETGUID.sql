--
-- FN_GETNETGUID  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.fn_getNetGuid(
v_guid varchar2
)
return varchar2
as
    v_ret varchar(40):='';
begin
   if length(v_guid)=32 then
   v_ret:= substr(v_guid,1,8)||'-'||substr(v_guid,9,4)||'-'||substr(v_guid,13,4)||'-'||substr(v_guid,17,4)||'-'||substr(v_guid,21,12); 
   
   end if;
   return v_ret;
   
end fn_getNetGuid;
/

