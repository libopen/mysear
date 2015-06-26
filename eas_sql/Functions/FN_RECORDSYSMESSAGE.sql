--
-- FN_RECORDSYSMESSAGE  (Function) 
--
CREATE OR REPLACE FUNCTION OUCHNSYS.FN_RecordSysMessage
(
    vMsgScope varchar2,
    vMsgContent varchar2,
    vMsgSource varchar2
)
RETURN NUMBER IS
tmpVar NUMBER;
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
BEGIN
   tmpVar := 1;
   insert into EAS_Sys_Message (SN,MsgScope,MsgContent,CreateTime,MsgSource)
   values(seq_ExmM_Message.nextVal,vMsgScope,vMsgContent,sysdate,vMsgSource);
   RETURN tmpVar;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END FN_RecordSysMessage;
/

