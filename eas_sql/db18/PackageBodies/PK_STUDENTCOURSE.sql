--
-- PK_STUDENTCOURSE  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_STUDENTCOURSE AS
/******************************************************************************
   NAME:       PK_STUDENTCOURSE
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/19      libin       1. Created this package body.
******************************************************************************/

   FUNCTION FN_GETSTUDENTCOURSEINDBBASE(in_XML_ELC IN CLOB) RETURN MTB_StudentElc IS
  
   xmlpar          xmlparser.parser := xmlparser.newparser;  
   -- dom文档对象  
   doc             xmldom.domdocument;  
   StudentCoursesnodes   xmldom.domnodelist;  
   -----student ifno
   v_StudentCode      VARCHAR2 (50);  
   v_CourseID      VARCHAR2 (50);
   v_batchcode varchar2(6);
   v_fullname    varchar2(20);
   v_professionallevel varchar(20);
   v_spyname           varchar2(30);
   v_learnname         varchar2(50);       
   
   -----end student info
   chilnodes       xmldom.domnodelist;  
   tempnode        xmldom.domnode;  
   temparrmap      xmldom.domnamednodemap;  
    
    ElcTotalNumber            number;
    var_mtb_studentelc MTB_StudentElc :=MTB_StudentElc(); 
    strSQL varchar2(500);
/******************************************************************************
   NAME:       FN_GETSTUDENTCOURSEINDBBASE
   PURPOSE:    将从学生选课库返回的记录与基础库数据进行关联查询

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/05/16   libin       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     FN_GETSTUDENTCOURSEINDBBASE
      Sysdate:         2014/05/16
      Date and Time:   2014/05/16, 9:33:10, and 2014/05/16 9:33:10
      Username:        libin (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   xmlparser.parseclob (xmlpar, in_XML_ELC);  
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
      --tmp := xmldom.getlength (chilnodes);
      v_StudentCode := xmldom.getNodeValue(XMLDOM.GETFIRSTCHILD (XMLDOM.ITEM (chilnodes,0)));
      v_CourseID := xmldom.getNodeValue(XMLDOM.GETFIRSTCHILD (XMLDOM.ITEM (chilnodes,1)));
      strSQL := 'select a.batchcode, a.fullname,b.dicname,c.spyname,D3.ORGANIZATIONNAME ' ;
      strSQL := strSQL ||' from EAS_schroll_student a inner join EAs_dic_professionallevel b on a.professionallevel=b.diccode';
      strSQL := strSQL ||' inner join eas_spy_basicinfo c on a.spycode=c.spycode ';
      strSQL := strSQL ||' inner join eas_org_basicinfo d3 on a.learningcentercode=d3.ORGANIZATIONCODE where studentcode='''|| v_StudentCode || '''';
       DBMS_OUTPUT.put_line (strSQL);       
      execute immediate  strSQL into v_batchcode,v_fullname,v_professionallevel,v_spyname,v_learnname;
   
 
      
       DBMS_OUTPUT.put_line (v_StudentCode ||' '|| v_CourseID); 
       var_mtb_studentelc.extend;
       
       var_mtb_studentelc(var_mtb_studentelc.count):= mRow_StudentElc2(v_batchcode,v_StudentCode,v_fullname,v_professionallevel,v_spyname,v_learnname,v_CourseID);
       
   END LOOP;
        
   
   -- 释放文档对象  
   xmldom.freedocument (doc);
   return   var_mtb_studentelc;
EXCEPTION  
   WHEN OTHERS  
   THEN  
      DBMS_OUTPUT.put_line (SQLERRM);  
END FN_GETSTUDENTCOURSEINDBBASE;
 

  

END PK_STUDENTCOURSE;
/

