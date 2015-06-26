--
-- P_XMLPARSE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.p_xmlparse 
(p_xml   IN     CLOB,  
r_cur      OUT SYS_REFCURSOR)
IS
   -- xml解析器  
   xmlpar          xmlparser.parser := xmlparser.newparser;  
   -- dom文档对象  
   doc             xmldom.domdocument;  
   StudentCoursesnodes   xmldom.domnodelist;  
   StudentCode      VARCHAR2 (50);  
   CourseID      VARCHAR2 (50);
   chilnodes       xmldom.domnodelist;  
   tempnode        xmldom.domnode;  
   temparrmap      xmldom.domnamednodemap;  
  
   -- 以下变量用于获取xml节点的值  
   v_attribute     VARCHAR2 (50);  
   v_value         VARCHAR2 (50);  
   tmp             INTEGER;  
   l_sql           VARCHAR2 (32767) := 'select ';  
   ElcTotalNumber            number;
/******************************************************************************
   NAME:       p_xmlparse
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/16   libin       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     p_xmlparse
      Sysdate:         2014/05/16
      Date and Time:   2014/05/16, 9:33:10, and 2014/05/16 9:33:10
      Username:        libin (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
 
   xmlparser.parseclob (xmlpar, p_xml);  
   doc := xmlparser.getdocument (xmlpar);  
  
   -- 释放解析器实例  
   xmlparser.freeparser (xmlpar);  
  ---取总选课记录
   StudentCoursesnodes := xmldom.getelementsbytagname (doc, 'ElcRecord');  
   
   ElcTotalNumber := xmldom.getlength(StudentCoursesnodes);
   dbms_output.put_line('TotalRecords-->'|| ElcTotalNumber);
   FOR i in 0..ElcTotalNumber-1
   LOOP
     tempnode := xmldom.item (StudentCoursesnodes, i);  
     -- 获取子元素的值  
      chilnodes := xmldom.getchildnodes (tempnode);  
      tmp := xmldom.getlength (chilnodes);
      StudentCode := xmldom.getNodeValue(XMLDOM.GETFIRSTCHILD (XMLDOM.ITEM (chilnodes,0)));
      CourseID := xmldom.getNodeValue(XMLDOM.GETFIRSTCHILD (XMLDOM.ITEM (chilnodes,1)));
       DBMS_OUTPUT.put_line (StudentCode ||' '|| CourseID);  
   END LOOP;
        
   
   -- 释放文档对象  
   xmldom.freedocument (doc);  
EXCEPTION  
   WHEN OTHERS  
   THEN  
      DBMS_OUTPUT.put_line (SQLERRM);  
END p_xmlparse;
/

