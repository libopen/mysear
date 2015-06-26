--
-- PK_ELC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY OUCHNSYS.PK_ELC AS
/******************************************************************************
   NAME:       PK_ELC
   PURPOSE:   返回给定学生课程信息在指定选课批次下的结果 如果次数为－1表示当前选课批次下已经存在选课其它为当前是第N次选课

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014/06/11      libin       1. Created this package body.
******************************************************************************/

  FUNCTION FN_ELC_GETCURRENTELCINFO(i_ELC_XML IN CLOB,i_ELCBATCHCODE IN VARCHAR2) RETURN MTB_STUDENTELC IS
  --xml 
   x_Xmlpar          xmlparser.parser := xmlparser.newparser;  
   x_Doc             xmldom.domdocument;
   x_RowsetNodes     xmldom.domnodelist;
   x_RowNode         XMLDOM.DOMNODE ;
   x_RowChildNodes   xmldom.domnodelist;
   x_RowCount        number;
   --business
   l_sql             varchar2(1000);
   l_StudentCode     EAS_ELC_STUDENTELCINFO.STUDENTCODE %type; 
   l_CourseID        EAS_ELC_STUDENTELCINFO.COURSEID %type;
   l_StudentID       EAS_ELC_STUDENTELCINFO.STUDENTID %type;
   l_cs              number; --当前已经选课总数
   l_cc              number; --当前批次选课次数
   
   v_MTB_STUDENTELC MTB_STUDENTELC  := new MTB_STUDENTELC(); 
  BEGIN
     xmlparser.parseclob (x_Xmlpar, i_ELC_XML);  
     x_doc := xmlparser.getdocument (x_Xmlpar);  
  
   -- 释放解析器实例  
    xmlparser.freeparser (x_Xmlpar);  
  ---取总选课记录
     x_RowsetNodes := xmldom.getelementsbytagname (x_doc, 'ROW');
     x_RowCount    :=  xmldom.getlength(x_RowsetNodes);
     
    FOR i in 0..x_RowCount-1
     LOOP
     x_RowNode := xmldom.item (x_RowsetNodes, i);  
     -- 获取子元素的值  ROW中的记录
      x_RowChildNodes := xmldom.getchildnodes (x_RowNode);  
     
      l_StudentCode := xmldom.getNodeValue(XMLDOM.GETFIRSTCHILD (XMLDOM.ITEM (x_RowChildNodes,0)));
      l_CourseID := xmldom.getNodeValue(XMLDOM.GETFIRSTCHILD (XMLDOM.ITEM (x_RowChildNodes,1)));
      l_StudentID := xmldom.getNodeValue(XMLDOM.GETFIRSTCHILD (XMLDOM.ITEM (x_RowChildNodes,2)));
       l_sql :='select  count(*) cs,sum(case when batchcode='''||i_ELCBATCHCODE ||''' then 1 else 0 end) cc from  eas_elc_studentelcinfo where studentcode='''||l_StudentCode ||''' and courseid='''||l_CourseID || '''';
      --dbms_output.put_line(l_sql);
      execute immediate l_sql 
       into l_cs,l_cc;
      dbms_output.put_line(l_StudentID ||'-'|| l_StudentCode||'-'||l_CourseID||'-'||l_cs||'-'||l_cc);
        v_MTB_STUDENTELC.extend;
        if l_cc =1 then  -- 当前批次有记录
        v_MTB_STUDENTELC(v_MTB_STUDENTELC.count) := MROW_STUDENTELC(l_StudentID,l_StudentCode,l_CourseID,-1);
        else
        v_MTB_STUDENTELC(v_MTB_STUDENTELC.count) := MROW_STUDENTELC(l_StudentID,l_StudentCode,l_CourseID,l_cs+1);
        end if;
         
     END LOOP;
      xmldom.freedocument (x_doc);
   return   v_MTB_STUDENTELC;
   EXCEPTION  
    WHEN OTHERS  
     THEN  
      DBMS_OUTPUT.put_line (SQLERRM);  
  END;
  
  
  /*  开课*/
  PROCEDURE PR_ELC_OPENCOURSE(i_ELC_XML in CLOB,i_ElcBatchCode in EAS_ELC_STUDENTELCINFO.BATCHCODE%type ,i_ClassCode in EAS_ELC_STUDENTELCINFO.CLASSCODE%type ,i_ElcType in EAS_ELC_STUDENTELCINFO.ElcType%type  ,i_LearnCenterCode in EAS_ELC_STUDENTELCINFO.LEARNINGCENTERCODE %type,i_IsPlan in EAS_ELC_STUDENTELCINFO.ISPLAN %type,i_Operator in EAS_ELC_STUDENTELCINFO.OPERATOR %type,i_spycode in EAS_ELC_STUDENTELCINFO.SPYCODE %type,i_IsApplyExam in EAS_ELC_STUDENTELCINFO.ISAPPLYEXAM %type,oReturn out varchar2) 
  IS
  BEGIN
    insert into EAS_Elc_StudentElcInfo(
            SN,Batchcode,LearningCenterCode           ,classcode,isPlan
      ,Operator,ElcState,OperateTime,SpyCode   ,IsApplyExam  ,ElcType    ,refid
      ,StudentCode,CourseID,StudentID,CurrentSelectNumber)
      select sys_guid,i_ElcBatchCode,i_LearnCenterCode,i_ClassCode,i_IsPlan
      ,i_Operator,'0'   ,sysdate    ,i_spycode ,i_IsApplyExam,i_ElcType,seq_Elc_StudentElc.nextval
      ,StudentCode,CourseID,StudentID ,CurrentSelectNumber
      from  table( FN_ELC_GETCURRENTELCINFO(i_ELC_XML, I_ELCBATCHCODE )) a where currentselectnumber>0;
      
    oReturn :='';
    for rw in (select studentcode from table( FN_ELC_GETCURRENTELCINFO(i_ELC_XML, I_ELCBATCHCODE )) where currentselectnumber=-1  ) LOOP
     oReturn := oReturn || rw.studentcode || ',';
      --DBMS_OUTPUT.put_line(rw.studentcode);
    END LOOP;
  /* 返回不能开课的记录*/
   EXCEPTION 
    WHEN OTHERS  
     THEN  
     oReturn :='EXCEPTION';
      DBMS_OUTPUT.put_line (SQLERRM);  
  END PR_ELC_OpenCourse;

  PROCEDURE PR_ELC_OPENCOURSE2(i_ELC_XML in clob,oReturn out varchar2)IS 
   
   
  BEGIN
   
    oReturn :='OK';
     --oReturn :='';
    for rw in (select studentcode from table( FN_ELC_GETCURRENTELCINFO(i_ELC_XML, '200703' )) where currentselectnumber=-1  ) LOOP
     oReturn := oReturn || rw.studentcode || ',';
     END LOOP;
  /* 返回不能开课的记录*/
   EXCEPTION 
    WHEN OTHERS  
     THEN  
     oReturn :='error';
      DBMS_OUTPUT.put_line (SQLERRM);  
  END PR_ELC_OpenCourse2;
  
  
  --选课确认
PROCEDURE PR_ELC_ConfirmSelectedCourses(inConfirmOparator in varchar,inBatchCode in varchar,inStudentCode in varchar,inCourseID  in  varchar,inMutexCourseID in varchar,inLearningCenterCode in varchar,outUpdatedCount out int)
IS
curNumber int;
muxNumber int;
isConfirmed  int;
isExistStatus int;
Begin
    curNumber := 0;
    muxNumber := 0;
    isConfirmed := 0;
   --查询出该学生的选课数量
   select count(*) into curNumber from EAS_ELC_STUDENTELCINFO sei where SEI.STUDENTCODE=inStudentCode and SEI.LEARNINGCENTERCODE=inLearningCenterCode and CourseID=inCourseID;
   --互斥课的选课数量
   if inMutexCourseID is not null then
   select count(*) into muxNumber from EAS_ELC_STUDENTELCINFO sei where SEI.STUDENTCODE=inStudentCode and SEI.LEARNINGCENTERCODE=inLearningCenterCode and CourseID in (inMutexCourseID);
   end if;
   
   curNumber := curNumber + muxNumber;
   curNumber := curNumber + 1;
   
   select count(*) into isConfirmed from EAS_ELC_STUDENTELCINFO sei where CONFIRMSTATE='1'
   and CourseID = inCourseID 
   and StudentCode = inStudentCode 
   and BatchCode = inBatchCode 
   and LearningCenterCode = inLearningCenterCode;
   
   if isConfirmed = 0 then
       update EAS_Elc_StudentElcInfo set CONFIRMSTATE='1',ConfirmOperator=inConfirmOparator,CONFIRMTIME=sysdate,
       CurrentSelectNumber = curNumber
       where CourseID = inCourseID 
       and StudentCode = inStudentCode 
       and BatchCode = inBatchCode 
       and LearningCenterCode = inLearningCenterCode;
       outUpdatedCount := sql%rowcount;
       
       --记录学生选课状态
       select count(1) into isExistStatus from EAS_ELC_STUDENTSTUDYSTATUS where studentCode=inStudentCode and CourseID =InCourseID;
       if isExistStatus =0 then
        insert into EAS_ELC_STUDENTSTUDYSTATUS(SN,STUDENTCODE,COURSEID,STUDYSTATUS) values(seq_Elc_StudentStudyStatus.nextval,inStudentCode,inCourseID,'1');
       else
        update EAS_ELC_STUDENTSTUDYSTATUS set STUDYSTATUS='1' where studentCode=inStudentCode and CourseID =InCourseID;
       end if;
       else
       outUpdatedCount :=0;
   end if;
   commit;
   Exception
   when others then
   raise;


END PR_ELC_ConfirmSelectedCourses;



  --通过班级删除选课信息
PROCEDURE  PR_ELC_DelUnCfmCoursesByClass(InIsPlan in varchar2,inBatchCode in varchar2,inLearningCenterCode in varchar2,inClassCode in varchar2,outUpdatedCount out int)
IS
strSQL varchar(1000);
Begin
   if InIsPlan ='2' then
    strSQL :='delete from EAS_Elc_StudentElcInfo where ClassCode in('||inClassCode||') and BatchCode = '''||inBatchCode||''' and LearningCenterCode = '''||inLearningCenterCode||''' and (CONFIRMSTATE != ''1'' or CONFIRMSTATE is NULL)';
   else
    strSQL :='delete from EAS_Elc_StudentElcInfo where ClassCode in('||inClassCode||') and isPlan='''||InIsPlan||''' and BatchCode = '''||inBatchCode||''' and LearningCenterCode = '''||inLearningCenterCode||''' and (CONFIRMSTATE != ''1'' or CONFIRMSTATE is NULL)';
   end if;
   DBMS_OUTPUT.put_line(strSQL);  
   execute immediate strSQL;
   outUpdatedCount := sql%rowcount;
   commit;
   
   Exception
   when others then
   rollback;
   raise;
END PR_ELC_DelUnCfmCoursesByClass;


  --通过多个班级删除选课信息
PROCEDURE  PR_DelUnCfmCoursesByClasses(InXml varchar2,OutCount out int)
IS
strSQL varchar2(1000);
x_BatchCode varchar2(100);
x_ClassCode varchar2(100);

--定义xml解析
xmlPar XMLPARSER.parser :=XMLPARSER.NEWPARSER;
doc xmldom.DOMDocument;
--节点
pNodes xmldom.DOMNODELIST;
--临时节点
tempNode XMLDOM.DOMNODE;
--子节点
chilNodes xmldom.DOMNodeList;
--总数
pCount        number;
Begin
--开起解析
   XMLPARSER.PARSECLOB(xmlPar,InXml);
   doc:=XMLPARSER.GETDOCUMENT(xmlPar);
   --释放
   XMLPARSER.FREEPARSER(xmlPar);
   --获取节点
   pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'Entity');
   --获取总数
   pCount := XMLDOM.GETLENGTH(pNodes);
   OutCount :=0;
   FOR i in 0..pCount-1 
   LOOP
    tempNode := XMLDOM.ITEM(pNodes,i);
    chilNodes:=XMLDOM.GETCHILDNODES(tempNode);
    
    x_BatchCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
    x_ClassCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
    
    delete from EAS_Elc_StudentElcInfo where ClassCode = x_ClassCode and BatchCode = x_BatchCode and (CONFIRMSTATE != '1' or CONFIRMSTATE is NULL);
    outCount:=outCount + sql%rowcount;
   end loop;
   commit;
END PR_DelUnCfmCoursesByClasses;

--通过学生删除选课信息
Procedure PR_ELC_DelUnCfmCoursesByStu(InIsPlan in varchar2,inBatchCode in varchar2,inLearningCenterCode in varchar2,inStudentCode in varchar2,inCourseCode in varchar2,outUpdatedCount out int)
IS
strSQL varchar(1000);
Begin
    if inCourseCode is null then
    strSQL := 'delete from EAS_Elc_StudentElcInfo where StudentCode in('||inStudentCode||') and isPlan='''||InIsPlan||''' and BatchCode = '''|| inBatchCode ||''' and LearningCenterCode = '''||inLearningCenterCode||''' and (CONFIRMSTATE != ''1'' or CONFIRMSTATE is NULL)';
   else
    strSQL := 'delete from EAS_Elc_StudentElcInfo where StudentCode in('||inStudentCode||') and CourseID in ('||inCourseCode||') and BatchCode = '''||inBatchCode||''' and LearningCenterCode ='''||inLearningCenterCode||''' and (CONFIRMSTATE != ''1'' or CONFIRMSTATE is NULL)';
   end if;
    execute immediate strSQL;
    outUpdatedCount := sql%rowcount;
    
   commit;
   
   Exception
   when others then
   rollback;
   raise;
end PR_ELC_DelUnCfmCoursesByStu;

--通过REFID删除选课信息
Procedure PR_ELC_DelUnCfmCoursesByREFID(inREFID in varchar,outUpdatedCount out int)
IS
strSQL varchar(1000);
BEGIN
    strSQL :='delete from EAS_Elc_StudentElcInfo where REFID in ('||inREFID||') and (CONFIRMSTATE != ''1'' or CONFIRMSTATE is NULL)';
    execute immediate strSQL;
    outUpdatedCount := sql%rowcount;
    
    Exception
   when others then
   rollback;
   raise;
END PR_ELC_DelUnCfmCoursesByREFID;
END PK_ELC;
/

