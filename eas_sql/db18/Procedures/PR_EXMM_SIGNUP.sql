--
-- PR_EXMM_SIGNUP  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_EXMM_SIGNUP(
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

--插入参数

x_SubjectCode   VARCHAR2(10) ;
x_StudentCode VARCHAR2(20);
x_Score  number;
x_ScoreCode VARCHAR2(10);
x_dblink VARCHAR2(15);
x_CollegeCode VARCHAR2(15);

v_CountStuSql VARCHAR2(2000);
v_Cou number; 

v_SegmentCodeSql VARCHAR2(2000);
v_SegmentCode    VARCHAR2(10) ;

--v_CollegeCodeSql VARCHAR2(2000);
--v_CollegeCode  VARCHAR2(15) ;

v_LearningCenterCodeSql  VARCHAR2(2000);
v_LearningCenterCode  VARCHAR2(10);

v_ClassCodeSql    VARCHAR2(2000) ;
v_ClassCode    VARCHAR2(15) ;

v_FullNameSql VARCHAR2(2000) ;
v_FullName      VARCHAR2(80) ;

v_SubjectCodeSql VARCHAR2(2000) ;
v_SubjectCou      NUMBER ;

v_IsExptNetExam    NUMBER ;
v_IsRecord  NUMBER ;
v_IsReplaceDegreeCourse  NUMBER;

--查询学籍状态
v_EnrollmentStatusSql VARCHAR2(2000);
v_EnrollmentStatus  VARCHAR2(2) ;

v_ScoreSql VARCHAR(2000);
v_Score VARCHAR(20);

v_SNSql VARCHAR2(200);
v_SN NUMBER;
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

    
    --查学习中心代码根据学号
    v_LearningCenterCodeSql :='select LearningCenterCode from EAS_SchRoll_Student where StudentCode ='||x_StudentCode;
    execute immediate v_LearningCenterCodeSql into v_LearningCenterCode;

    --查学院代码根据学习中心
    --v_CollegeCodeSql :='select ParentCode from EAS_Org_BasicInfo where OrganizationCode ='||v_LearningCenterCode;
    --execute immediate v_CollegeCodeSql into v_CollegeCode;

    --查分部代码根据学院
    v_SegmentCodeSql :='select ParentCode from EAS_Org_BasicInfo where OrganizationCode ='||x_CollegeCode;
    execute immediate v_SegmentCodeSql into v_SegmentCode;

    --查班代码根据学号
    v_ClassCodeSql :='select ClassCode from EAS_SchRoll_Student where StudentCode ='||x_StudentCode;
    execute immediate v_ClassCodeSql into v_ClassCode;

    --查姓名根据学号
    v_FullNameSql :='select FullName from EAS_SchRoll_Student where StudentCode ='||x_StudentCode;
    execute immediate v_FullNameSql into v_FullName;

    --查网考科目是否存在
    v_SubjectCodeSql :='select count(SubjectCode) as SubjectCou from EAS_ExmM_NetExamSubject where SubjectCode='|| x_SubjectCode;
    execute immediate v_SubjectCodeSql into v_SubjectCou;
    
    --查成绩
    v_ScoreSql :='select DicScore from EAS_Dic_ScoreCode where DicCode='|| x_ScoreCode;
    execute immediate v_ScoreSql into v_Score;

    --判断有没有学生
    v_CountStuSql :='select count(StudentID) as cou from EAS_SchRoll_Student where StudentCode ='||x_StudentCode;
    execute immediate v_CountStuSql into v_Cou;

    if v_Cou > 0 then 
    --查询学生学籍状态
    v_EnrollmentStatusSql :='select EnrollmentStatus from EAS_ExmM_NetExamSubjectCourse where StudentCode ='||x_StudentCode;
        execute immediate v_EnrollmentStatusSql into v_EnrollmentStatus;
    if v_EnrollmentStatus = 1 then
        if v_SubjectCou > 0 then
        if x_dblink = 'ouchn112' then
            v_SNSql :='select seq_ExmM_NetExamScore.Nextval@ouchn112 as SN  from dual'; 
            execute immediate v_SNSql into v_SN;
            INSERT INTO EAS_ExmM_NetExamScore@ouchn112
            (SN,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,FullName,Score,ScoreCode,Maintainer,MaintainDate)
            VALUES
            (v_SN,v_SegmentCode,x_CollegeCode,v_LearningCenterCode,v_ClassCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_FullName,v_Score,x_ScoreCode,i_Maintainer,SYSDATE);
        else
            v_SNSql :='select seq_ExmM_NetExamScore.Nextval@ouchn113 as SN  from dual'; 
            execute immediate v_SNSql into v_SN;
            INSERT INTO EAS_ExmM_NetExamScore@ouchn113
            (SN,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,FullName,Score,ScoreCode,Maintainer,MaintainDate)
            VALUES (v_SN,v_SegmentCode,x_CollegeCode,v_LearningCenterCode,v_ClassCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_FullName,v_Score,x_ScoreCode,i_Maintainer,SYSDATE);
        end if;
        else
            v_SNSql :='select seq_ExmM_NetExamScore.Nextval@ouchn112 as SN  from dual'; 
            execute immediate v_SNSql into v_SN;
            INSERT INTO EAS_ExmM_NetExamScoreLost@ouchn112
        (SN,ExamYear,ExamMonth,CollegeCode,ExamSemester,SubjectCode,StudentCode,Maintainer,MaintainDate,Reason,LearningCenterCode,FullName,SegmentCode,ScoreCode)
        VALUES(v_SN,i_ExamYear,i_ExamMonth,x_CollegeCode,i_ExamSemester,x_SubjectCode,x_StudentCode,i_Maintainer,SYSDATE,'网考科目不存在',v_LearningCenterCode,v_FullName,v_SegmentCode,x_ScoreCode);
        end if;
    
    else
        v_SNSql :='select seq_ExmM_NetExamScore.Nextval@ouchn112 as SN  from dual'; 
        execute immediate v_SNSql into v_SN;
        INSERT INTO EAS_ExmM_NetExamScoreLost@ouchn112
        (SN,ExamYear,ExamMonth,CollegeCode,ExamSemester,SubjectCode,StudentCode,Maintainer,MaintainDate,Reason,LearningCenterCode,FullName,SegmentCode,ScoreCode,Score)
        VALUES(v_SN,i_ExamYear,i_ExamMonth,x_CollegeCode,i_ExamSemester,x_SubjectCode,x_StudentCode,i_Maintainer,SYSDATE,'学生不在籍',v_LearningCenterCode,v_FullName,v_SegmentCode,x_ScoreCode,v_Score);
    end if;

    else
    --插入导入不成功表 原因 学生不存在
    v_SNSql :='select seq_ExmM_NetExamScore.Nextval@ouchn112 as SN  from dual'; 
    execute immediate v_SNSql into v_SN;
    INSERT INTO EAS_ExmM_NetExamScoreLost@ouchn112 
    (SN,ExamYear,ExamMonth,CollegeCode,ExamSemester,SubjectCode,StudentCode,Maintainer,MaintainDate,Reason,Score)
    VALUES(v_SN,i_ExamYear,i_ExamMonth,x_CollegeCode,i_ExamSemester,x_SubjectCode,x_StudentCode,i_Maintainer,SYSDATE,'学号不存在',v_Score);
    end if;
    COMMIT;
    OutTotalCount:=OutTotalCount+1;
   
   END LOOP;
       
   XMLDOM.FREEDOCUMENT(doc);
   EXCEPTION
   WHEN OTHERS THEN 
   DBMS_OUTPUT.PUT_LINE(SQLERRM);
END PR_EXMM_SIGNUP;
/

