--
-- PR_EXMM_IMPORTNETSCORETEST  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_EXMM_IMPORTNETSCORETEST(
    i_XMLSTR VARCHAR2,
    i_ExamYear VARCHAR2,
    i_ExamMonth VARCHAR2 ,
    i_ExamSemester VARCHAR2,
    i_Maintainer  VARCHAR2 ,
    RETCODE out int)
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

--TYPE stu_info IS REF CURSOR;
--sInfo stu_info; --定义游标变量
--sInfoSql varchar(2000);
--插入参数

x_SubjectCode   VARCHAR2(10) ;
x_StudentCode VARCHAR2(20);
x_Score  number;
x_ScoreCode VARCHAR2(10);
x_dblink VARCHAR2(30);
x_CollegeCode VARCHAR2(15);

v_CountStuSql VARCHAR2(2000);
v_Cou number; 

v_SegmentCodeSql VARCHAR2(2000);
v_SegmentCode    VARCHAR2(10) ;


v_IsHaveSql VARCHAR2(2000);

v_IsHave  VARCHAR2(15) ;

--v_LearningCenterCodeSql  VARCHAR2(2000);
v_LearningCenterCode  VARCHAR2(10);

--v_ClassCodeSql    VARCHAR2(2000) ;
v_ClassCode    VARCHAR2(15) ;

--v_FullNameSql VARCHAR2(2000) ;
v_FullName      VARCHAR2(80) ;


v_SubjectCodeSql VARCHAR2(2000) ;
v_SubjectCou      NUMBER ;


--查询学籍状态
--v_EnrollmentStatusSql VARCHAR2(2000);
v_EnrollmentStatus  VARCHAR2(2) ;

v_ScoreSql VARCHAR(2000);
v_Score VARCHAR(20);

v_SNSql VARCHAR2(200);
v_SN NUMBER;
OutTotalCount NUMBER;
v_start number;
v_end   number;
BEGIN 
v_start := dbms_utility.get_time;
--开起解析
   XMLPARSER.PARSECLOB(xmlPar,i_XMLSTR);
   doc:=XMLPARSER.GETDOCUMENT(xmlPar);
   --释放
   XMLPARSER.FREEPARSER(xmlPar);
   --获取节点
   pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'r');
   --获取总数
   pCount := XMLDOM.GETLENGTH(pNodes);
   OutTotalCount :=0;
   FOR i in 0..pCount-1 
   LOOP
    tempNode := XMLDOM.ITEM(pNodes,i);
    chilNodes:=XMLDOM.GETCHILDNODES(tempNode);
    
    x_SubjectCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,0)));
    x_ScoreCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,1)));
    x_StudentCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,2)));
    x_CollegeCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
    --x_dblink := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,4)));
    
    --查成绩
    --v_ScoreSql :='select DicScore from EAS_Dic_ScoreCode where DicCode='''|| x_ScoreCode||'''';
    --execute immediate v_ScoreSql into v_Score;
    

    --判断有没有学生
    v_CountStuSql :='select count(StudentID) as cou from EAS_SchRoll_Student where StudentCode ='''||x_StudentCode||'''';
    execute immediate v_CountStuSql into v_Cou;
    v_SNSql :='select seq_ExmM_NetExamScore.Nextval@ouchn112 as SN  from dual'; 
                execute immediate v_SNSql into v_SN;
    INSERT INTO EAS_ExmM_NetExamScore@ouchn112 
    (SN,SubjectCode,StudentCode,CollegeCode,ScoreCode,ExamYear,ExamMonth,ExamSemester,Maintainer,MaintainDate)
    values (seq_ExmM_NetExamScore.Nextval@ouchn112,x_SubjectCode,x_StudentCode,x_CollegeCode,x_ScoreCode,i_ExamYear,i_ExamMonth,i_ExamSemester,i_Maintainer,SYSDATE);
    --COMMIT;
    OutTotalCount:=OutTotalCount+SQL%ROWCOUNT;
   
   END LOOP;
   v_end := dbms_utility.get_time;
   DBMS_OUTPUT.PUT_LINE(v_end-v_start);
   --CLOSE sInfo;
   XMLDOM.FREEDOCUMENT(doc);
   RETCODE :=OutTotalCount;
   EXCEPTION
   WHEN OTHERS THEN 
   DBMS_OUTPUT.PUT_LINE(SQLERRM);
END PR_EXMM_IMPORTNETSCORETEST;
/

