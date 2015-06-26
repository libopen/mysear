--
-- FN_GETTCPCODE  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.fn_GetTCPCode(
i_batchcode varchar2,
i_studentype varchar2,
i_professionallevel varchar2,
i_spycode varchar2
) 
RETURN varchar2 
IS
v_result varchar2(40):='';
/******************************************************************************
   NAME:       fn_GetTCPCode
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/4/17   liufengshuan       1. Created this function.

   NOTES: 根据学期+学生类型+层次+专业代码 

******************************************************************************/
BEGIN
   if i_batchcode is not null then
   
    v_result:= substr(i_batchcode,-4)||i_studentype||i_professionallevel||i_spycode;
    
   end if;
    return v_result;

END fn_GetTCPCode;
/

