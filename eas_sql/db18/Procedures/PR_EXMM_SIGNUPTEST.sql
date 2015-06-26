--
-- PR_EXMM_SIGNUPTEST  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_EXMM_SIGNUPTEST(
    InSignUpXml VARCHAR2,
    InExamBatchCode VARCHAR2,
    InExamPlanCode VARCHAR2 ,
    --InExamCategoryCode VARCHAR2,
    InSegmentCode  VARCHAR2 ,
    InLearningCenterCode   VARCHAR2 ,
    InApplicant     NVARCHAR2 ,
    InSignUpType    NUMBER ,
    OutTotalCount out int)
is 
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

--插入参数
x_AssessMode    VARCHAR2(10) ;
x_ExamSiteCode  VARCHAR2(10) ;
x_CourseID  VARCHAR2(10);
x_CourseName    VARCHAR2(80) ;
x_TCPCode   VARCHAR2(15) ;
x_ClassCode VARCHAR2(15);
x_StudentCode      VARCHAR2(20) ;
x_ExamUnit  NVARCHAR2(50);
x_RefID    number ;
x_ExamPaperCode VARCHAR2(10);
x_ExamPaperMemo VARCHAR2(200);
x_CollegeCode VARCHAR2(15);
x_ExamCategoryCode VARCHAR2(3);
x_ExamSessionUnit VARCHAR2(3) ;
x_SN number;

BEGIN 
--开起解析
   XMLPARSER.PARSECLOB(xmlPar,InSignUpXml);
   doc:=XMLPARSER.GETDOCUMENT(xmlPar);
   --释放
   XMLPARSER.FREEPARSER(xmlPar);
   --获取节点
   pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'Entity');
   --获取总数
   pCount := XMLDOM.GETLENGTH(pNodes);
   OutTotalCount :=0;
   FOR i in 0..pCount-1 
   LOOP
    tempNode := XMLDOM.ITEM(pNodes,i);
    chilNodes:=XMLDOM.GETCHILDNODES(tempNode);
     
    x_AssessMode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
    x_ExamSiteCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
    x_CourseID := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2)));
    x_CourseName := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
    x_TCPCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,4)));
    x_ClassCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,5)));
    x_StudentCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,6)));
    x_ExamUnit := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,7)));
    x_RefID := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,8)));
    x_ExamPaperCode :=XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,9)));
    x_ExamPaperMemo :=XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,10)));
    x_CollegeCode :=XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,11)));
    x_ExamCategoryCode :=XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,12)));
    x_ExamSessionUnit :=XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,13)));
    --
    select SN into x_SN from EAS_EXMM_SIGNUP where ExamPlanCode = ''||InExamPlanCode||'' and ExamCategoryCode =''||x_ExamCategoryCode||'' and StudentCode = ''||x_StudentCode||'' and CourseID = ''||x_CourseID||'' and TCPCode = ''||x_TCPCode||'' and ELC_RefID = ''||x_refID||'';
    if x_SN is null then
    INSERT INTO EAS_EXMM_SIGNUP (SN,ExamBatchCode,ExamPlanCode,ExamCategoryCode,AssessMode,ExamSiteCode,ExamPaperCode,ExamSessionUnit,ExamPaperMemo,CourseID,CourseName,TCPCode,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,StudentCode,ExamUnit,ELC_RefID,Applicant,ApplicatDate,SignUpType,IsConfirm) 
    VALUES(seq_ExmM_SignUp.nextval,InExamBatchCode,InExamPlanCode,x_ExamCategoryCode,x_AssessMode,x_ExamSiteCode,x_ExamPaperCode,x_ExamSessionUnit,x_ExamPaperMemo,x_CourseID,x_CourseName,x_TCPCode,InSegmentCode,x_CollegeCode,InLearningCenterCode,x_ClassCode,x_StudentCode,x_ExamUnit,x_RefID,InApplicant,SYSDATE,InSignUpType,0); 
    COMMIT;
    OutTotalCount:=OutTotalCount+1;
    end if;
   END LOOP;
       
   XMLDOM.FREEDOCUMENT(doc);
   EXCEPTION
   WHEN OTHERS THEN 
   DBMS_OUTPUT.PUT_LINE(SQLERRM);
END PR_EXMM_SIGNUPTEST;
/

