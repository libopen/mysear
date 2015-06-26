--
-- PK_TRACKERSYSMESSAGE  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_TrackerSysMessage AS
    procedure InsertTrackerMessage(msgScope varchar2,msgContent varchar2,msgSource varchar2)
    is
    begin
    insert into EAS_Sys_Message (SN,MsgScope,MsgContent,CreateTime,MsgSource)values(seq_ExmM_Message.nextval,msgScope,msgContent,sysdate,msgSource); 
    end;
end PK_TrackerSysMessage;
/

