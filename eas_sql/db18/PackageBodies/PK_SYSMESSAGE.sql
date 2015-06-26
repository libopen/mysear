--
-- PK_SYSMESSAGE  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_SysMessage AS
    
Procedure Pr_RecordSysMessage
(
    vMsgScope varchar2,
    vMsgContent varchar2,
    vMsgSource varchar2
)
is
/******************************************************************************
   NAME:       FN_RecordMessage
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015/6/8   Administrator       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     FN_RecordMessage
      Sysdate:         2015/6/8
      Date and Time:   2015/6/8, 16:27:38, and 2015/6/8 16:27:38
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
x_count int;
BEGIN
   x_count := 0;
   select count(1) into x_count from EAS_Sys_Message where msgScope = vMsgScope and msgContent = vMsgContent and (msgState is null or msgState =0);
   if x_count < 1 then --写入两个的原因是防止之前的还没计算完成，后边的却不让加了
     insert into EAS_Sys_Message (SN,MsgScope,MsgContent,CreateTime,MsgSource,MsgState)
     values(seq_ExmM_Message.nextVal,vMsgScope,vMsgContent,sysdate,vMsgSource,0);
   end if;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END Pr_RecordSysMessage;
end PK_SysMessage;
/

