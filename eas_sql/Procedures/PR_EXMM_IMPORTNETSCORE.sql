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
--����xml����
xmlPar XMLPARSER.parser :=XMLPARSER.NEWPARSER;
doc xmldom.DOMDocument;
--�ڵ�
pNodes xmldom.DOMNODELIST;
--��ʱ�ڵ�
tempNode XMLDOM.DOMNODE;
--�ӽڵ�
chilNodes xmldom.DOMNodeList;
--����
pCount        number;

v_studentID varchar2(40);
--�������

x_SubjectCode   VARCHAR2(10) ;
x_StudentCode VARCHAR2(20);
x_Score  number;
x_ScoreCode VARCHAR2(10);
x_dblink VARCHAR2(30);
x_CollegeCode VARCHAR2(15);
x_SegmentCode    VARCHAR2(10) ;
--��ѯ��û��ѧ��
v_CountStuSql VARCHAR2(2000);
v_Cou number; 

--��ѯ�Ƿ����
v_IsHaveSql VARCHAR2(2000);
v_IsHave  VARCHAR2(15) ;

v_LearningCenterCode  VARCHAR2(10) ;

v_ClassCode    VARCHAR2(15) ;

v_FullName      VARCHAR2(80) ;

--��ѯ������Ŀ
v_SubjectCodeSql VARCHAR2(2000) ;
v_SubjectCou      NUMBER ;


v_EnrollmentStatus  VARCHAR2(2) ;

--��ѯѧ��
v_ScoreSql VARCHAR(2000);
v_Score VARCHAR(20);

OutTotalCount NUMBER;
BEGIN 
--�������
   XMLPARSER.PARSECLOB(xmlPar,i_XMLSTR);
   doc:=XMLPARSER.GETDOCUMENT(xmlPar);
   --�ͷ�
   XMLPARSER.FREEPARSER(xmlPar);
   --��ȡ�ڵ�
   pNodes:=XMLDOM.GETELEMENTSBYTAGNAME(doc,'r');
   --��ȡ����
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
    --��ɼ�
    v_ScoreSql :='select DicScore from EAS_Dic_ScoreCode where DicCode='''|| x_ScoreCode||'''';
    execute immediate v_ScoreSql into v_Score;
    select count(StudentID) as Cou into v_Cou from EAS_SchRoll_Student where StudentCode =''||x_StudentCode||'';
    
    if v_Cou >0 then
    select StudentID,LearningCenterCode,ClassCode,FullName,EnrollmentStatus into v_studentID,v_LearningCenterCode,v_ClassCode,v_FullName,v_EnrollmentStatus  from EAS_SchRoll_Student where StudentCode =''||x_StudentCode||'';
    
    --�ж�ѧ���Ƿ��ڼ�
    if v_EnrollmentStatus =1 then
        --��ѯ������Ŀ
        v_SubjectCodeSql :='select count(SubjectCode) as SubjectCou from EAS_ExmM_NetExamSubject where SubjectCode='''|| x_SubjectCode ||'''';
            execute immediate v_SubjectCodeSql into v_SubjectCou;
        --�ж�������Ŀ�Ƿ����
        if v_SubjectCou > 0 then
            --�жϷֿ� 112
            if x_dblink = 'ouchn112' then
            --��ѯ��ǰ������������Ŀ�Ƿ����
            v_IsHaveSql :='select count(SN) as HaveCou from EAS_ExmM_NetExamScore@ouchn112 where ExamYear = '''||i_ExamYear||''' and  ExamMonth = '''||i_ExamMonth||''' and SubjectCode = '''||x_SubjectCode||''' and StudentCode = '''||x_StudentCode||''''; 
            execute immediate v_IsHaveSql into v_IsHave;
            --�ж��Ƿ����
            if v_IsHave =0 then
            --���뵼�������ɼ���
            INSERT INTO EAS_EXMM_NETEXAMSCORE@ouchn112
            (SN,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,FullName,Score,ScoreCode,Maintainer,MaintainDate)
            VALUES
            (seq_ExmM_NetExamScore.Nextval@ouchn112,x_SegmentCode,x_CollegeCode,v_LearningCenterCode,v_ClassCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_FullName,v_Score,x_ScoreCode,i_Maintainer,SYSDATE);
            OutTotalCount:=OutTotalCount+1;
            end if;
            --113
            else
            --��ѯ��ǰ������������Ŀ�Ƿ����
            v_IsHaveSql :='select count(SN) as HaveCou from EAS_ExmM_NetExamScore@ouchn112 where ExamYear = '''||i_ExamYear||''' and  ExamMonth = '''||i_ExamMonth||''' and SubjectCode = '''||x_SubjectCode||''' and StudentCode = '''||x_StudentCode||''''; 
            execute immediate v_IsHaveSql into v_IsHave;
            --�ж��Ƿ����
            if v_IsHave =0 then
            --���뵼�������ɼ���
            INSERT INTO EAS_EXMM_NETEXAMSCORE@ouchn113
            (SN,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,FullName,Score,ScoreCode,Maintainer,MaintainDate)
            VALUES
            (seq_ExmM_NetExamScore.Nextval@ouchn113,x_SegmentCode,x_CollegeCode,v_LearningCenterCode,v_ClassCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_FullName,v_Score,x_ScoreCode,i_Maintainer,SYSDATE);
            OutTotalCount:=OutTotalCount+1;
            end if;
            end if;
        else
            --���뵼���������ɹ��� ԭ��������Ŀ������
        INSERT INTO EAS_EXMM_NETEXAMSCORELOST@ouchn112
        (SN,SegmentCode,CollegeCode,LearningCenterCode,ClassCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,FullName,Score,ScoreCode,Maintainer,MaintainDate,Reason)
        VALUES
        (seq_ExmM_NetExamScore.Nextval@ouchn112,x_SegmentCode,x_CollegeCode,v_LearningCenterCode,v_ClassCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_FullName,v_Score,x_ScoreCode,i_Maintainer,SYSDATE,'������Ŀ������');
        end if;
    else
        --���뵼���������ɹ��� ԭ��ѧ�����ڼ�
        INSERT INTO EAS_EXMM_NETEXAMSCORELOST@ouchn112
        (SN,SegmentCode,CollegeCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,Score,ScoreCode,Maintainer,MaintainDate,Reason)
        VALUES
        (seq_ExmM_NetExamScore.Nextval@ouchn112,x_SegmentCode,x_CollegeCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_Score,x_ScoreCode,i_Maintainer,SYSDATE,'ѧ�����ڼ�');
    end if;
    else
    --���뵼���������ɹ��� ԭ��ѧ��������
    INSERT INTO EAS_EXMM_NETEXAMSCORELOST@ouchn112
    (SN,SegmentCode,CollegeCode,ExamYear,ExamMonth,ExamSemester,SubjectCode,StudentCode,Score,ScoreCode,Maintainer,MaintainDate,Reason)
    VALUES
    (seq_ExmM_NetExamScore.Nextval@ouchn112,x_SegmentCode,x_CollegeCode,i_ExamYear,i_ExamMonth,i_ExamSemester,x_SubjectCode,x_StudentCode,v_Score,x_ScoreCode,i_Maintainer,SYSDATE,'ѧ��������');
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

