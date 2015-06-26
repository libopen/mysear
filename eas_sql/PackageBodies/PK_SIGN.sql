--
-- PK_SIGN  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_SIGN AS
/******************************************************************************
   NAME:       PK_SIGN
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/11/20      libin       1. Created this package body.
******************************************************************************/

 Function Get_SignStaticsAll(i_ExamplanCode in varchar2) return  SignStatics_tab IS
 
   SignStatics SignStatics_tab :=SignStatics_tab(); ----用于本函数返回记录
   v_tb112 t_SignStatics;    --用于批量存储从业务库获取的数据bulk collect into 只能支持这样的类型
   v_tb113 t_SignStatics;
 BEGIN
     select examplancode,examcategorycode,exampapercode ,count(*) cnt1,sum(case when isconfirm=1 then 1 else 0 end) as cnt2
     bulk collect into v_tb113
     from eas_exmm_signup@ouchn113
     group by examplancode,examcategorycode,exampapercode;
  for i in 1..v_tb113.count 
  loop
    SignStatics.extend();
    SignStatics(i):=R_SignStatics( v_tb113(i).examplancode,v_tb113(i).examCategorycode,v_tb113(i).Exampapercode,v_tb113(i).SignCnt,v_tb113(i).ConfirmCnt); 
  
  end loop;
  return SignStatics;
 end ;

END PK_SIGN;
/

