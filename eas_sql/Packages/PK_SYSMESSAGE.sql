--
-- PK_SYSMESSAGE  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_SysMessage AS
/******************************************************************************
   NAME:       PK_SysMessage
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015/6/8      Administrator       1. Created this package.
******************************************************************************/

--��¼ϵͳ��Ϣ
  Procedure Pr_RecordSysMessage(
    vMsgScope varchar2,
    vMsgContent varchar2,
    vMsgSource varchar2
  );
END PK_SysMessage;
/

