--
-- PR_EXMM_IMPORTNETSCORE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_EXMM_IMPORTNETSCORE(
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

v_studentID varchar2(40);
--插入参数

x_SubjectCode   VARCHAR2(10) ;
x_StudentCode VARCHAR2(20);
x_Score  number;
x_ScoreCode VARCHAR2(10);
x_dblink VARCHAR2(30);
x_CollegeCode VARCHAR2(15);
x_SegmentCode    VARCHAR2(10) ;
--查询有没有学生
v_CountStuSql VARCHAR2(2000);
v_Cou number; 

--查询是否导入过
v_IsHaveSql VARCHAR2(2000);
v_IsHave  VARCHAR2(15) ;

v_LearningCenterCode  VARCHAR2(10) ;

v_ClassCode    VARCHAR2(15) ;

v_FullName      VARCHAR2(80) ;

--查询网考科目
v_SubjectCodeSql VARCHAR2(2000) ;
v_SubjectCou      NUMBER ;


v_EnrollmentStatus  VARCHAR2(2) ;

--查询学分
v_ScoreSql VARCHAR(2000);
v_Score VARCHAR(20);

OutTotalCount NUMBER;
BEGIN 
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
    x_dblink := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,4)));
    x_SegmentCode :=XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,5)));
    --查成绩
    v_ScoreSql :='select DicScore from EAS_Dic_ScoreCode where DicCode='''|| x_ScoreCode||'''';
    execute immediate v_ScoreSql into v_Score;
    select count(StudentID) as Cou into v_Cou from EAS_SchRoll_Student where StudentCode =''||x_StudentCode||'';
    
    if v_Cou >0 then
    select StudentID,LearningCenterCode,ClassCode,FullName,EnrollmentStatus into v_studentID,v_LearningCenterCode,v_ClassCode,v_FullName,v_EnrollmentStatus  from EAS_SchRoll_Student where StudentCode =''||x_StudentCode||'';
    
    --判断学生是否在籍
    if v_EnrollmentStatus =1 then
        --查询网考科目
        v_SubjectCodeSql :='select count(SubjectCode) as SubjectCou from EAS_ExmM_NetExamSubject where SubjectCode='''|| x_SubjectCode ||'''';
            execute immediate v_SubjectCodeSql into v_SubjectCou;
        --判断网考科目是否存在
        if v_SubjectCou > 0 then
            --判断分库 112
            if x_dblink = 'ouchn112' then
            --查询当前条件下网考科目是否导入过
            v_IsHaveSql :='select count(SN) as HaveCou from EAS_ExmM_NetExamScore@ouchn112 where ExamYear = '''||i_ExamYear||''' and  ExamMonth = '''||i_ExamMonth||''' and SubjectCode = '''||x_SubjectCode||''' and StudentCode = '''||x_StudentCode||''''; 
            execute immediate v_IsHaveSql into v_IsHave;
            --判断是否导入过
            if v_IsHave =0 then
            --插入导入网考成绩表
            INSERT INTO EAS_EXMM_NETEXAMSCORE@ouchn112
            (SN,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,FullName,Score,ScoreCode,Maintainer,MaintainDate)
            VALUES
            (seq_ExmM_NetExamScore.Nextval@ouchn112,x_SegmentCode,x_CollegeCode,v_LearningCenterCode,v_ClassCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_FullName,v_Score,x_ScoreCode,i_Maintainer,SYSDATE);
            OutTotalCount:=OutTotalCount+1;
            end if;
            --113
            else
            --查询当前条件下网考科目是否导入过
            v_IsHaveSql :='select count(SN) as HaveCou from EAS_ExmM_NetExamScore@ouchn112 where ExamYear = '''||i_ExamYear||''' and  ExamMonth = '''||i_ExamMonth||''' and SubjectCode = '''||x_SubjectCode||''' and StudentCode = '''||x_StudentCode||''''; 
            execute immediate v_IsHaveSql into v_IsHave;
            --判断是否导入过
            if v_IsHave =0 then
            --插入导入网考成绩表
            INSERT INTO EAS_EXMM_NETEXAMSCORE@ouchn113
            (SN,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,FullName,Score,ScoreCode,Maintainer,MaintainDate)
            VALUES
            (seq_ExmM_NetExamScore.Nextval@ouchn113,x_SegmentCode,x_CollegeCode,v_LearningCenterCode,v_ClassCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_FullName,v_Score,x_ScoreCode,i_Maintainer,SYSDATE);
            OutTotalCount:=OutTotalCount+1;
            end if;
            end if;
        else
            --插入导入网考不成功表 原因网考科目不存在
        INSERT INTO EAS_EXMM_NETEXAMSCORELOST@ouchn112
        (SN,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,FullName,Score,ScoreCode,Maintainer,MaintainDate,Reason)
        VALUES
        (seq_ExmM_NetExamScore.Nextval@ouchn112,x_SegmentCode,x_CollegeCode,v_LearningCenterCode,v_ClassCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_FullName,v_Score,x_ScoreCode,i_Maintainer,SYSDATE,'网考科目不存在');
        end if;
    else
        --插入导入网考不成功表 原因学生不在籍
        INSERT INTO EAS_EXMM_NETEXAMSCORELOST@ouchn112
        (SN,SegmentCode,CollegeCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,Score,ScoreCode,Maintainer,MaintainDate,Reason)
        VALUES
        (seq_ExmM_NetExamScore.Nextval@ouchn112,x_SegmentCode,x_CollegeCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_Score,x_ScoreCode,i_Maintainer,SYSDATE,'学生不在籍');
    end if;
    else
    --插入导入网考不成功表 原因学生不存在
    INSERT INTO EAS_EXMM_NETEXAMSCORELOST@ouchn112
    (SN,SegmentCode,CollegeCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,Score,ScoreCode,Maintainer,MaintainDate,Reason)
    VALUES
    (seq_ExmM_NetExamScore.Nextval@ouchn112,x_SegmentCode,x_CollegeCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_Score,x_ScoreCode,i_Maintainer,SYSDATE,'学生不存在');
    end if;
    
    COMMIT;
    
   END LOOP;
   XMLDOM.FREEDOCUMENT(doc);
   RETCODE :=OutTotalCount;
   EXCEPTION
   WHEN OTHERS THEN 
   DBMS_OUTPUT.PUT_LINE(SQLERRM);
END PR_EXMM_IMPORTNETSCORE;
/

