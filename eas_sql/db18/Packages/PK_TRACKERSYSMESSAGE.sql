--
-- PK_TRACKERSYSMESSAGE  (Package) 
--
CREATE OR REPLACE PACKAGE OUCHNSYS.PK_TrackerSysMessage AS
/******************************************************************************
   NAME:       PK_SysMessage
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015/5/11      Administrator       1. Created this package.
******************************************************************************/

  procedure InsertTrackerMessage(msgScope varchar2,msgContent varchar2,msgSource varchar2);

END PK_TrackerSysMessage;
/

