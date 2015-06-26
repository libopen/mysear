--
-- PR_EXMM_IMPORTNETSCORE  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OUCHNSYS.PR_EXMM_IMPORTNETSCORE(
    i_XMLSTR VARCHAR2,
    i_UnifBatchCode VARCHAR2,
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

--TYPE stu_info IS REF CURSOR;
--sInfo stu_info; --�����α����
--sInfoSql varchar(2000);
--�������

x_SubjectCode   VARCHAR2(10) ;
x_StudentCode VARCHAR2(20);
x_Score  number;
x_ScoreCode VARCHAR2(10);
x_dblink VARCHAR2(30);
x_SegmentCode VARCHAR2(15);

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


--��ѯѧ��״̬
--v_EnrollmentStatusSql VARCHAR2(2000);
v_EnrollmentStatus  VARCHAR2(2) ;

v_ScoreSql VARCHAR(2000);
v_Score VARCHAR(20);

v_SNSql VARCHAR2(200);
v_SN NUMBER;
OutTotalCount NUMBER;

v_start number;
v_end   number;

v_Maintaindate date;
BEGIN 
v_start := dbms_utility.get_time;
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
    x_SegmentCode := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,3)));
    --x_dblink := XMLDOM.GETNODEVALUE(XMLDOM.GETFIRSTCHILD(XMLDOM.ITEM(chilNodes,4)));
    
    --��ɼ�
    --v_ScoreSql :='select DicScore from EAS_Dic_ScoreCode@ouchnbase where DicCode='''|| x_ScoreCode||'''';
    --execute immediate v_ScoreSql into v_Score;
    

    --�ж���û��ѧ��
    --v_CountStuSql :='select count(StudentID) as cou from EAS_SchRoll_Student@ouchnbase where StudentCode ='''||x_StudentCode||'''';
    --execute immediate v_CountStuSql into v_Cou;
    v_Maintaindate:=sysdate;
    
    /*old
    insert into eas_exmm_netExamScore (SN,SubjectCode,StudentCode,SegmentCode,ScoreCode,UnifBatchCode,Maintainer,MaintainDate)
    values (seq_ExmM_NetExamScore.Nextval,x_SubjectCode,x_StudentCode,x_SegmentCode,x_ScoreCode,i_UnifBatchCode,i_Maintainer,v_Maintaindate);
    
    
    --COMMIT;
    OutTotalCount:=OutTotalCount+SQL%ROWCOUNT;
    */
    
    insert into TMP_ExmM_NetExamScore 
           (sn,SubjectCode ,StudentCode  ,SegmentCode   ,ScoreCode  ,UnifBatchCode  ,Maintainer,MaintainDate)
    select seq_ExmM_NetExamScore.Nextval,x_SubjectCode,x_StudentCode,x_SegmentCode,x_ScoreCode,i_UnifBatchCode,i_Maintainer,v_Maintaindate
    from dual where x_SubjectCode is not null and x_StudentCode is not null
    and not exists(select * from TMP_ExmM_NetExamScore where studentcode=x_StudentCode and subjectcode=x_StudentCode and  
    UnifBatchCode=i_UnifBatchCode);
      
   
   END LOOP;
   
   merge into TMP_ExmM_NetExamScore aa 
   using eas_schroll_student@ouchnbase bb on (aa.studentcode=bb.studentcode)
    when  MATCHED THEN
       update set CollegeCode=substr(bb.LearningCenterCode,1,5),LearningCenterCode=bb.LearningCenterCode
           ,ClassCode=bb.ClassCode,FullName=bb.FullName;
        
         
   merge into TMP_ExmM_NetExamScore aa 
    using eas_dic_scorecode@ouchnbase bb on (aa.ScoreCode=bb.diccode)
    when  MATCHED THEN
       update set aa.score=bb.dicscore;
       
   merge into TMP_ExmM_NetExamScore aa 
    using eas_exmm_netExamScore bb on (aa.studentcode=bb.studentcode and aa.UnifBatchCode=bb.UnifBatchCode and aa.SubjectCode=bb.SubjectCode)
     when  MATCHED THEN
          update set aa.sn=bb.sn;
          
   merge into eas_exmm_netExamScore aa
       using TMP_ExmM_NetExamScore bb on (aa.sn=bb.sn)
       when  MATCHED THEN
          update set aa.scorecode=bb.scorecode ,aa.score=bb.score,aa.maintainer=bb.maintainer,AA.MAINTAINDATE =BB.MAINTAINDATE 
        when not  MATCHED THEN   
       insert (
              SN,segmentcode,collegecode,learningcentercode,classcode,UnifBatchCode,SubjectCode,StudentCode,FullName,Score,ScoreCode,Maintainer,MaintainDate)
           values(bb.sn,bb.segmentcode,bb.collegecode,bb.learningcentercode,bb.classcode,bb.UnifBatchCode,bb.SubjectCode,bb.StudentCode,bb.FullName,bb.Score,bb.ScoreCode,bb.Maintainer,bb.MaintainDate);
   
   OutTotalCount:= SQL%ROWCOUNT;
   v_end := dbms_utility.get_time;
   DBMS_OUTPUT.PUT_LINE(v_end-v_start);
   
   --CLOSE sInfo;
   XMLDOM.FREEDOCUMENT(doc);
   RETCODE :=OutTotalCount;
    commit; 
    
   EXCEPTION
   WHEN OTHERS THEN 
   DBMS_OUTPUT.PUT_LINE(SQLERRM);
   RETCODE := -1;
    rollback;
END PR_EXMM_IMPORTNETSCORE;
/

